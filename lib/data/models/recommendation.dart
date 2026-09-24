import '../data_sources/commodity_local_data.dart';
import 'commodity.dart';
import 'food_properties.dart';
import 'packaging_material.dart';

class RationalePoint {
  final String title;
  final String description;

  const RationalePoint({
    required this.title,
    required this.description,
  });
}

class KeySpecification {
  final String label;
  final String tooltip;
  final String value;
  final String unit;
  final String subtitle;
  final String footerNote;

  const KeySpecification({
    required this.label,
    required this.tooltip,
    required this.value,
    required this.unit,
    required this.subtitle,
    required this.footerNote,
  });
}

/// Recommendation result model encapsulating match analysis
class PackagingRecommendationResult {
  final String foodName;
  final String foodEmoji;
  final String storageCondition;
  final String targetShelfLife;
  final PackagingMaterial primaryMatch;
  final String matchTier; // e.g. "Optimal Fit", "Strong Match"
  final bool basedOnMeasuredData;
  final String o2BarrierRating;
  final String moistureControlRating;
  final String condensationRating;
  final String rationaleSummary;
  final List<RationalePoint> rationalePoints;
  final List<KeySpecification> keySpecifications;
  final List<PackagingMaterial> alternatives;

  const PackagingRecommendationResult({
    required this.foodName,
    required this.foodEmoji,
    required this.storageCondition,
    required this.targetShelfLife,
    required this.primaryMatch,
    this.matchTier = 'Strong Match',
    required this.basedOnMeasuredData,
    required this.o2BarrierRating,
    required this.moistureControlRating,
    required this.condensationRating,
    required this.rationaleSummary,
    required this.rationalePoints,
    required this.keySpecifications,
    required this.alternatives,
  });

