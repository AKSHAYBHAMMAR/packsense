import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/bottom_action_bar.dart';
import '../../core/widgets/epistemic_tag.dart';
import '../../core/widgets/packsense_button.dart';
import '../../core/widgets/segmented_progress.dart';
import '../../data/models/food_item.dart';
import '../../data/models/food_properties.dart';
import '../../data/repositories/packaging_repository.dart';
import 'step4_recommendation_result_screen.dart';

class Step3FoodDetailsScreen extends StatefulWidget {
  final FoodItem foodItem;
  final FoodProperties initialProperties;

  const Step3FoodDetailsScreen({
    super.key,
    required this.foodItem,
    required this.initialProperties,
  });

  @override
  State<Step3FoodDetailsScreen> createState() => _Step3FoodDetailsScreenState();
}

class _Step3FoodDetailsScreenState extends State<Step3FoodDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _categoryController;
  late TextEditingController _typeController;
  late TextEditingController _moistureController;
  late TextEditingController _phController;
  late TextEditingController _oilFatController;
  late TextEditingController _shelfLifeController;

  late PhysicalState _physicalState;
  late StorageTemperature _storageTemperature;
  late TransportationDistance _transportationDistance;
  late FragilityLevel _fragility;
  late SustainabilityPreference _sustainabilityPreference;
  late BudgetTier _budgetPreference;

  final PackagingRepository _repository = PackagingRepository();

  @override
  void initState() {
    super.initState();
    final p = widget.initialProperties;
    _nameController = TextEditingController(text: p.productName);
    _categoryController = TextEditingController(text: p.foodCategory);
    _typeController = TextEditingController(text: p.foodType);
    _moistureController =
        TextEditingController(text: p.moisturePercent.toStringAsFixed(1));
    _phController = TextEditingController(text: p.ph.toStringAsFixed(1));
    _oilFatController =
        TextEditingController(text: p.oilFatPercent.toStringAsFixed(1));
    _shelfLifeController =
        TextEditingController(text: p.targetShelfLifeDays.toString());

    _physicalState = p.physicalState;
    _storageTemperature = p.storageTemperature;
    _transportationDistance = p.transportationDistance;
    _fragility = p.fragility;
    _sustainabilityPreference = p.sustainabilityPreference;
    _budgetPreference = p.budgetPreference;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _typeController.dispose();
    _moistureController.dispose();
    _phController.dispose();
    _oilFatController.dispose();
    _shelfLifeController.dispose();
    super.dispose();
  }

  void _onAnalyze() {
    if (!_formKey.currentState!.validate()) return;

    final updatedProperties = widget.initialProperties.copyWith(
      productName: _nameController.text.trim(),
      foodCategory: _categoryController.text.trim(),
      foodType: _typeController.text.trim(),
      physicalState: _physicalState,
      moisturePercent: double.tryParse(_moistureController.text.trim()) ?? 80.0,
      ph: double.tryParse(_phController.text.trim()) ?? 4.5,
      oilFatPercent: double.tryParse(_oilFatController.text.trim()) ?? 1.0,
      storageTemperature: _storageTemperature,
      targetShelfLifeDays: int.tryParse(_shelfLifeController.text.trim()) ?? 7,
      transportationDistance: _transportationDistance,
      fragility: _fragility,
      sustainabilityPreference: _sustainabilityPreference,
      budgetPreference: _budgetPreference,
      isMeasured: true,
    );

    final result = _repository.analyzePackaging(updatedProperties);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Step4RecommendationResultScreen(recommendation: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const RecommendationFlowHeader(currentStep: 3),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Food Context Pill
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLowest,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                              color: AppColors.structuralBorder, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(widget.foodItem.emoji,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 8),
                            Text(
                              widget.foodItem.name,
                              style: AppTypography.titleMd.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const EpistemicTag.measured(),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Headline
                  Text(
                    'Enter Food Specifications',
                    style: AppTypography.headlineLgMobile.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Provide chemical, physical, and logistics parameters to calculate packaging barrier requirements.',
                    style: AppTypography.bodyMd
                        .copyWith(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 24),

                  // Section 1: Food Information
                  _buildSectionHeader(
                      '1. Food Information', Icons.restaurant_menu),
                  const SizedBox(height: 12),
                  _buildTextInput(
                    controller: _nameController,
                    label: 'Product Name',
                    hint: 'e.g. Cherry Tomato on Vine',
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextInput(
                          controller: _categoryController,
                          label: 'Category',
                          hint: 'e.g. Fresh Produce',
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextInput(
                          controller: _typeController,
                          label: 'Food Type',
                          hint: 'e.g. Solanum Fruit',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Section 2: Physical & Chemical Properties
                  _buildSectionHeader(
                      '2. Physical & Chemical Properties', Icons.science),
                  const SizedBox(height: 12),
                  _buildPhysicalStateSelector(),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextInput(
                          controller: _moistureController,
                          label: 'Moisture (%)',
                          hint: '85.0',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextInput(
                          controller: _phController,
                          label: 'Acidity (pH)',
                          hint: '4.4',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextInput(
                          controller: _oilFatController,
                          label: 'Fat/Oil (%)',
                          hint: '0.2',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Section 3: Storage & Shelf-Life Requirements
                  _buildSectionHeader(
                      '3. Storage & Shelf-Life', Icons.thermostat),
                  const SizedBox(height: 12),
                  _buildStorageTempSelector(),
                  const SizedBox(height: 14),
                  _buildTextInput(
                    controller: _shelfLifeController,
                    label: 'Required Shelf Life (Days)',
                    hint: '7',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),

                  // Section 4: Transportation & Fragility
                  _buildSectionHeader(
                      '4. Logistics & Fragility', Icons.local_shipping),
                  const SizedBox(height: 12),
                  _buildTransportDistanceSelector(),
                  const SizedBox(height: 14),
                  _buildFragilitySelector(),
                  const SizedBox(height: 24),

                  // Section 5: Economic & Sustainability Preferences
                  _buildSectionHeader(
                      '5. Economic & Eco Preferences', Icons.eco),
                  const SizedBox(height: 12),
                  _buildSustainabilitySelector(),
                  const SizedBox(height: 14),
                  _buildBudgetSelector(),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: StickyBottomActionBar(
        child: PackSenseButton(
          label: 'Analyze Packaging Match',
          icon: Icons.auto_awesome,
          variant: ButtonVariant.darkContainer,
          onPressed: _onAnalyze,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppColors.secondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.titleMd.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Required';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.surfaceContainerLowest,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.structuralBorder, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.structuralBorder, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: AppColors.secondary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhysicalStateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Physical State',
          style: AppTypography.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: PhysicalState.values.map((state) {
            final isSelected = _physicalState == state;
            final label = state.name[0].toUpperCase() + state.name.substring(1);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) setState(() => _physicalState = state);
                  },
                  labelStyle: AppTypography.labelSm.copyWith(
                    color:
                        isSelected ? Colors.white : AppColors.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  selectedColor: AppColors.primaryContainer,
                  backgroundColor: AppColors.surfaceContainerLowest,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primaryContainer
                          : AppColors.structuralBorder,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStorageTempSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Storage Temperature',
          style: AppTypography.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildChipOption(
              label: 'Room Temp (20°C)',
              isSelected: _storageTemperature == StorageTemperature.roomTemp,
              onTap: () => setState(
                  () => _storageTemperature = StorageTemperature.roomTemp),
            ),
            const SizedBox(width: 8),
            _buildChipOption(
              label: 'Refrigerated (4-10°C)',
              isSelected:
                  _storageTemperature == StorageTemperature.refrigerated,
              onTap: () => setState(
                  () => _storageTemperature = StorageTemperature.refrigerated),
            ),
            const SizedBox(width: 8),
            _buildChipOption(
              label: 'Frozen (-18°C)',
              isSelected: _storageTemperature == StorageTemperature.frozen,
              onTap: () => setState(
                  () => _storageTemperature = StorageTemperature.frozen),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransportDistanceSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transportation Distance',
          style: AppTypography.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildChipOption(
              label: 'Local (< 50 km)',
              isSelected:
                  _transportationDistance == TransportationDistance.local,
              onTap: () => setState(
                  () => _transportationDistance = TransportationDistance.local),
            ),
            const SizedBox(width: 8),
            _buildChipOption(
              label: 'Regional (50-500 km)',
              isSelected:
                  _transportationDistance == TransportationDistance.regional,
              onTap: () => setState(() =>
                  _transportationDistance = TransportationDistance.regional),
            ),
            const SizedBox(width: 8),
            _buildChipOption(
              label: 'Long Distance',
              isSelected: _transportationDistance ==
                  TransportationDistance.longDistance,
              onTap: () => setState(() => _transportationDistance =
                  TransportationDistance.longDistance),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFragilitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Product Fragility',
          style: AppTypography.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: FragilityLevel.values.map((fragility) {
            final isSelected = _fragility == fragility;
            final label =
                fragility.name[0].toUpperCase() + fragility.name.substring(1);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildChipOption(
                  label: label,
                  isSelected: isSelected,
                  onTap: () => setState(() => _fragility = fragility),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSustainabilitySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sustainability Goal',
          style: AppTypography.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildChipOption(
              label: 'Standard',
              isSelected: _sustainabilityPreference ==
                  SustainabilityPreference.standard,
              onTap: () => setState(() => _sustainabilityPreference =
                  SustainabilityPreference.standard),
            ),
            const SizedBox(width: 8),
            _buildChipOption(
              label: '100% Recyclable',
              isSelected: _sustainabilityPreference ==
                  SustainabilityPreference.recyclable,
              onTap: () => setState(() => _sustainabilityPreference =
                  SustainabilityPreference.recyclable),
            ),
            const SizedBox(width: 8),
            _buildChipOption(
              label: 'Bio / Compostable',
              isSelected: _sustainabilityPreference ==
                  SustainabilityPreference.compostable,
              onTap: () => setState(() => _sustainabilityPreference =
                  SustainabilityPreference.compostable),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBudgetSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget / Unit Cost Tier',
          style: AppTypography.labelSm.copyWith(
            color: AppColors.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: BudgetTier.values.map((budget) {
            final isSelected = _budgetPreference == budget;
            final label =
                budget.name[0].toUpperCase() + budget.name.substring(1);
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildChipOption(
                  label: label,
                  isSelected: isSelected,
                  onTap: () => setState(() => _budgetPreference = budget),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildChipOption({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primaryContainer
              : AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: isSelected
                ? AppColors.primaryContainer
                : AppColors.structuralBorder,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
