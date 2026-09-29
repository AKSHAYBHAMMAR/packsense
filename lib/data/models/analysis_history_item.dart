import '../../core/utils/date_formatter.dart';
import 'food_properties.dart';
import 'recommendation.dart';

/// Database entity and UI model representing a persisted analysis record in Supabase.
class AnalysisHistoryItem {
  final String id;
  final String userId;
  final String productName;
  final bool hasProductData;
  final String analysisType; // 'measured' | 'ai_estimate'
  final double? moisture;
  final double? temperature;
  final double? relativeHumidity;
  final String? storageCondition;
  final String recommendedMaterial;
  final String? recommendationReason;
  final Map<String, dynamic>? barrierProperties;
  final String? predictedShelfLife;
  final double? confidenceScore;
  final Map<String, dynamic>? inputData;
  final Map<String, dynamic>? recommendationData;
  final DateTime createdAt;

  const AnalysisHistoryItem({
    required this.id,
    required this.userId,
    required this.productName,
    required this.hasProductData,
    required this.analysisType,
    this.moisture,
    this.temperature,
    this.relativeHumidity,
    this.storageCondition,
    required this.recommendedMaterial,
    this.recommendationReason,
    this.barrierProperties,
    this.predictedShelfLife,
    this.confidenceScore,
    this.inputData,
    this.recommendationData,
    required this.createdAt,
  });

  /// Compatibility getters matching Stitch UI card naming
  String get foodName => productName;
  String get materialName => recommendedMaterial;

  /// Computed relative time (e.g. "Just now", "2 hours ago", "Yesterday")
  String get timeAgo => DateFormatter.formatRelativeTime(createdAt);

  /// Detailed timestamp for View Details screen (e.g. "Sep 29, 2026 • 2:45 PM")
  String get formattedDateTime => DateFormatter.formatDetailedDateTime(createdAt);

  /// Returns true if this analysis was based on measured lab values
  bool get isMeasured =>
      analysisType.toLowerCase() == 'measured' || hasProductData;

  /// Inferred or stored food emoji
  String get foodEmoji {
    if (recommendationData != null &&
        recommendationData!['food_emoji'] != null &&
        recommendationData!['food_emoji'].toString().isNotEmpty) {
      return recommendationData!['food_emoji'].toString();
    }
    return _inferEmojiFromName(productName);
  }

  /// Key specifications summary line for History card
  /// Matches Stitch format: "OTR: 1,850 cc/m² • Target RH: 90%" or similar
  String get specsSummary {
    if (barrierProperties != null) {
      final otr = barrierProperties!['otr_spec']?.toString();
      final rh = relativeHumidity != null
          ? 'Target RH: ${relativeHumidity!.toStringAsFixed(0)}%'
          : (barrierProperties!['target_rh'] != null
              ? 'Target RH: ${barrierProperties!['target_rh']}'
              : (predictedShelfLife != null
                  ? 'Shelf Life: $predictedShelfLife'
                  : null));

      if (otr != null && rh != null) {
        return 'OTR: $otr • $rh';
      } else if (otr != null) {
        final wvtr = barrierProperties!['wvtr_spec']?.toString();
        if (wvtr != null) return 'OTR: $otr • WVTR: $wvtr';
        return 'OTR: $otr';
      }
    }

    if (predictedShelfLife != null && predictedShelfLife!.isNotEmpty) {
      return 'Target Shelf-Life: $predictedShelfLife';
    }

    return 'Optimized barrier preservation';
  }

