import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../core/config/supabase_config.dart';
import '../models/analysis_history_item.dart';
import '../models/food_properties.dart';
import '../models/recommendation.dart';

/// Custom exception thrown when History operations fail
class HistoryException implements Exception {
  final String message;
  final dynamic technicalDetails;
  final StackTrace? stackTrace;

  HistoryException(this.message, [this.technicalDetails, this.stackTrace]);

  @override
  String toString() =>
      'HistoryException: $message ${technicalDetails != null ? '($technicalDetails)' : ''}';
}

/// Custom exception for unauthenticated access attempts
class UnauthenticatedHistoryException extends HistoryException {
  UnauthenticatedHistoryException()
      : super('User must be authenticated with Supabase to access analysis history.');
}

/// Repository responsible for persisting and querying real food packaging analysis records
/// in Supabase table `analysis_history` with strict user-level isolation and RLS enforcement.
class HistoryRepository {
  static final HistoryRepository _instance = HistoryRepository._internal();
  factory HistoryRepository() => _instance;
  HistoryRepository._internal();

  /// Cached items for the current session (ordered newest first)
  final List<AnalysisHistoryItem> _cachedHistory = [];

  /// ValueNotifier broadcasting the current list of history items to listeners
  final ValueNotifier<List<AnalysisHistoryItem>> historyNotifier =
      ValueNotifier<List<AnalysisHistoryItem>>([]);

  /// Access current cached items immutably
  List<AnalysisHistoryItem> get currentHistory =>
      List.unmodifiable(_cachedHistory);

  /// Helper to get the top N most recent analyses for Home Screen display
  List<AnalysisHistoryItem> getRecentAnalyses([int limit = 3]) {
    if (_cachedHistory.isEmpty) return const [];
    return _cachedHistory.take(limit).toList();
  }

  /// Queries all analysis history records belonging to the authenticated Supabase user.
  /// Results are ordered by `created_at DESC` (newest first).
  Future<List<AnalysisHistoryItem>> fetchUserHistory({bool forceRefresh = false}) async {
    // If Supabase is not configured or not initialized
    if (!SupabaseConfig.isConfigured || !SupabaseConfig.isInitialized) {
      debugPrint('[HistoryRepository] Supabase is not configured. Returning local session history.');
      historyNotifier.value = List.unmodifiable(_cachedHistory);
      return currentHistory;
    }

    final user = SupabaseConfig.currentUser;
    if (user == null) {
      debugPrint('[HistoryRepository] No authenticated Supabase user. Cannot query history.');
      _cachedHistory.clear();
      historyNotifier.value = const [];
      throw UnauthenticatedHistoryException();
    }

    try {
      final client = SupabaseConfig.client!;
      // SELECT * FROM analysis_history WHERE user_id = current_user ORDER BY created_at DESC
      final response = await client
          .from('analysis_history')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      final List<dynamic> rows = response as List<dynamic>;
      final items = rows
          .map((row) =>
              AnalysisHistoryItem.fromJson(Map<String, dynamic>.from(row as Map)))
          .toList();

      _cachedHistory.clear();
      _cachedHistory.addAll(items);
      historyNotifier.value = List.unmodifiable(_cachedHistory);

      debugPrint(
          '[HistoryRepository] Loaded ${items.length} analysis history records for user ${user.id}');
      return currentHistory;
    } catch (e, st) {
      debugPrint('[HistoryRepository] Error querying analysis_history from Supabase: $e\n$st');
      throw HistoryException('Failed to retrieve analysis history from Supabase.', e, st);
    }
  }

