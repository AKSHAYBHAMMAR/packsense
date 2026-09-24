import '../data_sources/commodity_local_data.dart';
import '../models/commodity.dart';

/// Repository interface and implementation managing the commodity knowledge base.
/// Designed for clean extensibility so a future REST/FastAPI backend or Supabase
/// data source can be substituted without touching UI layers.
class CommodityRepository {
  static final CommodityRepository _instance = CommodityRepository._internal();
  factory CommodityRepository() => _instance;
  CommodityRepository._internal();

  /// Retrieve all active commodities, optionally paginated
  Future<List<Commodity>> getAllCommodities({int? limit, int? offset}) async {
    final activeItems =
        CommodityLocalData.allCommodities.where((c) => c.active).toList();
    final start = offset ?? 0;
    if (start >= activeItems.length) return [];
    if (limit != null) {
      final end = (start + limit).clamp(0, activeItems.length);
      return activeItems.sublist(start, end);
    }
    return activeItems.sublist(start);
  }

  /// Search commodities with case-insensitive multi-attribute ranking and exact-match prioritization
  Future<List<Commodity>> searchCommodities(
    String query, {
    String? category,
    int? limit,
    int? offset,
  }) async {
    final q = query.trim().toLowerCase();
    final activeItems =
        CommodityLocalData.allCommodities.where((c) => c.active);

    final filteredByCategory = (category != null &&
            category.isNotEmpty &&
            category != 'All')
        ? activeItems
            .where((c) => c.category.toLowerCase() == category.toLowerCase())
        : activeItems;

    if (q.isEmpty) {
      final list = filteredByCategory.toList();
      final start = offset ?? 0;
      if (start >= list.length) return [];
      if (limit != null) {
        final end = (start + limit).clamp(0, list.length);
        return list.sublist(start, end);
      }
      return list.sublist(start);
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
      return CommodityLocalData.allCommodities.where((c) => c.active).toList();
    }
    return CommodityLocalData.allCommodities
        .where((c) =>
            c.active && c.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  /// Get popular commodities for quick-access display
  Future<List<Commodity>> getPopularCommodities() async {
    return CommodityLocalData.popularCommodities;
  }

  /// Get all available category names
  Future<List<String>> getCategories() async {
    return CommodityLocalData.categories;
  }

  /// Total count of commodities in catalog
  int get totalCommodityCount => CommodityLocalData.allCommodities.length;
}
