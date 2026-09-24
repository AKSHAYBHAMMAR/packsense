import 'food_item.dart';
import 'food_properties.dart';

/// Controlled qualitative respiration rate enum
enum RespirationRate {
  veryLow,
  low,
  moderate,
  high,
  veryHigh,
  none,
}

extension RespirationRateExtension on RespirationRate {
  String get label {
    switch (this) {
      case RespirationRate.veryLow:
        return 'Very Low';
      case RespirationRate.low:
        return 'Low';
      case RespirationRate.moderate:
        return 'Moderate';
      case RespirationRate.high:
        return 'High';
      case RespirationRate.veryHigh:
        return 'Very High';
      case RespirationRate.none:
        return 'None / Inactive';
    }
  }
}

/// Controlled sensitivity level enum
enum SensitivityLevel {
  none,
  low,
  moderate,
  high,
  veryHigh,
  notApplicable,
}

extension SensitivityLevelExtension on SensitivityLevel {
  String get label {
    switch (this) {
      case SensitivityLevel.none:
        return 'None';
      case SensitivityLevel.low:
        return 'Low';
      case SensitivityLevel.moderate:
        return 'Moderate';
      case SensitivityLevel.high:
        return 'High';
      case SensitivityLevel.veryHigh:
        return 'Very High';
      case SensitivityLevel.notApplicable:
        return 'N/A';
    }
  }
}

/// Comprehensive, extensible commodity profile model
class Commodity {
  final String id;
  final String name;
  final String displayName;
  final String category;
  final String subcategory;
  final String? scientificName;
  final List<String> aliases;
  final String description;
  final String emoji;
  final String characteristicBadge;
  final bool active;

  // Food characteristics
  final RespirationRate respirationRate;
  final SensitivityLevel moistureSensitivity;
  final SensitivityLevel oxygenSensitivity;
  final SensitivityLevel carbonDioxideSensitivity;
  final SensitivityLevel ethyleneSensitivity;
  final SensitivityLevel lightSensitivity;
  final FragilityLevel fragility;
  final StorageTemperature temperatureRequirement;
  final String humidityRequirement;
  final int shelfLifeDays;
  final String freshnessRequirement;

  // Additional characteristics
  final PhysicalState physicalState;
  final String processingState;
  final String storageCondition;
  final List<String> typicalPackagingChallenges;
  final String notes;
  final double moisturePercent;
  final double ph;
  final double oilFatPercent;

  // Scientific metadata (extensibility & provenance)
  final String? source;
  final String? sourceTitle;
  final String? sourceUrl;
  final String? sourceType;
  final String? lastReviewed;

  const Commodity({
    required this.id,
    required this.name,
    required this.displayName,
    required this.category,
    required this.subcategory,
    this.scientificName,
    this.aliases = const [],
    required this.description,
    required this.emoji,
    required this.characteristicBadge,
    this.active = true,
    required this.respirationRate,
    required this.moistureSensitivity,
    required this.oxygenSensitivity,
    this.carbonDioxideSensitivity = SensitivityLevel.low,
    this.ethyleneSensitivity = SensitivityLevel.notApplicable,
    this.lightSensitivity = SensitivityLevel.low,
    required this.fragility,
    required this.temperatureRequirement,
    required this.humidityRequirement,
    required this.shelfLifeDays,
    required this.freshnessRequirement,
    this.physicalState = PhysicalState.solid,
    this.processingState = 'Raw / Fresh',
    required this.storageCondition,
    this.typicalPackagingChallenges = const [],
    this.notes = '',
    required this.moisturePercent,
    required this.ph,
    required this.oilFatPercent,
    this.source,
    this.sourceTitle,
    this.sourceUrl,
    this.sourceType,
    this.lastReviewed,
  });

  /// Convert to legacy [FoodItem] for UI compatibility
  FoodItem toFoodItem() {
    return FoodItem(
      id: id,
      name: displayName.isNotEmpty ? displayName : name,
      scientificName: scientificName,
      category: category,
      emoji: emoji,
      characteristicBadge: characteristicBadge,
      description: description,
    );
  }

