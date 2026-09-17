import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/bottom_action_bar.dart';
import '../../core/widgets/packsense_button.dart';
import '../../core/widgets/segmented_progress.dart';
import '../../data/models/food_item.dart';
import 'step2_data_choice_screen.dart';

class Step1FoodSelectionScreen extends StatefulWidget {
  const Step1FoodSelectionScreen({super.key});

  @override
  State<Step1FoodSelectionScreen> createState() => _Step1FoodSelectionScreenState();
}

class _Step1FoodSelectionScreenState extends State<Step1FoodSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<FoodItem> _filteredItems = FoodItem.standardCatalog;
  FoodItem _selectedItem = FoodItem.standardCatalog.first; // Defaults to Tomato

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim().toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredItems = FoodItem.standardCatalog;
      } else {
        _filteredItems = FoodItem.standardCatalog
            .where((item) =>
                item.name.toLowerCase().contains(query) ||
                item.category.toLowerCase().contains(query) ||
                (item.scientificName?.toLowerCase().contains(query) ?? false))
            .toList();
      }
    });
  }

  void _onContinue() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Step2DataChoiceScreen(selectedFood: _selectedItem),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const RecommendationFlowHeader(currentStep: 1),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Commodity Intake Tag
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.structuralBorder, width: 1),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'COMMODITY INTAKE',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Headline
                Text(
                  'What are you packaging?',
                  style: AppTypography.headlineLgMobile.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),

                // Subtitle
                Text(
                  'Choose your food commodity to determine packaging requirements.',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 20),

                // Search Input Field
                Container(
                  height: 54,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.structuralBorder, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: AppTypography.bodyMd.copyWith(color: AppColors.onSurface),
                    decoration: InputDecoration(
                      hintText: 'Search food (e.g. Tomato, Apple, Rice...)',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: AppColors.onSurfaceVariant,
                        size: 22,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18, color: AppColors.onSurfaceVariant),
                              onPressed: () {
                                _searchController.clear();
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Section Label
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Standard Commodities',
                      style: AppTypography.titleMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '${_filteredItems.length} Cataloged Profiles',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Bento-style 2-Column Food Card Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredItems.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (context, index) {
                    final item = _filteredItems[index];
                    final isSelected = item.id == _selectedItem.id;
                    return _buildFoodCommodityCard(item, isSelected);
                  },
                ),
                const SizedBox(height: 20),

                // Epistemic Grounding Note
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.structuralBorder, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.biotech,
                        color: AppColors.secondary,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'EMPIRICAL GROUNDING ACTIVE',
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Selecting fresh produce activates dynamic respiration (RO2/RCO2) and equilibrium modified atmosphere packaging (EMAP) calculations.',
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: StickyBottomActionBar(
        child: PackSenseButton(
          label: 'Continue with ${_selectedItem.name}',
          icon: Icons.arrow_forward,
          variant: ButtonVariant.primary,
          onPressed: _onContinue,
        ),
      ),
    );
  }

  Widget _buildFoodCommodityCard(FoodItem item, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() => _selectedItem = item);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primaryContainer, width: 2)
              : Border.all(color: AppColors.structuralBorder, width: 1),
          boxShadow: [
            BoxShadow(
              color: isSelected ? AppColors.activeCardShadow : AppColors.cardShadow,
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
            // Selected Check Indicator
            if (isSelected)
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Food Emoji Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      item.emoji,
                      style: const TextStyle(fontSize: 26),
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: AppTypography.titleMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.category,
                      style: AppTypography.labelSm.copyWith(
                        color: isSelected ? AppColors.secondary : AppColors.onSurfaceVariant,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.only(top: 6),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0x1FE3EAE1), width: 1),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.secondary : AppColors.outlineVariant,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              item.characteristicBadge,
                              style: AppTypography.bodySm.copyWith(
                                fontSize: 10,
                                color: AppColors.onSurfaceVariant,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
