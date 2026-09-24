import '../data_sources/commodity_local_data.dart';

enum PhysicalState { solid, liquid, semiSolid, powder }

enum StorageTemperature { roomTemp, refrigerated, frozen }

enum TransportationDistance { local, regional, longDistance }

enum FragilityLevel { low, medium, high }

enum SustainabilityPreference { standard, recyclable, compostable }

enum BudgetTier { economical, moderate, premium }

/// Comprehensive food characteristics model based on product requirements
class FoodProperties {
  final String productName;
  final String foodCategory;
  final String foodType;
  final PhysicalState physicalState;
  final double moisturePercent; // e.g. 85.0%
  final double ph; // e.g. 4.4
  final double oilFatPercent; // e.g. 0.2%
  final StorageTemperature storageTemperature;
  final int targetShelfLifeDays; // e.g. 7 days
  final TransportationDistance transportationDistance;
  final FragilityLevel fragility;
  final SustainabilityPreference sustainabilityPreference;
  final BudgetTier budgetPreference;
  final bool isMeasured; // whether user entered lab values or AI estimated

  const FoodProperties({
    required this.productName,
    required this.foodCategory,
    required this.foodType,
    this.physicalState = PhysicalState.solid,
    this.moisturePercent = 80.0,
    this.ph = 5.0,
    this.oilFatPercent = 1.0,
    this.storageTemperature = StorageTemperature.refrigerated,
    this.targetShelfLifeDays = 7,
    this.transportationDistance = TransportationDistance.regional,
    this.fragility = FragilityLevel.medium,
    this.sustainabilityPreference = SustainabilityPreference.recyclable,
    this.budgetPreference = BudgetTier.moderate,
    this.isMeasured = false,
  });

  /// Factory to generate estimated properties for known commodities
  factory FoodProperties.estimateForCommodity(String commodityName) {
    final query = commodityName.trim().toLowerCase();

    // Check if commodity exists in the structured database
    for (final c in CommodityLocalData.allCommodities) {
      if (c.name.toLowerCase() == query ||
          c.displayName.toLowerCase() == query ||
          c.id.toLowerCase() == query ||
          c.aliases.any((a) => a.toLowerCase() == query)) {
        return c.toFoodProperties(isMeasured: false);
      }
    }

    // Secondary partial matching for broader input
    for (final c in CommodityLocalData.allCommodities) {
      if (c.name.toLowerCase().contains(query) ||
          query.contains(c.name.toLowerCase())) {
        return c.toFoodProperties(isMeasured: false);
      }
    }

    // Safe general fallback if unsupported
    return FoodProperties(
      productName: commodityName,
      foodCategory: 'General Food',
      foodType: 'Standard Commodity',
      physicalState: PhysicalState.solid,
      moisturePercent: 60.0,
      ph: 5.5,
      oilFatPercent: 5.0,
      storageTemperature: StorageTemperature.roomTemp,
      targetShelfLifeDays: 14,
      transportationDistance: TransportationDistance.regional,
      fragility: FragilityLevel.medium,
      sustainabilityPreference: SustainabilityPreference.recyclable,
      budgetPreference: BudgetTier.moderate,
      isMeasured: false,
    );
  }

  FoodProperties copyWith({
    String? productName,
    String? foodCategory,
    String? foodType,
    PhysicalState? physicalState,
    double? moisturePercent,
    double? ph,
    double? oilFatPercent,
    StorageTemperature? storageTemperature,
    int? targetShelfLifeDays,
    TransportationDistance? transportationDistance,
    FragilityLevel? fragility,
    SustainabilityPreference? sustainabilityPreference,
    BudgetTier? budgetPreference,
    bool? isMeasured,
  }) {
    return FoodProperties(
      productName: productName ?? this.productName,
      foodCategory: foodCategory ?? this.foodCategory,
      foodType: foodType ?? this.foodType,
      physicalState: physicalState ?? this.physicalState,
      moisturePercent: moisturePercent ?? this.moisturePercent,
      ph: ph ?? this.ph,
      oilFatPercent: oilFatPercent ?? this.oilFatPercent,
      storageTemperature: storageTemperature ?? this.storageTemperature,
      targetShelfLifeDays: targetShelfLifeDays ?? this.targetShelfLifeDays,
      transportationDistance:
          transportationDistance ?? this.transportationDistance,
      fragility: fragility ?? this.fragility,
      sustainabilityPreference:
          sustainabilityPreference ?? this.sustainabilityPreference,
      budgetPreference: budgetPreference ?? this.budgetPreference,
      isMeasured: isMeasured ?? this.isMeasured,
    );
  }
}
