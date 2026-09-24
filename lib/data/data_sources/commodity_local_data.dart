import '../models/commodity.dart';
import 'commodities/bakery_snacks_data.dart';
import 'commodities/beverages_processed_data.dart';
import 'commodities/catalog_extension_data.dart';
import 'commodities/catalog_extension_two.dart';
import 'commodities/confectionery_frozen_data.dart';
import 'commodities/dairy_eggs_data.dart';
import 'commodities/fruits_data.dart';
import 'commodities/grains_pulses_data.dart';
import 'commodities/meat_seafood_data.dart';
import 'commodities/spices_nuts_data.dart';
import 'commodities/vegetables_data.dart';

/// Primary local data provider for the PackSense Commodity Catalog
class CommodityLocalData {
  CommodityLocalData._();

  /// Comprehensive list of all food commodities in the knowledge base
  static final List<Commodity> allCommodities = List.unmodifiable([
    ...fruitCommodities,
    ...vegetableCommodities,
    ...grainAndPulseCommodities,
    ...dairyAndEggCommodities,
    ...bakeryAndSnackCommodities,
    ...spiceAndNutCommodities,
    ...meatAndSeafoodCommodities,
    ...beverageAndProcessedCommodities,
    ...confectioneryAndFrozenCommodities,
    ...extensionCommodities,
    ...extensionTwoCommodities,
  ]);

  /// 8 Popular quick-select commodities preserved from the original catalog
  static List<Commodity> get popularCommodities {
    const popularIds = [
      'veg_tomato',
      'fruit_apple',
      'fruit_mango',
      'veg_potato',
      'grain_rice_white',
      'snack_biscuits_glucose',
      'snack_potato_chips',
      'spice_turmeric_powder',
    ];
    return allCommodities.where((c) => popularIds.contains(c.id)).toList();
  }

  /// All registered categories for filtering
  static const List<String> categories = [
    'All',
    'Fruits',
    'Vegetables',
    'Grains & Cereals',
    'Pulses & Legumes',
    'Nuts & Seeds',
    'Dairy',
    'Eggs',
    'Bakery',
    'Biscuits & Snacks',
    'Spices & Herbs',
    'Meat',
    'Seafood',
    'Beverages',
    'Processed Foods',
    'Confectionery',
    'Frozen Foods',
  ];
}
