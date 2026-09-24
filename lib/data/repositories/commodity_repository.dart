import '../data_sources/commodity_local_data.dart';
import '../models/commodity.dart';

/// The 100 concrete products required by the PackSense initial catalog specification.
const List<String> kPrimaryTargetCommodityNames = [
  // FRUITS (20)
  'Apple',
  'Banana',
  'Mango',
  'Orange',
  'Grapes',
  'Strawberry',
  'Watermelon',
  'Papaya',
  'Pineapple',
  'Pomegranate',
  'Guava',
  'Kiwi',
  'Pear',
  'Peach',
  'Plum',
  'Cherry',
  'Dragon Fruit',
  'Jackfruit',
  'Lychee',
  'Coconut',

  // VEGETABLES (25)
  'Tomato',
  'Potato',
  'Onion',
  'Garlic',
  'Ginger',
  'Carrot',
  'Beetroot',
  'Radish',
  'Cucumber',
  'Capsicum',
  'Green Chilli',
  'Brinjal',
  'Okra',
  'Broccoli',
  'Cauliflower',
  'Cabbage',
  'Spinach',
  'Lettuce',
  'Green Peas',
  'Green Beans',
  'Sweet Corn',
  'Pumpkin',
  'Bottle Gourd',
  'Bitter Gourd',
  'Sweet Potato',

  // GRAINS & CEREALS (12)
  'Rice',
  'Basmati Rice',
  'Brown Rice',
  'Wheat',
  'Whole Wheat',
  'Corn',
  'Oats',
  'Barley',
  'Ragi',
  'Bajra',
  'Jowar',
  'Quinoa',

  // PULSES & LEGUMES (9)
  'Chickpeas',
  'Black Chickpeas',
  'Lentils',
  'Red Lentils',
  'Green Gram',
  'Black Gram',
  'Kidney Beans',
  'Soybeans',
  'Pigeon Peas',

  // NUTS & SEEDS (9)
  'Almond',
  'Cashew',
  'Walnut',
  'Pistachio',
  'Peanut',
  'Sunflower Seeds',
  'Pumpkin Seeds',
  'Chia Seeds',
  'Sesame Seeds',

  // DAIRY (7)
  'Milk',
  'Curd',
  'Yogurt',
  'Paneer',
  'Cheese',
  'Butter',
  'Ghee',

  // BAKERY & SNACKS (9)
  'Bread',
  'Cake',
  'Muffin',
  'Biscuits',
  'Cookies',
  'Crackers',
  'Potato Chips',
  'Popcorn',
  'Namkeen',

  // SPICES & HERBS (9)
  'Turmeric',
  'Red Chilli Powder',
  'Black Pepper',
  'Cumin',
  'Coriander',
  'Cardamom',
  'Clove',
  'Cinnamon',
  'Fennel',
];

/// Repository interface and implementation managing the commodity knowledge base.
/// Designed for clean extensibility so a future REST/FastAPI backend or Supabase
/// data source can be substituted without touching UI layers.
class CommodityRepository {
  static final CommodityRepository _instance = CommodityRepository._internal();
  factory CommodityRepository() => _instance;
  CommodityRepository._internal();

  /// User-facing categories matching the UI specifications
  static const List<String> userFacingCategories = [
    'All',
    'Fruits',
    'Vegetables',
    'Grains',
    'Pulses',
    'Nuts & Seeds',
    'Dairy',
    'Bakery',
    'Snacks',
    'Spices',
    'Meat',
    'Seafood',
    'Beverages',
    'Processed Foods',
    'Confectionery',
    'Frozen Foods',
  ];

  /// Checks if a commodity's category matches the user-selected category
  static bool matchesCategory(String itemCategory, String selectedCategory) {
    if (selectedCategory == 'All' || selectedCategory.isEmpty) return true;
    final item = itemCategory.trim().toLowerCase();
    final selected = selectedCategory.trim().toLowerCase();
    if (item == selected) return true;
    if (selected == 'grains' &&
        (item.contains('grain') || item.contains('cereal'))) return true;
    if (selected == 'pulses' &&
        (item.contains('pulse') || item.contains('legume'))) return true;
    if (selected == 'snacks' && item.contains('snack')) return true;
    if (selected == 'bakery' && item.contains('baker')) return true;
    if (selected == 'spices' &&
        (item.contains('spice') || item.contains('herb'))) return true;
    if (selected == 'nuts & seeds' &&
        (item.contains('nut') || item.contains('seed'))) return true;
    if (selected == 'dairy' && item.contains('dairy')) return true;
    if (item.startsWith(selected)) return true;
    return false;
  }

  /// Returns the complete catalog ordered with the 100 core user-facing commodities
  /// at the beginning, followed by the remaining comprehensive commodities.
  List<Commodity> getOrderedCatalog() {
    final active =
        CommodityLocalData.allCommodities.where((c) => c.active).toList();
    final primaryList = <Commodity>[];
    final otherList = <Commodity>[];

    final mapByName = <String, Commodity>{};
    for (final c in active) {
      mapByName[c.name.toLowerCase()] = c;
    }

    final addedIds = <String>{};

    for (final targetName in kPrimaryTargetCommodityNames) {
      final match = mapByName[targetName.toLowerCase()];
      if (match != null && !addedIds.contains(match.id)) {
        primaryList.add(match);
        addedIds.add(match.id);
      }
    }

    for (final c in active) {
      if (!addedIds.contains(c.id)) {
        otherList.add(c);
      }
    }

    return [...primaryList, ...otherList];
  }

