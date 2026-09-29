import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:packsense/core/theme/app_theme.dart';
import 'package:packsense/data/models/analysis_history_item.dart';
import 'package:packsense/data/models/food_properties.dart';
import 'package:packsense/data/models/recommendation.dart';
import 'package:packsense/data/repositories/history_repository.dart';
import 'package:packsense/presentation/history/history_detail_screen.dart';
import 'package:packsense/presentation/home/home_screen.dart';
import 'package:packsense/presentation/recommendation_flow/step4_recommendation_result_screen.dart';

void main() {
  group('PackSense History Navigation & Widget Tests', () {
    setUp(() {
      HistoryRepository().clear();
    });

    testWidgets('1. Bottom navigation renders Home, History, Profile and switches tabs without snackbars',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify bottom nav items exist
      expect(find.text('Home'), findsWidgets);
      expect(find.text('History'), findsWidgets);
      expect(find.text('Profile'), findsWidgets);

      // Verify no mock Tomato / Potato / Mango on screen initially
      expect(find.text('recent_tomato'), findsNothing);

      // Tap on History tab
      final historyTab = find.widgetWithText(InkWell, 'History');
      expect(historyTab, findsOneWidget);
      await tester.tap(historyTab);
      await tester.pumpAndSettle();

      // Verify NO snackbar saying 'History tab clicked'
      expect(find.text('History tab clicked'), findsNothing);

      // Verify History screen is displayed
      expect(find.text('Recent Analysis'), findsOneWidget);
    });

    testWidgets('2. Empty state renders correctly when no analyses have occurred',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Switch to History tab
      await tester.tap(find.widgetWithText(InkWell, 'History'));
      await tester.pumpAndSettle();

      // Verify empty state text
      expect(find.text('No analyses yet'), findsOneWidget);
      expect(find.text('Your completed packaging analyses will appear here.'),
          findsOneWidget);
      expect(find.text('Start Analysis'), findsOneWidget);
    });

    testWidgets('3. Populated analysis card renders real data and opens HistoryDetailScreen',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      // Seed a real analysis into the repository
      final realItem = AnalysisHistoryItem(
        id: 'test-real-uuid-001',
        userId: 'user_tester_999',
        productName: 'Organic Alphonso Mango',
        hasProductData: true,
        analysisType: 'measured',
        moisture: 82.0,
        temperature: 12.0,
        relativeHumidity: 88.0,
        storageCondition: 'Cool & Dry (10–12°C)',
        recommendedMaterial: 'Corrugated Box with Ethylene Scavenger',
        recommendationReason: 'Climacteric produce delay requirement',
        predictedShelfLife: '14 Days',
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      );

      final repo = HistoryRepository();
      repo.seedHistory([realItem]);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Open History tab
      await tester.tap(find.widgetWithText(InkWell, 'History'));
      await tester.pumpAndSettle();

      // Verify card content
      expect(find.text('Organic Alphonso Mango'), findsOneWidget);
      expect(find.text('Corrugated Box with Ethylene Scavenger'), findsOneWidget);
      expect(find.textContaining('10 minutes ago'), findsOneWidget);
      expect(find.text('MEASURED'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);

      // Tap on View Details
      await tester.tap(find.text('View Details'));
      await tester.pumpAndSettle();

      // Verify HistoryDetailScreen opened
      expect(find.byType(HistoryDetailScreen), findsOneWidget);
      expect(find.text('Analysis Record'), findsOneWidget);
      expect(find.text('Organic Alphonso Mango'), findsOneWidget);
      expect(find.text('RECOMMENDED PACKAGING'), findsOneWidget);
      expect(find.text('Corrugated Box with Ethylene Scavenger'), findsOneWidget);
      expect(find.text('Moisture Content'), findsOneWidget);
      expect(find.text('82.0%'), findsOneWidget);

      // Verify "← Home" button is present at top-left
      final homeButton = find.byKey(const Key('history_detail_back_to_home_button'));
      expect(homeButton, findsOneWidget);
      expect(find.descendant(of: homeButton, matching: find.text('Home')), findsOneWidget);
      expect(find.descendant(of: homeButton, matching: find.byIcon(Icons.arrow_back)), findsOneWidget);

      // Tap "← Home" button
      await tester.tap(homeButton);
      await tester.pumpAndSettle();

      // Verify we returned directly to HomeScreen and Home tab is active
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('Smarter Packaging. Better Food.'), findsOneWidget);
      expect(find.text('Explore Packaging Materials'), findsOneWidget);
    });

    testWidgets('4. Step4RecommendationResultScreen renders top-left "← Home" button and navigates to Home',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final properties = FoodProperties.estimateForCommodity('Tomato');
      final recommendation = PackagingRecommendationResult.compute(properties);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const HomeScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Push Step4RecommendationResultScreen to simulate analysis completion
      final BuildContext context = tester.element(find.byType(HomeScreen));
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => Step4RecommendationResultScreen(
            recommendation: recommendation,
            foodProperties: properties,
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Step4 screen is displayed
      expect(find.byType(Step4RecommendationResultScreen), findsOneWidget);
      expect(find.text('PackSense'), findsOneWidget);
      expect(find.byIcon(Icons.share), findsWidgets);
      expect(find.byIcon(Icons.help_outline), findsOneWidget);

      // Verify "← Home" button is present at top-left
      final homeButton = find.byKey(const Key('back_to_home_button'));
      expect(homeButton, findsOneWidget);
      expect(find.descendant(of: homeButton, matching: find.text('Home')), findsOneWidget);
      expect(find.descendant(of: homeButton, matching: find.byIcon(Icons.arrow_back)), findsOneWidget);

      // Click "← Home"
      await tester.tap(homeButton);
      await tester.pumpAndSettle();

      // Verify it returned directly to HomeScreen on the Home tab
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(Step4RecommendationResultScreen), findsNothing);
      expect(find.text('Smarter Packaging. Better Food.'), findsOneWidget);
      expect(find.text('Explore Packaging Materials'), findsOneWidget);
    });
  });
}
