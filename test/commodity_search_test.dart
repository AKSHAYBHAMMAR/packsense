import 'dart:io';
import '../lib/data/data_sources/commodity_local_data.dart';
import '../lib/data/models/food_properties.dart';
import '../lib/data/models/recommendation.dart';
import '../lib/data/repositories/commodity_repository.dart';

void main() async {
  int totalTests = 0;
  int passedTests = 0;

  void test(String description, void Function() body) {
    totalTests++;
    try {
      body();
      passedTests++;
      print('  ✓ $description');
    } catch (e, stack) {
      print('  ✗ $description');
      print('    Error: $e');
      print('    $stack');
    }
  }

  Future<void> asyncTest(
      String description, Future<void> Function() body) async {
    totalTests++;
    try {
      await body();
      passedTests++;
      print('  ✓ $description');
    } catch (e, stack) {
      print('  ✗ $description');
      print('    Error: $e');
      print('    $stack');
    }
  }

  print('\n=== PackSense Commodity Database & Search Test Suite ===\n');

  final repo = CommodityRepository();

  // Test 1: Database Size & Integrity (250–300 range)
  test('1. Catalog contains approximately 250–300 profiles', () {
    final count = CommodityLocalData.allCommodities.length;
    print('    Catalog profile count: $count');
    if (count < 240 || count > 320) {
      throw Exception('Expected 240-320 commodities, found $count');
    }
  });

  // Test 2: Duplicate commodity detection
  test('2. All commodity IDs in the catalog are strictly unique', () {
    final ids = <String>{};
    final duplicates = <String>[];
    for (final c in CommodityLocalData.allCommodities) {
      if (ids.contains(c.id)) {
        duplicates.add(c.id);
      }
      ids.add(c.id);
    }
    if (duplicates.isNotEmpty) {
      throw Exception('Duplicate commodity IDs detected: $duplicates');
    }
  });

  // Test 3: Exact search
  await asyncTest('3. Exact search: "mango" prioritizes Mango at rank 1',
      () async {
    final results = await repo.searchCommodities('mango');
    if (results.isEmpty) throw Exception('No results for "mango"');
    if (results.first.name.toLowerCase() != 'mango') {
      throw Exception(
          'Expected first result to be "Mango", got "${results.first.name}"');
    }
  });

  // Test 4: Partial search
  await asyncTest(
      '4. Partial search: "man" returns matching commodities (Mango, Mandarin, etc.)',
      () async {
    final results = await repo.searchCommodities('man');
    if (results.isEmpty) throw Exception('No results for "man"');
    final names = results.map((c) => c.name.toLowerCase()).toList();
    if (!names.any((n) => n.contains('man'))) {
      throw Exception('No names containing "man" found in: $names');
    }
  });

  // Test 5: Case-insensitive search
  await asyncTest('5. Case-insensitive search: "MANGO" and "mAnGo" match Mango',
      () async {
    final results1 = await repo.searchCommodities('MANGO');
    final results2 = await repo.searchCommodities('mAnGo');
    if (results1.isEmpty || results2.isEmpty) {
      throw Exception('Case-insensitive search failed');
    }
    if (results1.first.id != results2.first.id) {
      throw Exception('Results mismatch for different casing');
    }
  });

  // Test 6: Alias search
  await asyncTest(
      '6. Alias search: "Aam" finds Mango, "Spud" finds Potato, "Tamatar" finds Tomato',
      () async {
    final mangoResults = await repo.searchCommodities('Aam');
    if (!mangoResults.any((c) => c.name == 'Mango')) {
      throw Exception('Failed to find Mango using alias "Aam"');
    }

    final potatoResults = await repo.searchCommodities('Spud');
    if (!potatoResults.any((c) => c.name == 'Potato')) {
      throw Exception('Failed to find Potato using alias "Spud"');
    }

    final tomatoResults = await repo.searchCommodities('Tamatar');
    if (!tomatoResults.any((c) => c.name == 'Tomato')) {
      throw Exception('Failed to find Tomato using alias "Tamatar"');
    }
  });

  // Test 7: Category filtering
  await asyncTest('7. Category filtering: "Dairy" returns only Dairy items',
      () async {
    final dairyItems = await repo.getCommoditiesByCategory('Dairy');
    if (dairyItems.isEmpty) throw Exception('No dairy items returned');
    for (final item in dairyItems) {
      if (item.category != 'Dairy') {
        throw Exception(
            'Non-dairy item returned in dairy category: ${item.name} (${item.category})');
      }
    }
  });

  // Test 8: All required categories are present
  test('8. All 16 primary categories have rich profiles', () {
    final allCats =
        CommodityLocalData.categories.where((c) => c != 'All').toList();
    for (final cat in allCats) {
      final items = CommodityLocalData.allCommodities
          .where((c) => c.category == cat)
          .toList();
      if (items.isEmpty) {
        throw Exception('Category "$cat" has 0 profiles!');
      }
    }
  });

  // Test 9: No-result search (unsupported products)
  await asyncTest('9. Unsupported query: returns empty result list cleanly',
      () async {
    final results =
        await repo.searchCommodities('nonexistent_space_food_xyz_999');
    if (results.isNotEmpty) {
      throw Exception(
          'Expected empty list for nonexistent food, got ${results.length} items');
    }
  });

  // Test 10: Popular commodities
  await asyncTest(
      '10. Popular commodities list contains the 8 quick-select items',
      () async {
    final popular = await repo.getPopularCommodities();
    if (popular.length < 8) {
      throw Exception(
          'Expected at least 8 popular commodities, got ${popular.length}');
    }
    final names = popular.map((c) => c.name.toLowerCase()).toList();
    if (!names.contains('tomato') ||
        !names.contains('apple') ||
        !names.contains('potato')) {
      throw Exception('Popular commodities missing baseline items: $names');
    }
  });

  // Test 11: FoodProperties conversion from Commodity
  test('11. Commodity model accurately converts to FoodProperties', () {
    final mango = CommodityLocalData.allCommodities
        .firstWhere((c) => c.id == 'fruit_mango');
    final props = mango.toFoodProperties();
    if (props.productName != mango.displayName) {
      throw Exception('Product name mismatch in FoodProperties');
    }
    if (props.moisturePercent != mango.moisturePercent) {
      throw Exception('Moisture percent mismatch');
    }
    if (props.ph != mango.ph) {
      throw Exception('pH mismatch');
    }
  });

  // Test 12: Recommendation Engine Integration (Characteristics-based, not product name based)
  test(
      '12. Recommendation engine derives scientifically accurate packaging from characteristics',
      () {
    // Produce with high respiration -> Breathable perforated film
    final tomatoProps = FoodProperties.estimateForCommodity('Tomato');
    final tomatoRec = PackagingRecommendationResult.compute(tomatoProps);
    if (tomatoRec.primaryMatch.id != 'bopp_ldpe_perforated') {
      throw Exception(
          'Expected breathable film for high-respiration produce, got ${tomatoRec.primaryMatch.name}');
    }

    // High fat dry snack -> Metallized barrier pouch
    final chipsProps = FoodProperties.estimateForCommodity('Potato Chips');
    final chipsRec = PackagingRecommendationResult.compute(chipsProps);
    if (chipsRec.primaryMatch.id != 'metallized_bopp') {
      throw Exception(
          'Expected metallized BOPP for high fat chips, got ${chipsRec.primaryMatch.name}');
    }

    // Light-sensitive tuber -> Ventilated Kraft Bag
    final potatoProps = FoodProperties.estimateForCommodity('Potato');
    final potatoRec = PackagingRecommendationResult.compute(potatoProps);
    if (potatoRec.primaryMatch.id != 'kraft_valve_bag') {
      throw Exception(
          'Expected kraft valve bag for light-sensitive potato, got ${potatoRec.primaryMatch.name}');
    }

    // Liquid beverage -> Aseptic Carton or Glass Jar
    final juiceProps = FoodProperties.estimateForCommodity('Fruit Juice');
    final juiceRec = PackagingRecommendationResult.compute(juiceProps);
    if (juiceRec.primaryMatch.id != 'aseptic_carton' &&
        juiceRec.primaryMatch.id != 'glass_jar_hermetic') {
      throw Exception(
          'Expected liquid packaging for fruit juice, got ${juiceRec.primaryMatch.name}');
    }
  });

  // Test 13: Minimum 80 visible user-facing catalog products (Target 100)
  await asyncTest(
      '13. Initial user-facing catalog returns at least 80 (target 100+) visible products',
      () async {
    final initialCatalog = await repo.getInitialCatalog(limit: 100);
    if (initialCatalog.length < 80) {
      throw Exception(
          'Expected at least 80 visible catalog products, got ${initialCatalog.length}');
    }
    if (initialCatalog.length < 100) {
      throw Exception(
          'Target 100 visible products not met, got ${initialCatalog.length}');
    }
    print('    Initial user-facing catalog size: ${initialCatalog.length}');
  });

  // Test 14: All 100 concrete commodities from Section 3 exist by exact name
  test('14. All 100 concrete commodities from Section 3 exist in the catalog',
      () {
    final allNames = CommodityLocalData.allCommodities
        .map((c) => c.name.toLowerCase())
        .toSet();
    final missing = <String>[];
    for (final target in kPrimaryTargetCommodityNames) {
      if (!allNames.contains(target.toLowerCase())) {
        missing.add(target);
      }
    }
    if (missing.isNotEmpty) {
      throw Exception('Missing concrete target commodities: $missing');
    }
    print(
        '    All ${kPrimaryTargetCommodityNames.length} target commodities verified present!');
  });

  // Test 15: Every commodity has complete structured characteristics and is analyzable
  test(
      '15. Every commodity is analyzable and can generate packaging recommendations',
      () {
    for (final commodity in CommodityLocalData.allCommodities) {
      if (commodity.id.isEmpty)
        throw Exception('Commodity has empty ID: ${commodity.name}');
      if (commodity.name.isEmpty)
        throw Exception('Commodity has empty name: ${commodity.id}');
      if (commodity.category.isEmpty)
        throw Exception('Commodity has empty category: ${commodity.name}');
      if (commodity.shelfLifeDays <= 0)
        throw Exception('Invalid shelf life for ${commodity.name}');

      // Must convert to FoodProperties and FoodItem without error
      final foodItem = commodity.toFoodItem();
      if (foodItem.name.isEmpty)
        throw Exception('FoodItem has empty name for ${commodity.name}');

      final foodProps = commodity.toFoodProperties();
      final rec = PackagingRecommendationResult.compute(foodProps);
      if (rec.primaryMatch.id.isEmpty) {
        throw Exception('Recommendation engine failed for ${commodity.name}');
      }
    }
    print(
        '    All ${CommodityLocalData.allCommodities.length} commodities verified fully analyzable!');
  });

  print('\n=== Test Results: $passedTests / $totalTests Passed ===\n');

  if (passedTests != totalTests) {
    exit(1);
  }
}
