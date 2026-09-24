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
  final String
      ecoBadge; // e.g. Code 4 (LDPE) Recyclable, 100% Recyclable, +92 Eco Score
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
    description:
        'Precision gas transmission matrix tailored for high-respiration produce with anti-fog additive.',
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
    description:
        'Economical with high tear durability; shorter cold-chain freshness due to higher moisture venting.',
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
    description:
        'Superior crush resistance for bulk retail transit; higher cost index with 100% bottle-grade circularity.',
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
    description:
        'Plant-derived starch polymer; 100% industrial compostable with moderate oxygen barrier and gentle handling.',
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
    description:
        'Ultra-high barrier laminate shielding oily or moisture-sensitive snacks from oxygen degradation.',
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
    description:
        'Natural breathable fiber sack shielding tubers and bulbs from light while venting heat.',
    otrSpec: 'High Porosity',
    wvtrSpec: 'High Breathability',
    thickness: '120–180 gsm',
    costTier: 'Economical',
    costDelta: '-25% Cost',
    ecoBadge: 'Bio-Degradable',
    ecoDetail: '100% Biodegradable • Light Shield 99%',
    durability: 'Tough Fiber',
    idealFor: 'Potatoes, onions, root tubers, bulk dry grains',
    recyclabilityCode: 'Paper Recyclable (Code 22)',
    keyFeatures: [
      'Blocks light to prevent solanine greening',
      'Absorbs ambient humidity spikes',
      'Curbside recyclable and compostable',
    ],
  );

  static const PackagingMaterial highBarrierEvohPouch = PackagingMaterial(
    id: 'evoh_vacuum_pouch',
    name: 'High-Barrier EVOH Vacuum / MAP Pouch',
    polymerCode: 'PA/EVOH/PE',
    category: 'Multilayer Pouches',
    description:
        'Coextruded gas-tight barrier pouch optimized for vacuum packing and modified atmosphere gas flush for fresh proteins and dairy.',
    otrSpec: '< 2.0 cc/m²/day',
    wvtrSpec: '< 3.0 g/m²/day',
    thickness: '70–90 μm',
    costTier: 'Moderate-High',
    costDelta: 'MAP Engineered',
    ecoBadge: 'Food Waste Reduction',
    ecoDetail: 'Prevents Protein Oxidation & Drip Loss',
    durability: 'High Puncture & Seal Integrity',
    idealFor: 'Fresh meat, poultry, seafood, paneer, cured cheeses',
    recyclabilityCode: 'Mixed Multi-layer (Chemical Recycling)',
    keyFeatures: [
      'Exceptional oxygen barrier extends chilled protein shelf life 3x',
      'Vacuum-formable with hermetic hot-bar seal',
      'Retains moisture and prevents freezer burn',
    ],
  );

  static const PackagingMaterial asepticLiquidCarton = PackagingMaterial(
    id: 'aseptic_carton',
    name: 'Aseptic Multi-layer Liquid Carton',
    polymerCode: 'Paperboard/Alu/PE',
    category: 'Liquid Packaging',
    description:
        'Sterile composite carton providing 100% light and oxygen barrier for shelf-stable liquid dairy and juices without refrigeration.',
    otrSpec: '< 0.5 cc/m²/day',
    wvtrSpec: '< 0.5 g/m²/day',
    thickness: 'Cartonboard Composite',
    costTier: 'Economical-Moderate',
    costDelta: 'Ambient Distribution',
    ecoBadge: '70% FSC Paperboard',
    ecoDetail: 'FSC Certified • Curbside Recyclable',
    durability: 'Stackable Rigid Brick',
    idealFor: 'UHT milk, fruit juices, plant milks, liquid soups',
    recyclabilityCode: 'Carton Recycling (Code 84)',
    keyFeatures: [
      'Long ambient shelf life without chemical preservatives',
      'Complete light block prevents vitamin and flavor degradation',
      'Efficient transport cube-density',
    ],
  );

  static const PackagingMaterial glassJarLugCap = PackagingMaterial(
    id: 'glass_jar_hermetic',
    name: 'Glass Jar with Hermetic Lug Cap',
    polymerCode: 'Soda-Lime Glass / Steel',
    category: 'Rigid Containers',
    description:
        'Impermeable, chemically inert glass container providing total barrier against gases, moisture, and acid migration.',
    otrSpec: '0.0 cc/m²/day (Total Barrier)',
    wvtrSpec: '0.0 g/m²/day (Total Barrier)',
    thickness: '2.5–3.5 mm',
    costTier: 'Premium',
    costDelta: 'Inert Hermetic',
    ecoBadge: '100% Infinite Recyclable',
    ecoDetail: 'Endlessly Recyclable • Non-Toxic',
    durability: 'Rigid / Shatter Sensitive',
    idealFor: 'Jams, pickles, sauces, honey, mayonnaise',
    recyclabilityCode: 'Glass (Code 70-72)',
    keyFeatures: [
      'Zero flavor leaching and complete acid resistance',
      'Hot-fill and post-fill pasteurization ready',
      'Total oxygen, aroma, and moisture seal',
    ],
  );

  static const PackagingMaterial retortPouchLaminate = PackagingMaterial(
    id: 'retort_pouch',
    name: 'Retortable Foil Barrier Pouch',
    polymerCode: 'PET/Alu/PA/CPP',
    category: 'Multilayer Pouches',
    description:
        'High-temperature retortable pouch designed for pressure autoclave sterilization, enabling multi-year shelf stability for cooked meals.',
    otrSpec: '< 0.1 cc/m²/day',
    wvtrSpec: '< 0.1 g/m²/day',
    thickness: '90–120 μm',
    costTier: 'Moderate',
    costDelta: 'Autoclave Safe',
    ecoBadge: 'Lightweight Metal Substitute',
    ecoDetail: 'Low Transport Carbon • Shelf Stable',
    durability: 'Thermal & Puncture Tough',
    idealFor: 'Ready-to-eat curries, cooked biryani, wet gravies, pet food',
    recyclabilityCode: 'Specialized Foil Laminate Stream',
    keyFeatures: [
      'Withstands 121°C commercial retort sterilization',
      '1 to 2 year ambient shelf stability without refrigeration',
      'Pouch geometry heats 50% faster than traditional tin cans',
    ],
  );

  static const PackagingMaterial aromaBarrierCan = PackagingMaterial(
    id: 'aroma_tin_canister',
    name: 'Aroma-Proof Tinplate Canister',
    polymerCode: 'Tinplate Steel / Seamed End',
    category: 'Rigid Metal',
    description:
        'Hermetically seamed metal container providing absolute protection against aroma loss, moisture ingress, and light oxidation.',
    otrSpec: '0.0 cc/m²/day',
    wvtrSpec: '0.0 g/m²/day',
    thickness: '0.18–0.24 mm',
    costTier: 'Moderate-High',
    costDelta: 'Max Aroma Shield',
    ecoBadge: 'Steel Recyclable',
    ecoDetail: 'Magnetic Separation • Infinite Recyclability',
    durability: 'Crushproof',
    idealFor:
        'Ground spices, whole spices, premium tea, roasted coffee, confectionery',
    recyclabilityCode: 'Steel (Code 40)',
    keyFeatures: [
      'Total retention of volatile aromatic essential oils',
      'Zero UV/light transmittance prevents pigment fading',
      'Long-term moisture proof hermetic seal',
    ],
  );

  static const PackagingMaterial coldTolerantPeFilm = PackagingMaterial(
    id: 'deep_freeze_pe',
    name: 'Cold-Tolerant Coex Freezer Film',
    polymerCode: 'Metallocene LLDPE/EVA',
    category: 'Flexible Films',
    description:
        'Low-temperature impact modified polymer film engineered to withstand sub-zero flex-cracking and prevent freezer dehydration burn.',
    otrSpec: '300–600 cc/m²/day',
    wvtrSpec: '< 2.5 g/m²/day',
    thickness: '60–80 μm',
    costTier: 'Economical-Moderate',
    costDelta: 'Sub-Zero Safe',
    ecoBadge: 'Code 4 (LDPE) Recyclable',
    ecoDetail: 'Low Temp Impact Resistant • Recyclable',
    durability: 'Cold Crack Resistant to -35°C',
    idealFor: 'Frozen vegetables, frozen peas, frozen fries, frozen seafood',
    recyclabilityCode: 'RIC 4 (LDPE)',
    keyFeatures: [
      'Maintains elastic ductility down to -35°C without brittle cracking',
      'Tight moisture barrier stops ice sublimation (freezer burn)',
      'High dart drop impact resistance for bulk frozen transit',
    ],
  );

  /// All registered packaging materials in the system
  static const List<PackagingMaterial> allMaterials = [
    breathableFilm,
    macroPerforatedLdpe,
    rPetClamshell,
    compostablePla,
    metallizedBopp,
    kraftValveBag,
    highBarrierEvohPouch,
    asepticLiquidCarton,
    glassJarLugCap,
    retortPouchLaminate,
    aromaBarrierCan,
    coldTolerantPeFilm,
  ];
}
