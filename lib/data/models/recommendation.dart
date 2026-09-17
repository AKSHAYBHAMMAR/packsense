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
  final String matchTier; // e.g. "Strong Match"
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

  /// Generate recommendation result from food properties
  factory PackagingRecommendationResult.compute(FoodProperties properties) {
    final String name = properties.productName;
    final bool measured = properties.isMeasured;

    // Check specific food types or properties
    if (name.toLowerCase().contains('potato') && !name.toLowerCase().contains('chips')) {
      return PackagingRecommendationResult(
        foodName: properties.productName,
        foodEmoji: '🥔',
        storageCondition: 'Dark Room Temp (15°C)',
        targetShelfLife: '${properties.targetShelfLifeDays}d Target',
        primaryMatch: PackagingMaterial.kraftValveBag,
        matchTier: 'Strong Match',
        basedOnMeasuredData: measured,
        o2BarrierRating: 'Ventilated Safe',
        moistureControlRating: 'Vapor Absorbing',
        condensationRating: 'Zero Moisture Trap',
        rationaleSummary:
            'PackSense selected ventilated multiwall Kraft packaging to shield tubers from light-induced solanine while maintaining air exchange.',
        rationalePoints: const [
          RationalePoint(
            title: 'Product Compatibility',
            description: 'Optimal for root tubers requiring dark, dry, breathable containment.',
          ),
          RationalePoint(
            title: 'Light & Green Safeguard',
            description: '99.2% light opacity eliminates toxic solanine synthesis during retail presentation.',
          ),
          RationalePoint(
            title: 'Temperature & Shelf-Life',
            description: 'Prevents sprout acceleration and tuber moisture buildup over extended holding.',
          ),
          RationalePoint(
            title: 'Durability & Eco',
            description: 'High burst-strength paper and jute fibers, 100% curbside recyclable and biodegradable.',
          ),
        ],
        keySpecifications: const [
          KeySpecification(
            label: 'Light Shield',
            tooltip: 'Percentage of ambient UV/visible light blocked',
            value: '99.2',
            unit: '% Opacity',
            subtitle: 'Prevents Solanine',
            footerNote: 'Blocks greening wavelengths',
          ),
          KeySpecification(
            label: 'Breathability',
            tooltip: 'Air flow to vent metabolic heat',
            value: 'High',
            unit: 'Porosity',
            subtitle: 'Ventilated Flow',
            footerNote: 'Inhibits fungal condensation',
          ),
          KeySpecification(
            label: 'Durability',
            tooltip: 'Tensile burst index',
            value: '140',
            unit: 'gsm',
            subtitle: 'Tear Resistant Kraft',
            footerNote: 'Bulk transport safe',
          ),
          KeySpecification(
            label: 'Cost & Eco Tier',
            tooltip: 'Sustainability ranking and unit cost',
            value: 'Economical',
            unit: '',
            subtitle: 'Paper Code 22',
            footerNote: '100% Circular & Compostable',
          ),
        ],
        alternatives: const [
          PackagingMaterial.macroPerforatedLdpe,
          PackagingMaterial.compostablePla,
        ],
      );
    } else if (name.toLowerCase().contains('chips') ||
        properties.foodCategory.toLowerCase().contains('fried') ||
        properties.oilFatPercent > 15) {
      return PackagingRecommendationResult(
        foodName: properties.productName,
        foodEmoji: '🍟',
        storageCondition: 'Ambient Dry (22°C)',
        targetShelfLife: '${properties.targetShelfLifeDays}d Target',
        primaryMatch: PackagingMaterial.metallizedBopp,
        matchTier: 'Optimal Barrier',
        basedOnMeasuredData: measured,
        o2BarrierRating: 'Ultra-High Barrier',
        moistureControlRating: 'Hermetic Shield',
        condensationRating: 'N2 Flush Ready',
        rationaleSummary:
            'PackSense selected a metallized multilayer laminate to block oxygen and moisture, preventing rancidity in high-fat fried snacks.',
        rationalePoints: const [
          RationalePoint(
            title: 'Lipid Oxidation Prevention',
            description: 'OTR < 1 cc/m²/day prevents peroxide value increase and rancid odor formation.',
          ),
          RationalePoint(
            title: 'Moisture Vapor Shield',
            description: 'WVTR < 1 g/m²/day guarantees crisp texture retention over 90+ days.',
          ),
          RationalePoint(
            title: 'Gas Flushing Compatibility',
            description: 'Accommodates nitrogen headspace flushing to preserve potato chip integrity.',
          ),
          RationalePoint(
            title: 'Mechanical Protection',
            description: 'Cushioned pillow pouch geometry prevents brittle product breakage.',
          ),
        ],
        keySpecifications: const [
          KeySpecification(
            label: 'OTR Barrier',
            tooltip: 'Oxygen Transmission Rate',
            value: '< 1.0',
            unit: 'cc/m²/day OTR',
            subtitle: 'Total Lipid Protection',
            footerNote: 'Zero oxidative rancidity',
          ),
          KeySpecification(
            label: 'Moisture Barrier',
            tooltip: 'Water Vapor Transmission Rate',
            value: '< 0.8',
            unit: 'g/m²/day WVTR',
            subtitle: 'Crispness Locking',
            footerNote: 'Prevents sogginess',
          ),
          KeySpecification(
            label: 'Durability',
            tooltip: 'Barrier layer thickness',
            value: '65',
            unit: 'μm',
            subtitle: 'Puncture Resistant',
            footerNote: 'Laminated Metallized BOPP',
          ),
          KeySpecification(
            label: 'Cost & Eco Tier',
            tooltip: 'Material tier',
            value: 'Moderate',
            unit: '',
            subtitle: 'Long Shelf Life',
            footerNote: 'Protects high-value product',
          ),
        ],
        alternatives: const [
          PackagingMaterial.breathableFilm,
          PackagingMaterial.rPetClamshell,
        ],
      );
    }

    // Default Tomato / Produce match matching Stitch screen exactly
    return PackagingRecommendationResult(
      foodName: properties.productName.isEmpty ? 'Fresh Tomato' : properties.productName,
      foodEmoji: '🍅',
      storageCondition: 'Chilled (10°C)',
      targetShelfLife: '${properties.targetShelfLifeDays}d Target',
      primaryMatch: PackagingMaterial.breathableFilm,
      matchTier: 'Strong Match',
      basedOnMeasuredData: measured,
      o2BarrierRating: 'Optimized High',
      moistureControlRating: 'Vapor Safe',
      condensationRating: 'Anti-Fog',
      rationaleSummary:
          'PackSense selected this packaging because it supports required moisture transmission while enabling controlled gas exchange for ripe tomatoes.',
      rationalePoints: const [
        RationalePoint(
          title: 'Product Compatibility',
          description: 'Tailored for solid fresh produce (whole tomato) with active respiration.',
        ),
        RationalePoint(
          title: 'Moisture & Condensation',
          description: 'Balanced WVTR (15–25 g/m²/d) with anti-fog to eliminate internal surface condensation & mold bloom.',
        ),
        RationalePoint(
          title: 'Temperature & Shelf-Life',
          description: 'Optimized for cold storage (10°C) to reliably maintain 7-day target freshness.',
        ),
        RationalePoint(
          title: 'Durability, Cost & Eco',
          description: 'Flexible puncture-resistant gauge, moderate unit cost, and fully recyclable PE/PP stream.',
        ),
      ],
      keySpecifications: const [
        KeySpecification(
          label: 'OTR Barrier',
          tooltip: 'How easily oxygen passes through',
          value: '1,200–1,800',
          unit: 'cc/m²/day OTR',
          subtitle: 'Targeted produce respiration',
          footerNote: 'Gas exchange equilibrium',
        ),
        KeySpecification(
          label: 'Moisture & Temp',
          tooltip: 'Controls condensation and chill tolerance',
          value: '15–25',
          unit: 'WVTR',
          subtitle: '10°C Chilled Safe',
          footerNote: 'Anti-fog condensation control',
        ),
        KeySpecification(
          label: 'Durability',
          tooltip: 'Film tensile strength',
          value: '25–35',
          unit: 'μm',
          subtitle: 'High Puncture Resistance',
          footerNote: 'BOPP / LDPE Blend',
        ),
        KeySpecification(
          label: 'Cost & Eco Tier',
          tooltip: 'Unit cost and recyclability',
          value: 'Moderate',
          unit: '',
          subtitle: 'Code 4 (LDPE) Recyclable',
          footerNote: 'Balanced ROI',
        ),
      ],
      alternatives: const [
        PackagingMaterial.macroPerforatedLdpe,
        PackagingMaterial.rPetClamshell,
        PackagingMaterial.compostablePla,
      ],
    );
  }
}