  /// Deserializes a database record from Supabase table `analysis_history`
  factory AnalysisHistoryItem.fromJson(Map<String, dynamic> json) {
    return AnalysisHistoryItem(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      productName: json['product_name']?.toString() ?? 'Food Commodity',
      hasProductData: json['has_product_data'] == true,
      analysisType: json['analysis_type']?.toString() ?? 'ai_estimate',
      moisture: _toDouble(json['moisture']),
      temperature: _toDouble(json['temperature']),
      relativeHumidity: _toDouble(json['relative_humidity']),
      storageCondition: json['storage_condition']?.toString(),
      recommendedMaterial:
          json['recommended_material']?.toString() ?? 'Sustainable Packaging',
      recommendationReason: json['recommendation_reason']?.toString(),
      barrierProperties: json['barrier_properties'] is Map
          ? Map<String, dynamic>.from(json['barrier_properties'] as Map)
          : null,
      predictedShelfLife: json['predicted_shelf_life']?.toString(),
      confidenceScore: _toDouble(json['confidence_score']),
      inputData: json['input_data'] is Map
          ? Map<String, dynamic>.from(json['input_data'] as Map)
          : null,
      recommendationData: json['recommendation_data'] is Map
          ? Map<String, dynamic>.from(json['recommendation_data'] as Map)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Serializes model to Supabase table row
  Map<String, dynamic> toJson({bool includeId = true}) {
    final map = <String, dynamic>{
      'user_id': userId,
      'product_name': productName,
      'has_product_data': hasProductData,
      'analysis_type': analysisType,
      'moisture': moisture,
      'temperature': temperature,
      'relative_humidity': relativeHumidity,
      'storage_condition': storageCondition,
      'recommended_material': recommendedMaterial,
      'recommendation_reason': recommendationReason,
      'barrier_properties': barrierProperties,
      'predicted_shelf_life': predictedShelfLife,
      'confidence_score': confidenceScore,
      'input_data': inputData,
      'recommendation_data': recommendationData,
      'created_at': createdAt.toUtc().toIso8601String(),
    };

    if (includeId && id.isNotEmpty) {
      map['id'] = id;
    }

    return map;
  }

  /// Factory constructor to bridge from [PackagingRecommendationResult]
  factory AnalysisHistoryItem.fromRecommendation({
    required PackagingRecommendationResult result,
    required String userId,
    FoodProperties? properties,
    String? id,
    DateTime? createdAt,
  }) {
    final now = createdAt ?? DateTime.now();

    // Map barrier properties
    final barrierProps = <String, dynamic>{
      'o2_barrier_rating': result.o2BarrierRating,
      'moisture_control_rating': result.moistureControlRating,
      'condensation_rating': result.condensationRating,
      'otr_spec': result.primaryMatch.otrSpec,
      'wvtr_spec': result.primaryMatch.wvtrSpec,
      'match_tier': result.matchTier,
    };

    // Map input food properties if provided
    final inputMap = properties != null
        ? <String, dynamic>{
            'product_name': properties.productName,
            'food_category': properties.foodCategory,
            'food_type': properties.foodType,
            'physical_state': properties.physicalState.name,
            'moisture_percent': properties.moisturePercent,
            'ph': properties.ph,
            'oil_fat_percent': properties.oilFatPercent,
            'storage_temperature': properties.storageTemperature.name,
            'target_shelf_life_days': properties.targetShelfLifeDays,
            'transportation_distance': properties.transportationDistance.name,
            'fragility': properties.fragility.name,
            'sustainability_preference':
                properties.sustainabilityPreference.name,
            'budget_preference': properties.budgetPreference.name,
            'is_measured': properties.isMeasured,
          }
        : null;

    // Map recommendation output details
    final recMap = <String, dynamic>{
      'food_emoji': result.foodEmoji,
      'primary_material_id': result.primaryMatch.id,
      'match_tier': result.matchTier,
      'rationale_summary': result.rationaleSummary,
      'rationale_points': result.rationalePoints
          .map((p) => {'title': p.title, 'description': p.description})
          .toList(),
      'key_specifications': result.keySpecifications
          .map((s) => {
                'label': s.label,
                'tooltip': s.tooltip,
                'value': s.value,
                'unit': s.unit,
                'subtitle': s.subtitle,
                'footer_note': s.footerNote,
              })
          .toList(),
      'alternatives': result.alternatives.map((a) => a.id).toList(),
    };

    // Calculate inferred storage temperature in Celsius
    double? tempC;
    double? rhPercent;
    if (properties != null) {
      switch (properties.storageTemperature) {
        case StorageTemperature.frozen:
          tempC = -18.0;
          rhPercent = 90.0;
          break;
        case StorageTemperature.refrigerated:
          tempC = 4.0;
          rhPercent = 85.0;
          break;
        case StorageTemperature.roomTemp:
          tempC = 22.0;
          rhPercent = 60.0;
          break;
      }
    }

    return AnalysisHistoryItem(
      id: id ?? '',
      userId: userId,
      productName: result.foodName,
      hasProductData: result.basedOnMeasuredData,
      analysisType: result.basedOnMeasuredData ? 'measured' : 'ai_estimate',
      moisture: properties?.moisturePercent,
      temperature: tempC,
      relativeHumidity: rhPercent,
      storageCondition: result.storageCondition,
      recommendedMaterial: result.primaryMatch.name,
      recommendationReason: result.rationaleSummary,
      barrierProperties: barrierProps,
      predictedShelfLife: result.targetShelfLife,
      confidenceScore: result.matchTier == 'Optimal Fit' ? 0.95 : 0.88,
      inputData: inputMap,
      recommendationData: recMap,
      createdAt: now,
    );
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static String _inferEmojiFromName(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('tomato')) return '🍅';
    if (lower.contains('potato')) return '🥔';
    if (lower.contains('mango')) return '🥭';
    if (lower.contains('apple')) return '🍎';
    if (lower.contains('banana')) return '🍌';
    if (lower.contains('berry') || lower.contains('strawberr')) return '🍓';
    if (lower.contains('milk') || lower.contains('dairy')) return '🥛';
    if (lower.contains('cheese')) return '🧀';
    if (lower.contains('bread') || lower.contains('bakery')) return '🍞';
    if (lower.contains('meat') || lower.contains('beef')) return '🥩';
    if (lower.contains('fish') || lower.contains('salmon')) return '🐟';
    if (lower.contains('rice') || lower.contains('grain')) return '🌾';
    if (lower.contains('pulse') || lower.contains('bean')) return '🫘';
    return '📦';
  }
}
