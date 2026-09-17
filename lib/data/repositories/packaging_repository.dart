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

  /// Recent items shown on Home Screen matching Stitch design
  final List<RecentAnalysisItem> _recentAnalyses = [
    const RecentAnalysisItem(
      id: 'recent_tomato',
      foodName: 'Tomato',
      foodEmoji: '🍅',
      timeAgo: '2 hours ago',
      materialName: 'Breathable Micro-perforated Film',
      specsSummary: 'OTR: 1,850 cc/m² • Target RH: 90%',
      isMeasured: true,
    ),
    const RecentAnalysisItem(
      id: 'recent_potato',
      foodName: 'Potato',
      foodEmoji: '🥔',
      timeAgo: 'Yesterday',
      materialName: 'Jute / Ventilated Kraft Paper',
      specsSummary: 'Light Shielding: 99.2% • Prevents Solanine',
      isMeasured: false,
    ),
    const RecentAnalysisItem(
      id: 'recent_mango',
      foodName: 'Mango',
      foodEmoji: '🥭',
      timeAgo: '3 days ago',
      materialName: 'Corrugated Box with Ethylene Scavenger',
      specsSummary: 'Climacteric Delay: +6 Days Ambient Shelf Life',
      isMeasured: true,
    ),
  ];

  List<RecentAnalysisItem> getRecentAnalyses() => List.unmodifiable(_recentAnalyses);

  List<FoodItem> getCatalogFoods() => FoodItem.standardCatalog;

  List<PackagingMaterial> getAllMaterials() => [
        PackagingMaterial.breathableFilm,
        PackagingMaterial.macroPerforatedLdpe,
        PackagingMaterial.rPetClamshell,
        PackagingMaterial.compostablePla,
        PackagingMaterial.metallizedBopp,
        PackagingMaterial.kraftValveBag,
      ];

  void addAnalysis(RecentAnalysisItem item) {
    _recentAnalyses.insert(0, item);
  }

  PackagingRecommendationResult analyzePackaging(FoodProperties properties) {
    final result = PackagingRecommendationResult.compute(properties);
    return result;
  }
}