  /// Multi-attribute requirement-based recommendation engine.
  /// Analyzes food characteristics -> determines technical packaging requirements
  /// -> scores candidate packaging materials -> selects optimal primary match and alternatives.
  factory PackagingRecommendationResult.compute(FoodProperties properties) {
    final bool measured = properties.isMeasured;
    final String name =
        properties.productName.isEmpty ? 'Commodity' : properties.productName;

    // 1. Look up structured commodity metadata if registered
    Commodity? matchedCommodity;
    final lowerName = name.toLowerCase().trim();
    for (final c in CommodityLocalData.allCommodities) {
      if (c.name.toLowerCase() == lowerName ||
          c.displayName.toLowerCase() == lowerName ||
          c.aliases.any((a) => a.toLowerCase() == lowerName)) {
        matchedCommodity = c;
        break;
      }
    }

    final emoji =
        matchedCommodity?.emoji ?? _inferEmoji(properties.foodCategory);
    final respiration = matchedCommodity?.respirationRate ??
        (properties.foodCategory.toLowerCase().contains('produce') ||
                properties.foodCategory.toLowerCase().contains('fruit') ||
                properties.foodCategory.toLowerCase().contains('veg')
            ? RespirationRate.moderate
            : RespirationRate.none);

    final lightSens = matchedCommodity?.lightSensitivity ??
        (properties.oilFatPercent > 20 || lowerName.contains('potato')
            ? SensitivityLevel.high
            : SensitivityLevel.low);

    // 2. Score candidate materials against technical requirements
    final candidates =
        List<PackagingMaterial>.from(PackagingMaterial.allMaterials);
    final Map<PackagingMaterial, double> scores = {};

    for (final mat in candidates) {
      double score = 100.0;

      // Rule A: Physical State
      if (properties.physicalState == PhysicalState.liquid) {
        if (mat.id == 'aseptic_carton') score += 90;
        if (mat.id == 'glass_jar_hermetic') score += 70;
        if (mat.category == 'Flexible Films' || mat.category == 'Paper & Fiber')
          score -= 120;
      } else if (properties.physicalState == PhysicalState.semiSolid) {
        if (mat.id == 'glass_jar_hermetic') score += 75;
        if (mat.id == 'retort_pouch') score += 65;
        if (mat.id == 'evoh_vacuum_pouch') score += 50;
        if (mat.category == 'Paper & Fiber') score -= 90;
      } else if (properties.physicalState == PhysicalState.powder) {
        if (mat.id == 'metallized_bopp') score += 60;
        if (mat.id == 'aroma_tin_canister') score += 65;
        if (mat.id == 'kraft_valve_bag') score += 40;
        if (mat.id == 'bopp_ldpe_perforated' || mat.id == 'macro_ldpe')
          score -= 100;
      }

      // Rule B: Temperature & Deep Freeze
      if (properties.storageTemperature == StorageTemperature.frozen) {
        if (mat.id == 'deep_freeze_pe') score += 100;
        if (mat.id == 'evoh_vacuum_pouch') score += 40;
        if (mat.id == 'glass_jar_hermetic')
          score -= 60; // Shatter risk on freeze
        if (mat.id == 'kraft_valve_bag') score -= 70;
      } else if (properties.storageTemperature ==
          StorageTemperature.refrigerated) {
        if (mat.id == 'bopp_ldpe_perforated' &&
            (respiration == RespirationRate.high ||
                respiration == RespirationRate.veryHigh)) {
          score += 70;
        }
        if (mat.id == 'evoh_vacuum_pouch' &&
            (properties.foodCategory == 'Meat' ||
                properties.foodCategory == 'Seafood' ||
                properties.foodCategory == 'Dairy')) {
          score += 85;
        }
      }

      // Rule C: Respiration Rate (Gas Permeability vs Hermetic Barrier)
      if (respiration == RespirationRate.high ||
          respiration == RespirationRate.veryHigh) {
        // Needs breathability / anti-fog; hermetic foil creates anaerobic alcohol fermentation
        if (mat.id == 'bopp_ldpe_perforated') score += 80;
        if (mat.id == 'macro_ldpe') score += 50;
        if (mat.id == 'pla_compostable') score += 60;
        if (mat.id == 'rpet_clamshell') score += 65;
        if (mat.id == 'metallized_bopp' || mat.id == 'retort_pouch')
          score -= 110;
      } else if (respiration == RespirationRate.veryLow ||
          respiration == RespirationRate.none) {
        // Dry or processed items need tight moisture/oxygen barrier
        if (mat.id == 'metallized_bopp' && properties.moisturePercent < 15)
          score += 65;
        if (mat.id == 'kraft_valve_bag' &&
            (properties.foodCategory == 'Grains & Cereals' ||
                properties.foodCategory == 'Pulses & Legumes' ||
                lowerName.contains('potato'))) {
          score += 60;
        }
      }

      // Rule D: High Lipids / Oil Oxidation (OTR Sensitivity)
      if (properties.oilFatPercent >= 15.0) {
        if (mat.id == 'metallized_bopp') score += 70;
        if (mat.id == 'aroma_tin_canister') score += 65;
        if (mat.id == 'evoh_vacuum_pouch') score += 55;
        if (mat.id == 'macro_ldpe' || mat.id == 'pla_compostable') score -= 60;
      }

      // Rule E: High Fragility (Mechanical Crush Protection)
      if (properties.fragility == FragilityLevel.high) {
        if (mat.id == 'rpet_clamshell') score += 65;
        if (mat.id == 'metallized_bopp') score += 30; // Cushioning pillow pouch
        if (mat.id == 'aroma_tin_canister') score += 40;
      }

      // Rule F: Light Sensitivity (Photo-oxidation & Greening)
      if (lightSens == SensitivityLevel.veryHigh ||
          lightSens == SensitivityLevel.high) {
        if (mat.id == 'kraft_valve_bag') score += 60;
        if (mat.id == 'metallized_bopp') score += 55;
        if (mat.id == 'aroma_tin_canister') score += 65;
        if (mat.id == 'aseptic_carton') score += 60;
        if (mat.id == 'rpet_clamshell' && !lowerName.contains('berry'))
          score -= 40;
      }

      // Rule G: Sustainability Preference
      if (properties.sustainabilityPreference ==
          SustainabilityPreference.compostable) {
        if (mat.id == 'pla_compostable' || mat.id == 'kraft_valve_bag')
          score += 45;
      } else if (properties.sustainabilityPreference ==
          SustainabilityPreference.recyclable) {
        if (mat.recyclabilityCode.contains('RIC 1') ||
            mat.recyclabilityCode.contains('RIC 4') ||
            mat.recyclabilityCode.contains('Paper')) {
          score += 25;
        }
      }

      // Rule H: Budget Tier
      if (properties.budgetPreference == BudgetTier.economical) {
        if (mat.costTier.toLowerCase().contains('economical')) score += 30;
        if (mat.costTier.toLowerCase().contains('premium')) score -= 30;
      } else if (properties.budgetPreference == BudgetTier.premium) {
        if (mat.costTier.toLowerCase().contains('premium')) score += 20;
      }

      scores[mat] = score;
    }

    // Sort materials by calculated score descending
    candidates.sort((a, b) => (scores[b] ?? 0).compareTo(scores[a] ?? 0));

    final PackagingMaterial primary = candidates.first;
    final List<PackagingMaterial> alts = candidates.skip(1).take(2).toList();

    // 3. Synthesize scientifically grounded rationale and barrier metrics
    final storageStr = matchedCommodity?.storageCondition ??
        (properties.storageTemperature == StorageTemperature.frozen
            ? 'Deep Frozen (-18°C)'
            : properties.storageTemperature == StorageTemperature.refrigerated
                ? 'Chilled (2–6°C)'
                : 'Ambient Room Temp (20–25°C)');

    final shelfLifeStr = '${properties.targetShelfLifeDays}d Target';

    final String o2Rating;
    final String moistureRating;
    final String condensationRating;

    if (respiration == RespirationRate.high ||
        respiration == RespirationRate.veryHigh) {
      o2Rating = 'Produce Tuned (1,200–1,800 cc)';
      moistureRating = 'Equilibrium Breathable';
      condensationRating = 'Anti-Fog Micro-Vented';
    } else if (properties.storageTemperature == StorageTemperature.frozen) {
      o2Rating = 'Sub-Zero Crack Proof';
      moistureRating = 'Ice Sublimation Lock';
      condensationRating = 'Zero Freezer Burn';
    } else if (properties.oilFatPercent > 15 ||
        properties.moisturePercent < 10) {
      o2Rating = 'Ultra-High Barrier (OTR < 1.0)';
      moistureRating = 'Hermetic Moisture Shield';
      condensationRating = 'N2 / Vacuum Flush Ready';
    } else if (properties.physicalState == PhysicalState.liquid) {
      o2Rating = 'Hermetic Gas Lock';
      moistureRating = 'Liquid Hermetic Seal';
      condensationRating = 'Sterile Barrier';
    } else {
      o2Rating = 'Optimized Barrier';
      moistureRating = 'Vapor Safe';
      condensationRating = 'Balanced Diffusion';
    }

    final String rationale =
        'PackSense matched ${properties.productName} with ${primary.name} based on its ${respiration != RespirationRate.none ? "active respiration balance" : "barrier preservation needs"}, ${properties.moisturePercent.toStringAsFixed(0)}% moisture content, and ${properties.storageTemperature.name} conditions.';

    final rationalePoints = [
      RationalePoint(
        title: 'Product Compatibility',
        description:
            'Engineered for ${properties.foodType.isNotEmpty ? properties.foodType : properties.foodCategory} requirements, maintaining food structure and sensory quality.',
      ),
      RationalePoint(
        title: 'Atmosphere & Barrier Dynamics',
        description: primary.description,
      ),
      RationalePoint(
        title: 'Storage & Target Longevity',
        description:
            'Calibrated for $storageStr to reliably achieve the $shelfLifeStr preservation threshold.',
      ),
      RationalePoint(
        title: 'Eco & Material Viability',
        description:
            '${primary.ecoBadge}: ${primary.ecoDetail} (${primary.recyclabilityCode}).',
      ),
    ];

    final keySpecs = [
      KeySpecification(
        label: 'Gas Transmission',
        tooltip: 'Oxygen permeation balance for commodity preservation',
        value: primary.otrSpec.split(' ').first,
        unit: primary.otrSpec.contains('cc') ? 'OTR' : 'Barrier Index',
        subtitle: primary.otrSpec,
        footerNote: 'Protects aroma and cellular vitality',
      ),
      KeySpecification(
        label: 'Moisture Control',
        tooltip: 'Water vapor transmission rate across polymer matrix',
        value: primary.wvtrSpec.split(' ').first,
        unit: primary.wvtrSpec.contains('g') ? 'WVTR' : 'Moisture Lock',
        subtitle: primary.wvtrSpec,
        footerNote: 'Prevents sogginess and dehydration',
      ),
      KeySpecification(
        label: 'Durability',
        tooltip: 'Material gauge and puncture endurance',
        value: primary.thickness,
        unit: '',
        subtitle: primary.durability,
        footerNote: '${primary.polymerCode} composite layer',
      ),
      KeySpecification(
        label: 'Cost & Eco Tier',
        tooltip: 'Lifecycle footprint and cost rating',
        value: primary.costTier,
        unit: '',
        subtitle: primary.ecoBadge,
        footerNote: primary.recyclabilityCode,
      ),
    ];

    return PackagingRecommendationResult(
      foodName: properties.productName,
      foodEmoji: emoji,
      storageCondition: storageStr,
      targetShelfLife: shelfLifeStr,
      primaryMatch: primary,
      matchTier: 'Optimal Fit',
      basedOnMeasuredData: measured,
      o2BarrierRating: o2Rating,
      moistureControlRating: moistureRating,
      condensationRating: condensationRating,
      rationaleSummary: rationale,
      rationalePoints: rationalePoints,
      keySpecifications: keySpecs,
      alternatives: alts,
    );
  }

  static String _inferEmoji(String category) {
    switch (category.toLowerCase()) {
      case 'fruits':
        return '🍎';
      case 'vegetables':
        return '🥦';
      case 'grains & cereals':
        return '🌾';
      case 'pulses & legumes':
        return '🫘';
      case 'nuts & seeds':
        return '🥜';
      case 'dairy':
        return '🥛';
      case 'eggs':
        return '🥚';
      case 'bakery':
        return '🍞';
      case 'biscuits & snacks':
        return '🍪';
      case 'spices & herbs':
        return '🌿';
      case 'meat':
        return '🥩';
      case 'seafood':
        return '🐟';
      case 'beverages':
        return '🧃';
      case 'processed foods':
        return '🥫';
      case 'confectionery':
        return '🍫';
      case 'frozen foods':
        return '🧊';
      default:
        return '📦';
    }
  }
}
