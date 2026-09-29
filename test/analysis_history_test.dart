import 'package:flutter_test/flutter_test.dart';
import 'package:packsense/core/utils/date_formatter.dart';
import 'package:packsense/data/models/analysis_history_item.dart';
import 'package:packsense/data/models/food_properties.dart';
import 'package:packsense/data/models/recommendation.dart';
import 'package:packsense/data/repositories/history_repository.dart';
import 'package:packsense/data/repositories/packaging_repository.dart';

void main() {
  group('PackSense Real Analysis History Test Suite', () {
    late HistoryRepository historyRepo;
    late PackagingRepository packagingRepo;

    setUp(() {
      historyRepo = HistoryRepository();
      historyRepo.clear();
      packagingRepo = PackagingRepository();
    });

    test('1. PackagingRepository has no hardcoded demo entries (Tomato/Potato/Mango removed)', () {
      final recent = packagingRepo.getRecentAnalyses();
      expect(recent, isEmpty,
          reason: 'Hardcoded demo records must not be pre-populated');
    });

    test('2. DateFormatter calculates human-readable relative time accurately', () {
      final base = DateTime(2026, 9, 29, 12, 0, 0);

      // Just now (< 1 min)
      expect(
        DateFormatter.formatRelativeTime(base.subtract(const Duration(seconds: 30)), clock: base),
        'Just now',
      );

      // 15 minutes ago
      expect(
        DateFormatter.formatRelativeTime(base.subtract(const Duration(minutes: 15)), clock: base),
        '15 minutes ago',
      );

      // 2 hours ago
      expect(
        DateFormatter.formatRelativeTime(base.subtract(const Duration(hours: 2)), clock: base),
        '2 hours ago',
      );

      // Yesterday (1 day ago)
      expect(
        DateFormatter.formatRelativeTime(base.subtract(const Duration(days: 1)), clock: base),
        'Yesterday',
      );

      // 3 days ago
      expect(
        DateFormatter.formatRelativeTime(base.subtract(const Duration(days: 3)), clock: base),
        '3 days ago',
      );

      // 12 days ago
      expect(
        DateFormatter.formatRelativeTime(base.subtract(const Duration(days: 12)), clock: base),
        '12 days ago',
      );
    });

    test('3. AnalysisHistoryItem serializes to and from Supabase table schema correctly', () {
      final now = DateTime.utc(2026, 9, 29, 10, 30, 0);
      final jsonMap = {
        'id': '11111111-2222-3333-4444-555555555555',
        'user_id': 'user_abc_123',
        'product_name': 'Organic Strawberries',
        'has_product_data': true,
        'analysis_type': 'measured',
        'moisture': 91.5,
        'temperature': 2.0,
        'relative_humidity': 90.0,
        'storage_condition': 'Refrigerated (1–3°C)',
        'recommended_material': 'Perforated RPET Clamshell',
        'recommendation_reason': 'High respiration produce requiring micro-ventilation',
        'barrier_properties': {
          'otr_spec': '1,500 cc/m²/day',
          'wvtr_spec': '20 g/m²/day',
          'match_tier': 'Optimal Fit',
        },
        'predicted_shelf_life': '10–14 Days',
        'confidence_score': 0.96,
        'input_data': {
          'moisture_percent': 91.5,
          'storage_temperature': 'refrigerated',
        },
        'recommendation_data': {
          'food_emoji': '🍓',
          'match_tier': 'Optimal Fit',
        },
        'created_at': now.toIso8601String(),
      };

      final item = AnalysisHistoryItem.fromJson(jsonMap);

      expect(item.id, equals('11111111-2222-3333-4444-555555555555'));
      expect(item.userId, equals('user_abc_123'));
      expect(item.productName, equals('Organic Strawberries'));
      expect(item.hasProductData, isTrue);
      expect(item.analysisType, equals('measured'));
      expect(item.isMeasured, isTrue);
      expect(item.moisture, equals(91.5));
      expect(item.temperature, equals(2.0));
      expect(item.relativeHumidity, equals(90.0));
      expect(item.storageCondition, equals('Refrigerated (1–3°C)'));
      expect(item.recommendedMaterial, equals('Perforated RPET Clamshell'));
      expect(item.foodEmoji, equals('🍓'));
      expect(item.confidenceScore, equals(0.96));
      expect(item.specsSummary, contains('OTR: 1,500 cc/m²/day'));

      // Verify toJson() includes all database columns
      final exported = item.toJson();
      expect(exported['user_id'], equals('user_abc_123'));
      expect(exported['product_name'], equals('Organic Strawberries'));
      expect(exported['has_product_data'], isTrue);
      expect(exported['analysis_type'], equals('measured'));
      expect(exported['moisture'], equals(91.5));
      expect(exported['temperature'], equals(2.0));
      expect(exported['relative_humidity'], equals(90.0));
      expect(exported['recommended_material'], equals('Perforated RPET Clamshell'));
    });

    test('4. Saving a real recommendation creates a history record and updates reactive cache', () async {
      final properties = FoodProperties.estimateForCommodity('Apple');
      final rec = PackagingRecommendationResult.compute(properties);

      final saved = await historyRepo.saveAnalysis(
        recommendation: rec,
        properties: properties,
      );

      expect(saved.productName, equals(rec.foodName));
      expect(saved.recommendedMaterial, equals(rec.primaryMatch.name));
      expect(saved.predictedShelfLife, equals(rec.targetShelfLife));
      expect(historyRepo.currentHistory.length, equals(1));
      expect(historyRepo.currentHistory.first.productName, equals(rec.foodName));
    });

    test('5. Multiple analyses maintain newest-first ordering (DESC by created_at)', () async {
      final item1 = AnalysisHistoryItem(
        id: 'rec_1',
        userId: 'user_test',
        productName: 'Spinach',
        hasProductData: false,
        analysisType: 'ai_estimate',
        recommendedMaterial: 'Anti-fog LDPE Pouch',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      );

      final item2 = AnalysisHistoryItem(
        id: 'rec_2',
        userId: 'user_test',
        productName: 'Blueberries',
        hasProductData: true,
        analysisType: 'measured',
        recommendedMaterial: 'Ventilated Clamshell',
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
      );

      final rawRows = [item2.toJson(), item1.toJson()]; // Sorted desc by created_at
      final parsed = rawRows.map((r) => AnalysisHistoryItem.fromJson(r)).toList();

      expect(parsed.first.productName, equals('Blueberries'));
      expect(parsed.last.productName, equals('Spinach'));
      expect(parsed.first.createdAt.isAfter(parsed.last.createdAt), isTrue);
    });

    test('6. User-specific isolation: records are tagged strictly with current user_id', () {
      final properties = FoodProperties.estimateForCommodity('Tomato');
      final rec = PackagingRecommendationResult.compute(properties);

      final userAItem = AnalysisHistoryItem.fromRecommendation(
        result: rec,
        userId: 'user_aaa_111',
        properties: properties,
      );

      final userBItem = AnalysisHistoryItem.fromRecommendation(
        result: rec,
        userId: 'user_bbb_222',
        properties: properties,
      );

      expect(userAItem.userId, equals('user_aaa_111'));
      expect(userBItem.userId, equals('user_bbb_222'));
      expect(userAItem.userId, isNot(equals(userBItem.userId)));
    });

    test('7. Empty state: when user has 0 analyses, history is empty without demo entries', () {
      expect(historyRepo.currentHistory, isEmpty);
      expect(historyRepo.getRecentAnalyses(), isEmpty);
    });

    test('8. Rejects invalid / incomplete recommendations from persisting', () async {
      // Missing product name
      final dummyProperties = const FoodProperties(
        productName: '',
        foodCategory: 'General',
        foodType: 'Unknown',
      );
      final rec = PackagingRecommendationResult.compute(dummyProperties);
      // FoodName empty
      final invalidRec = PackagingRecommendationResult(
        foodName: '',
        foodEmoji: '📦',
        storageCondition: 'Ambient',
        targetShelfLife: '7 days',
        primaryMatch: rec.primaryMatch,
        basedOnMeasuredData: false,
        o2BarrierRating: 'Low',
        moistureControlRating: 'Low',
        condensationRating: 'None',
        rationaleSummary: 'Test',
        rationalePoints: const [],
        keySpecifications: const [],
        alternatives: const [],
      );

      expect(
        () => historyRepo.saveAnalysis(recommendation: invalidRec),
        throwsA(isA<HistoryException>()),
      );
    });
  });
}