  /// Convert to [FoodProperties] for the recommendation engine
  FoodProperties toFoodProperties({bool isMeasured = false}) {
    return FoodProperties(
      productName: displayName.isNotEmpty ? displayName : name,
      foodCategory: category,
      foodType: '$subcategory ($processingState)',
      physicalState: physicalState,
      moisturePercent: moisturePercent,
      ph: ph,
      oilFatPercent: oilFatPercent,
      storageTemperature: temperatureRequirement,
      targetShelfLifeDays: shelfLifeDays,
      transportationDistance: TransportationDistance.regional,
      fragility: fragility,
      sustainabilityPreference: SustainabilityPreference.recyclable,
      budgetPreference: BudgetTier.moderate,
      isMeasured: isMeasured,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'category': category,
      'subcategory': subcategory,
      'scientificName': scientificName,
      'aliases': aliases,
      'description': description,
      'emoji': emoji,
      'characteristicBadge': characteristicBadge,
      'active': active,
      'respirationRate': respirationRate.name,
      'moistureSensitivity': moistureSensitivity.name,
      'oxygenSensitivity': oxygenSensitivity.name,
      'carbonDioxideSensitivity': carbonDioxideSensitivity.name,
      'ethyleneSensitivity': ethyleneSensitivity.name,
      'lightSensitivity': lightSensitivity.name,
      'fragility': fragility.name,
      'temperatureRequirement': temperatureRequirement.name,
      'humidityRequirement': humidityRequirement,
      'shelfLifeDays': shelfLifeDays,
      'freshnessRequirement': freshnessRequirement,
      'physicalState': physicalState.name,
      'processingState': processingState,
      'storageCondition': storageCondition,
      'typicalPackagingChallenges': typicalPackagingChallenges,
      'notes': notes,
      'moisturePercent': moisturePercent,
      'ph': ph,
      'oilFatPercent': oilFatPercent,
      'source': source,
      'sourceTitle': sourceTitle,
      'sourceUrl': sourceUrl,
      'sourceType': sourceType,
      'lastReviewed': lastReviewed,
    };
  }

  factory Commodity.fromJson(Map<String, dynamic> json) {
    return Commodity(
      id: json['id'] as String,
      name: json['name'] as String,
      displayName: json['displayName'] as String? ?? json['name'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String? ?? 'General',
      scientificName: json['scientificName'] as String?,
      aliases: (json['aliases'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      description: json['description'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '📦',
      characteristicBadge: json['characteristicBadge'] as String? ?? 'Standard',
      active: json['active'] as bool? ?? true,
      respirationRate: RespirationRate.values.byName(
        json['respirationRate'] as String? ?? 'moderate',
      ),
      moistureSensitivity: SensitivityLevel.values.byName(
        json['moistureSensitivity'] as String? ?? 'moderate',
      ),
      oxygenSensitivity: SensitivityLevel.values.byName(
        json['oxygenSensitivity'] as String? ?? 'moderate',
      ),
      carbonDioxideSensitivity: SensitivityLevel.values.byName(
        json['carbonDioxideSensitivity'] as String? ?? 'low',
      ),
      ethyleneSensitivity: SensitivityLevel.values.byName(
        json['ethyleneSensitivity'] as String? ?? 'notApplicable',
      ),
      lightSensitivity: SensitivityLevel.values.byName(
        json['lightSensitivity'] as String? ?? 'low',
      ),
      fragility: FragilityLevel.values.byName(
        json['fragility'] as String? ?? 'medium',
      ),
      temperatureRequirement: StorageTemperature.values.byName(
        json['temperatureRequirement'] as String? ?? 'refrigerated',
      ),
      humidityRequirement: json['humidityRequirement'] as String? ?? 'Ambient',
      shelfLifeDays: json['shelfLifeDays'] as int? ?? 7,
      freshnessRequirement:
          json['freshnessRequirement'] as String? ?? 'Standard',
      physicalState: PhysicalState.values.byName(
        json['physicalState'] as String? ?? 'solid',
      ),
      processingState: json['processingState'] as String? ?? 'Raw / Fresh',
      storageCondition: json['storageCondition'] as String? ?? 'Standard',
      typicalPackagingChallenges:
          (json['typicalPackagingChallenges'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],
      notes: json['notes'] as String? ?? '',
      moisturePercent: (json['moisturePercent'] as num?)?.toDouble() ?? 50.0,
      ph: (json['ph'] as num?)?.toDouble() ?? 5.5,
      oilFatPercent: (json['oilFatPercent'] as num?)?.toDouble() ?? 1.0,
      source: json['source'] as String?,
      sourceTitle: json['sourceTitle'] as String?,
      sourceUrl: json['sourceUrl'] as String?,
      sourceType: json['sourceType'] as String?,
      lastReviewed: json['lastReviewed'] as String?,
    );
  }
}