  /// Retrieve all active commodities, optionally paginated with initial 100 priority
  Future<List<Commodity>> getAllCommodities({int? limit, int? offset}) async {
    final ordered = getOrderedCatalog();
    final start = offset ?? 0;
    if (start >= ordered.length) return [];
    if (limit != null) {
      final end = (start + limit).clamp(0, ordered.length);
      return ordered.sublist(start, end);
    }
    return ordered.sublist(start);
  }

  /// Retrieve the initial user-facing catalog (at least 100 visible products)
  Future<List<Commodity>> getInitialCatalog(
      {int limit = 100, int offset = 0}) async {
    final ordered = getOrderedCatalog();
    final start = offset.clamp(0, ordered.length);
    final end = (start + limit).clamp(0, ordered.length);
    return ordered.sublist(start, end);
  }

  /// Search commodities with case-insensitive multi-attribute ranking and exact-match prioritization
  Future<List<Commodity>> searchCommodities(
    String query, {
    String? category,
    int? limit,
    int? offset,
  }) async {
    final q = query.trim().toLowerCase();
    final ordered = getOrderedCatalog();

    final filteredByCategory = (category != null &&
            category.isNotEmpty &&
            category != 'All')
        ? ordered.where((c) => matchesCategory(c.category, category)).toList()
        : ordered;

    if (q.isEmpty) {
      final start = offset ?? 0;
      if (start >= filteredByCategory.length) return [];
      if (limit != null) {
        final end = (start + limit).clamp(0, filteredByCategory.length);
        return filteredByCategory.sublist(start, end);
      }
      return filteredByCategory.sublist(start);
    }

    final List<MapEntry<Commodity, int>> scored = [];

    for (final commodity in filteredByCategory) {
      final nameLower = commodity.name.toLowerCase();
      final displayLower = commodity.displayName.toLowerCase();
      final categoryLower = commodity.category.toLowerCase();
      final subcategoryLower = commodity.subcategory.toLowerCase();
      final scientificLower = commodity.scientificName?.toLowerCase() ?? '';
      final aliasesLower =
          commodity.aliases.map((a) => a.toLowerCase()).toList();

      int score = 0;

      // 1. Exact matches (highest priority)
      if (nameLower == q) {
        score += 1000;
      } else if (displayLower == q) {
        score += 950;
      } else if (aliasesLower.contains(q)) {
        score += 850;
      }

      // 2. Starts with query
      if (nameLower.startsWith(q)) {
        score += 600;
      } else if (displayLower.startsWith(q)) {
        score += 550;
      } else if (nameLower.split(' ').any((w) => w.startsWith(q))) {
        score += 450;
      } else if (aliasesLower.any((a) => a.startsWith(q))) {
        score += 400;
      }

      // 3. Substring containment in name or aliases
      if (nameLower.contains(q)) {
        score += 300;
      } else if (displayLower.contains(q)) {
        score += 250;
      } else if (aliasesLower.any((a) => a.contains(q))) {
        score += 200;
      }

      // 4. Subcategory / Category / Scientific name matches
      if (subcategoryLower == q) {
        score += 220;
      } else if (subcategoryLower.contains(q)) {
        score += 140;
      }

      if (scientificLower.contains(q)) {
        score += 150;
      }

      if (categoryLower == q) {
        score += 100;
      } else if (categoryLower.contains(q)) {
        score += 60;
      }

      // 5. Description containment (lowest weighting)
      if (commodity.description.toLowerCase().contains(q)) {
        score += 25;
      }

      if (score > 0) {
        scored.add(MapEntry(commodity, score));
      }
    }

    // Sort by relevance score descending, then by name length, then alphabetically
    scored.sort((a, b) {
      final scoreComp = b.value.compareTo(a.value);
      if (scoreComp != 0) return scoreComp;
      final lenComp = a.key.name.length.compareTo(b.key.name.length);
      if (lenComp != 0) return lenComp;
      return a.key.name.compareTo(b.key.name);
    });

    final sortedItems = scored.map((e) => e.key).toList();
    final start = offset ?? 0;
    if (start >= sortedItems.length) return [];
    if (limit != null) {
      final end = (start + limit).clamp(0, sortedItems.length);
      return sortedItems.sublist(start, end);
    }
    return sortedItems.sublist(start);
  }

  /// Look up single commodity by ID
  Future<Commodity?> getCommodityById(String id) async {
    try {
      return CommodityLocalData.allCommodities.firstWhere(
        (c) => c.id.toLowerCase() == id.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Look up commodity by name or exact alias
  Future<Commodity?> getCommodityByName(String name) async {
    final lower = name.trim().toLowerCase();
    try {
      return CommodityLocalData.allCommodities.firstWhere(
        (c) =>
            c.name.toLowerCase() == lower ||
            c.displayName.toLowerCase() == lower ||
            c.aliases.any((a) => a.toLowerCase() == lower),
      );
    } catch (_) {
      return null;
    }
  }

  /// Get list of commodities belonging to a specific category
  Future<List<Commodity>> getCommoditiesByCategory(String category) async {
    if (category == 'All' || category.isEmpty) {
      return getOrderedCatalog();
    }
    return getOrderedCatalog()
        .where((c) => matchesCategory(c.category, category))
        .toList();
  }

  /// Get popular commodities for quick-access display
  Future<List<Commodity>> getPopularCommodities() async {
    return CommodityLocalData.popularCommodities;
  }

  /// Get all available category names
  Future<List<String>> getCategories() async {
    return userFacingCategories;
  }

  /// Total count of commodities in catalog
  int get totalCommodityCount => CommodityLocalData.allCommodities.length;
}
