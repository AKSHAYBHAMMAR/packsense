/// Represents a packaging material and its technical barrier specifications
class PackagingMaterial {
  final String id;
  final String name;
  final String polymerCode;
  final String category;
  final String description;
  final String otrSpec; // Oxygen Transmission Rate
  final String wvtrSpec; // Water Vapor Transmission Rate
  final String thickness; // e.g. 25–35 μm
  final String costTier; // e.g. Economical, Moderate, Premium
  final String costDelta; // e.g. -18% Cost, +22% Cost
  final String ecoBadge; // e.g. Code 4 (LDPE) Recyclable, 100% Recyclable, +92 Eco Score
  final String ecoDetail; // e.g. EN 13432 Certified
  final String durability; // High, Maximum, Moderate
  final String idealFor;
  final String recyclabilityCode;
  final List<String> keyFeatures;

  const PackagingMaterial({
    required this.id,
    required this.name,
    required this.polymerCode,
    required this.category,
    required this.description,
    required this.otrSpec,
    required this.wvtrSpec,
    required this.thickness,
    required this.costTier,
    this.costDelta = 'Baseline',
    required this.ecoBadge,
    required this.ecoDetail,
    required this.durability,
    required this.idealFor,
    required this.recyclabilityCode,
    this.keyFeatures = const [],
  });

  /// Predefined materials matching Stitch catalog
  static const PackagingMaterial breathableFilm = PackagingMaterial(
    id: 'bopp_ldpe_perforated',
    name: 'Breathable / Micro-Perforated Film',
    polymerCode: 'BOPP/LDPE',
    category: 'Flexible Films',
    description: 'Precision gas transmission matrix tailored for high-respiration produce with anti-fog additive.',
    otrSpec: '1,200–1,800 cc/m²/day',
    wvtrSpec: '15–25 g/m²/day',
    thickness: '25–35 μm',
    costTier: 'Moderate',
    costDelta: 'Optimal Fit',
    ecoBadge: 'Code 4 (LDPE) Recyclable',
    ecoDetail: 'High Puncture Resistance • Balanced ROI',
    durability: 'High Puncture Resistance',
    idealFor: 'Fresh tomatoes, berries, bell peppers',
    recyclabilityCode: 'RIC 4 (LDPE)',
    keyFeatures: [
      'Balanced O2/CO2 gas permeation prevents anaerobic decay',
      'Anti-fog coating prevents condensation water droplets',
      'Chilled safe at 4°C to 12°C',
      'Puncture-resistant for retail bulk transport',
    ],
  );

  static const PackagingMaterial macroPerforatedLdpe = PackagingMaterial(
    id: 'macro_ldpe',
    name: 'Macro-perforated LDPE',
    polymerCode: 'LDPE',
    category: 'Flexible Films',
    description: 'Economical with high tear durability; shorter cold-chain freshness due to higher moisture venting.',
    otrSpec: '3,000–5,000 cc/m²/day',
    wvtrSpec: '40–60 g/m²/day',
    thickness: '40–50 μm',
    costTier: 'Economical',
    costDelta: '-18% Cost',
    ecoBadge: 'Cost-Effective',
    ecoDetail: 'High Durability • Standard Eco',
    durability: 'High Durability',
    idealFor: 'Carrots, citrus, robust tubers',
    recyclabilityCode: 'RIC 4 (LDPE)',
    keyFeatures: [
      'Highest mechanical tear strength',
      'Lowest unit cost index',
      'Rapid air circulation',
    ],
  );

  static const PackagingMaterial rPetClamshell = PackagingMaterial(
    id: 'rpet_clamshell',
    name: 'Rigid Recycled PET (rPET) Clamshell',
    polymerCode: 'rPET',
    category: 'Rigid Containers',
    description: 'Superior crush resistance for bulk retail transit; higher cost index with 100% bottle-grade circularity.',
    otrSpec: '50–100 cc/m²/day',
    wvtrSpec: '2–5 g/m²/day',
    thickness: '250–350 μm',
    costTier: 'Premium',
    costDelta: '+22% Cost',
    ecoBadge: 'Max Protection',
    ecoDetail: 'Maximum Durability • 100% Recyclable',
    durability: 'Maximum Durability',
    idealFor: 'Delicate berries, cherry tomatoes, cut fruits',
    recyclabilityCode: 'RIC 1 (PET)',
    keyFeatures: [
      'Zero stack-crush damage during transit',
      'Crystal clear optical clarity for retail appeal',
      '100% post-consumer recycled content',
    ],
  );

  static const PackagingMaterial compostablePla = PackagingMaterial(
    id: 'pla_compostable',
    name: 'Biodegradable PLA / Compostable Film',
    polymerCode: 'PLA/PBAT',
    category: 'Bio / Compostable',
    description: 'Plant-derived starch polymer; 100% industrial compostable with moderate oxygen barrier and gentle handling.',
    otrSpec: '600–900 cc/m²/day',
    wvtrSpec: '80–120 g/m²/day',
    thickness: '20–30 μm',
    costTier: 'Moderate-High',
    costDelta: '+92 Eco Score',
    ecoBadge: 'Eco Choice',
    ecoDetail: 'EN 13432 Certified • Moderate Durability',
    durability: 'Moderate Durability',
    idealFor: 'Organic produce, specialty mushrooms, micro-greens',
    recyclabilityCode: 'Industrial Compostable (EN 13432)',
    keyFeatures: [
      'Zero petroleum fossil inputs',
      'Decomposes within 90 days in composting facility',
      'Naturally breathable for fresh produce',
    ],
  );

  static const PackagingMaterial metallizedBopp = PackagingMaterial(
    id: 'metallized_bopp',
    name: 'Metallized Barrier Pouch',
    polymerCode: 'BOPP/Met-PET/PE',
    category: 'Multilayer Pouches',
    description: 'Ultra-high barrier laminate shielding oily or moisture-sensitive snacks from oxygen degradation.',
    otrSpec: '< 1.0 cc/m²/day',
    wvtrSpec: '< 1.0 g/m²/day',
    thickness: '60–80 μm',
    costTier: 'Moderate',
    costDelta: 'High Barrier',
    ecoBadge: 'Extended Shelf Life',
    ecoDetail: 'Oxygen Shield • Light Proof',
    durability: 'High Durability',
    idealFor: 'Potato chips, fried snacks, roasted nuts',
    recyclabilityCode: 'Mixed Plastic (Specialized stream)',
    keyFeatures: [
      'Near-total oxygen and moisture barrier',
      'Protects sensitive oils and crispness',
      'Gas flushing (nitrogen) compatible',
    ],
  );

  static const PackagingMaterial kraftValveBag = PackagingMaterial(
    id: 'kraft_valve_bag',
    name: 'Ventilated Multiwall Kraft Bag',
    polymerCode: 'Kraft/Jute',
    category: 'Paper & Fiber',
    description: 'Natural breathable fiber sack shielding tubers and bulbs from light while venting heat.',
    otrSpec: 'High Porosity',
    wvtrSpec: 'High Breathability',
    thickness: '120–180 gsm',
    costTier: 'Economical',
    costDelta: '-25% Cost',
    ecoBadge: 'Bio-Degradable',
    ecoDetail: '100% Biodegradable • Light Shield 99%',
    durability: 'Tough Fiber',
    idealFor: 'Potatoes, onions, root tubers',
    recyclabilityCode: 'Paper Recyclable (Code 22)',
    keyFeatures: [
      'Blocks light to prevent solanine greening',
      'Absorbs ambient humidity spikes',
      'Curbside recyclable and compostable',
    ],
  );
}
