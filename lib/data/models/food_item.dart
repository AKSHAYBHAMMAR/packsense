/// Represents a food commodity profile
class FoodItem {
  final String id;
  final String name;
  final String? scientificName;
  final String category;
  final String emoji;
  final String characteristicBadge;
  final String description;

  const FoodItem({
    required this.id,
    required this.name,
    this.scientificName,
    required this.category,
    required this.emoji,
    required this.characteristicBadge,
    this.description = '',
  });

  /// Cataloged profiles matching Stitch Step 1 design
  static const List<FoodItem> standardCatalog = [
    FoodItem(
      id: 'tomato',
      name: 'Tomato',
      scientificName: 'Solanum lycopersicum',
      category: 'Fresh Produce',
      emoji: '🍅',
      characteristicBadge: 'High Respiration',
      description:
          'Climacteric fruit with active gas exchange, sensitive to moisture pooling.',
    ),
    FoodItem(
      id: 'apple',
      name: 'Apple',
      scientificName: 'Malus domestica',
      category: 'Fresh Produce',
      emoji: '🍎',
      characteristicBadge: 'Moderate',
      description:
          'Firm flesh with moderate respiration, needs controlled O2/CO2 balance.',
    ),
    FoodItem(
      id: 'mango',
      name: 'Mango',
      scientificName: 'Mangifera indica',
      category: 'Fresh Produce',
      emoji: '🥭',
      characteristicBadge: 'Tropical',
      description:
          'High ethylene production, prone to chilling injury below 10°C.',
    ),
    FoodItem(
      id: 'potato',
      name: 'Potato',
      scientificName: 'Solanum tuberosum',
      category: 'Tuber',
      emoji: '🥔',
      characteristicBadge: 'Moisture Sensitive',
      description:
          'Requires darkness to prevent greening (solanine) and balanced ventilation.',
    ),
    FoodItem(
      id: 'rice_grains',
      name: 'Rice & Grains',
      scientificName: 'Oryza sativa',
      category: 'Dry Food',
      emoji: '🌾',
      characteristicBadge: 'Low Respiration',
      description:
          'Very dry product needing moisture vapor shielding and insect barrier.',
    ),
    FoodItem(
      id: 'biscuits',
      name: 'Biscuits',
      scientificName: 'Baked Confectionery',
      category: 'Dry Baked',
      emoji: '🍪',
      characteristicBadge: 'High WVTR Barrier',
      description:
          'Crisp texture requiring stringent moisture protection to prevent sogginess.',
    ),
    FoodItem(
      id: 'chips_snacks',
      name: 'Chips & Snacks',
      scientificName: 'Fried Savory',
      category: 'Fried Dry',
      emoji: '🍟',
      characteristicBadge: 'O2 Sensitive',
      description:
          'High oil/fat content prone to oxidation, needs nitrogen-flushed pouch.',
    ),
    FoodItem(
      id: 'spices',
      name: 'Spices',
      scientificName: 'Aromatics',
      category: 'Aromatic',
      emoji: '🌿',
      characteristicBadge: 'Volatile Flavor Loss',
      description:
          'Rich in essential oils, requires high aroma retention barrier.',
    ),
  ];
}
