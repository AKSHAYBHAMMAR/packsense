import '../models/food_item.dart';
import '../models/food_properties.dart';
import '../models/packaging_material.dart';
import '../models/recommendation.dart';

class RecentAnalysisItem {
  final String id;
  final String foodName;
  final String foodEmoji;
  final String timeAgo;
  final String materialName;
  final String specsSummary;
  final bool isMeasured;

  const RecentAnalysisItem({
    required this.id,
    required this.foodName,
    required this.foodEmoji,
    required this.timeAgo,
    required this.materialName,
    required this.specsSummary,
    required this.isMeasured,
  });
}

class PackagingRepository {
  static final PackagingRepository _instance = PackagingRepository._internal();
  factory PackagingRepository() => _instance;
  PackagingRepository._internal();

  /// Dynamic recent items populated strictly from real completed analyses
  final List<RecentAnalysisItem> _recentAnalyses = [];

  List<RecentAnalysisItem> getRecentAnalyses() =>
      List.unmodifiable(_recentAnalyses);

  List<FoodItem> getCatalogFoods() => FoodItem.standardCatalog;

  List<PackagingMaterial> getAllMaterials() => PackagingMaterial.allMaterials;

  void addAnalysis(RecentAnalysisItem item) {
    _recentAnalyses.insert(0, item);
  }

  PackagingRecommendationResult analyzePackaging(FoodProperties properties) {
    final result = PackagingRecommendationResult.compute(properties);
    return result;
  }
}