  /// Persists a successfully generated [PackagingRecommendationResult] to Supabase.
  ///
  /// - Only saves complete and successful analyses.
  /// - Associates the record strictly with [user_id].
  /// - Immediately updates the local reactive cache so History reflects the item instantly.
  Future<AnalysisHistoryItem> saveAnalysis({
    required PackagingRecommendationResult recommendation,
    FoodProperties? properties,
  }) async {
    // 1. Validation - Do not save incomplete or invalid analyses
    if (recommendation.foodName.trim().isEmpty ||
        recommendation.primaryMatch.name.trim().isEmpty) {
      throw HistoryException('Cannot save analysis with incomplete recommendation data.');
    }

    final user = SupabaseConfig.currentUser;
    final userId = user?.id ?? 'session_${DateTime.now().millisecondsSinceEpoch}';

    final tempItem = AnalysisHistoryItem.fromRecommendation(
      result: recommendation,
      userId: userId,
      properties: properties,
      id: 'local_${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );

    // If Supabase is not configured or user is unauthenticated
    if (!SupabaseConfig.isConfigured || !SupabaseConfig.isInitialized) {
      debugPrint(
          '[HistoryRepository] Supabase not active. Saving analysis to local session store.');
      _prependToLocalCache(tempItem);
      return tempItem;
    }

    if (user == null) {
      debugPrint(
          '[HistoryRepository] User is not authenticated. Saving to local session cache.');
      _prependToLocalCache(tempItem);
      return tempItem;
    }

    try {
      final client = SupabaseConfig.client!;
      final payload = tempItem.toJson(includeId: false);

      // INSERT INTO analysis_history (user_id, ...) VALUES (...) RETURNING *
      final response = await client
          .from('analysis_history')
          .insert(payload)
          .select()
          .single();

      final savedItem = AnalysisHistoryItem.fromJson(
          Map<String, dynamic>.from(response as Map));

      _prependToLocalCache(savedItem);
      debugPrint(
          '[HistoryRepository] Successfully saved analysis ${savedItem.id} for user ${savedItem.userId}');
      return savedItem;
    } catch (e, st) {
      debugPrint('[HistoryRepository] Failed to insert analysis_history to Supabase: $e\n$st');
      // Keep in local cache so user's current session analysis is not lost
      _prependToLocalCache(tempItem);
      throw HistoryException('Could not persist analysis to Supabase.', e, st);
    }
  }

  /// Retrieves a specific analysis record by ID from local cache or Supabase.
  Future<AnalysisHistoryItem?> getAnalysisById(String id) async {
    // Check in-memory cache first
    try {
      final cached = _cachedHistory.firstWhere((item) => item.id == id);
      return cached;
    } catch (_) {}

    final user = SupabaseConfig.currentUser;
    if (user == null || !SupabaseConfig.isConfigured || !SupabaseConfig.isInitialized) {
      return null;
    }

    try {
      final client = SupabaseConfig.client!;
      final response = await client
          .from('analysis_history')
          .select()
          .eq('id', id)
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) return null;
      return AnalysisHistoryItem.fromJson(
          Map<String, dynamic>.from(response as Map));
    } catch (e) {
      debugPrint('[HistoryRepository] Error fetching analysis $id: $e');
      return null;
    }
  }

  /// Deletes a specific history record
  Future<void> deleteAnalysis(String id) async {
    _cachedHistory.removeWhere((item) => item.id == id);
    historyNotifier.value = List.unmodifiable(_cachedHistory);

    final user = SupabaseConfig.currentUser;
    if (user != null && SupabaseConfig.isInitialized) {
      try {
        final client = SupabaseConfig.client!;
        await client
            .from('analysis_history')
            .delete()
            .eq('id', id)
            .eq('user_id', user.id);
        debugPrint('[HistoryRepository] Deleted analysis record $id');
      } catch (e) {
        debugPrint('[HistoryRepository] Failed to delete analysis $id: $e');
      }
    }
  }

  /// Prepend item to local cache, avoiding duplicates
  void _prependToLocalCache(AnalysisHistoryItem item) {
    _cachedHistory.removeWhere((existing) =>
        existing.id == item.id ||
        (existing.id.startsWith('local_') &&
            existing.productName == item.productName &&
            existing.createdAt.difference(item.createdAt).inSeconds.abs() < 5));
    _cachedHistory.insert(0, item);
    historyNotifier.value = List.unmodifiable(_cachedHistory);
  }

  /// Seeds initial items or test fixtures into cache and reactive notifier
  void seedHistory(List<AnalysisHistoryItem> items) {
    _cachedHistory.clear();
    _cachedHistory.addAll(items);
    historyNotifier.value = List.unmodifiable(_cachedHistory);
  }

  /// Reset in-memory cache (e.g., on sign out)
  void clear() {
    _cachedHistory.clear();
    historyNotifier.value = const [];
  }
}
