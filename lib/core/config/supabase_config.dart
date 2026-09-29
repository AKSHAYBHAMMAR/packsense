import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Centralized configuration and lifecycle manager for Supabase.
///
/// Manages connection, authentication status, and public client access.
/// Never exposes or requires service-role keys.
class SupabaseConfig {
  SupabaseConfig._();

  // Read environment variables passed at compile-time or run-time
  static String _envUrl = const String.fromEnvironment('SUPABASE_URL', defaultValue: '');
  static String _envAnonKey = const String.fromEnvironment('SUPABASE_ANON_KEY', defaultValue: '');

  static String get supabaseUrl => _envUrl;
  static String get supabaseAnonKey => _envAnonKey;

  /// Allows programmatic override or runtime injection of Supabase credentials
  static void setCredentials({required String url, required String anonKey}) {
    _envUrl = url.trim();
    _envAnonKey = anonKey.trim();
  }

  static bool get isConfigured =>
      _envUrl.isNotEmpty &&
      _envAnonKey.isNotEmpty &&
      !_envUrl.contains('YOUR_SUPABASE') &&
      !_envAnonKey.contains('YOUR_ANON');

  static bool get isInitialized {
    try {
      final _ = Supabase.instance.client;
      return true;
    } catch (_) {
      return false;
    }
  }

  static SupabaseClient? get client {
    if (!isInitialized) return null;
    return Supabase.instance.client;
  }

  static User? get currentUser {
    try {
      return client?.auth.currentUser;
    } catch (_) {
      return null;
    }
  }

  static String? get currentUserId => currentUser?.id;

  static bool get isAuthenticated => currentUser != null;

  static Stream<AuthState>? get authStateChanges {
    try {
      return client?.auth.onAuthStateChange;
    } catch (_) {
      return null;
    }
  }

  /// Initialize Supabase client.
  /// Safely catches configuration missing without terminating the application.
  static Future<void> initialize() async {
    if (!isConfigured) {
      debugPrint('[PackSense] Supabase is not configured. Set SUPABASE_URL and SUPABASE_ANON_KEY.');
      return;
    }

    try {
      await Supabase.initialize(
        url: _envUrl,
        // ignore: deprecated_member_use
        anonKey: _envAnonKey,
        debug: kDebugMode,
      );
      debugPrint('[PackSense] Supabase initialized successfully. URL: $_envUrl');
    } catch (e, st) {
      debugPrint('[PackSense] Failed to initialize Supabase: $e\n$st');
    }
  }

  /// Sign in with email and password
  static Future<AuthResponse?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final c = client;
    if (c == null) throw StateError('Supabase client is not initialized.');
    return await c.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign up with email and password
  static Future<AuthResponse?> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final c = client;
    if (c == null) throw StateError('Supabase client is not initialized.');
    return await c.auth.signUp(
      email: email.trim(),
      password: password,
    );
  }

  /// Sign in anonymously (if anonymous logins are enabled in Supabase)
  static Future<AuthResponse?> signInAnonymously() async {
    final c = client;
    if (c == null) throw StateError('Supabase client is not initialized.');
    return await c.auth.signInAnonymously();
  }

  /// Sign out current user
  static Future<void> signOut() async {
    final c = client;
    if (c != null) {
      await c.auth.signOut();
    }
  }
}
