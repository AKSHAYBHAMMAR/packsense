import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/bottom_action_bar.dart';
import '../../core/widgets/packsense_button.dart';
import '../../core/widgets/segmented_progress.dart';
import '../../data/models/commodity.dart';
import '../../data/models/food_item.dart';
import '../../data/repositories/commodity_repository.dart';
import 'step2_data_choice_screen.dart';

class Step1FoodSelectionScreen extends StatefulWidget {
  const Step1FoodSelectionScreen({super.key});

  @override
  State<Step1FoodSelectionScreen> createState() =>
      _Step1FoodSelectionScreenState();
}

class _Step1FoodSelectionScreenState extends State<Step1FoodSelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  final CommodityRepository _commodityRepository = CommodityRepository();

  Timer? _debounceTimer;
  bool _isLoading = false;
  String? _errorMessage;

  List<Commodity> _allFilteredCommodities = [];
  List<Commodity> _displayedCommodities = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';

  int _visibleCount = 100;
  static const int _pageSize = 100;

  Commodity? _selectedCommodity;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _searchController.addListener(_onSearchInputChanged);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.removeListener(_onSearchInputChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => _isLoading = true);
    try {
      final categories = await _commodityRepository.getCategories();
      final all = await _commodityRepository.getAllCommodities();
      setState(() {
        _categories = categories;
        _allFilteredCommodities = all;
        _visibleCount = _pageSize;
        _displayedCommodities = all.take(_visibleCount).toList();
        if (_displayedCommodities.isNotEmpty) {
          _selectedCommodity = _displayedCommodities.first;
        }
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to load food commodities. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _onSearchInputChanged() {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      _executeSearch();
    });
  }

  void _onCategorySelected(String category) {
    if (_selectedCategory == category) return;
    setState(() {
      _selectedCategory = category;
      _visibleCount = _pageSize;
    });
    _executeSearch();
  }

  Future<void> _executeSearch() async {
    final query = _searchController.text.trim();

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final results = await _commodityRepository.searchCommodities(
        query,
        category: _selectedCategory,
      );

      setState(() {
        _allFilteredCommodities = results;
        _displayedCommodities = results.take(_visibleCount).toList();
        _isLoading = false;
        if (results.isNotEmpty &&
            (_selectedCommodity == null ||
                !_isCommodityInList(_selectedCommodity!, results))) {
          _selectedCommodity = results.first;
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Unable to load food commodities. Please try again.';
        _isLoading = false;
      });
    }
  }

  void _onLoadMore() {
    setState(() {
      _visibleCount += _pageSize;
      _displayedCommodities =
          _allFilteredCommodities.take(_visibleCount).toList();
    });
  }

  bool _isCommodityInList(Commodity target, List<Commodity> list) {
    return list.any((c) => c.id == target.id);
  }

  void _onSelectCommodity(Commodity commodity) {
    setState(() => _selectedCommodity = commodity);
  }

  void _onContinue() {
    if (_selectedCommodity == null) return;
    final FoodItem foodItem = _selectedCommodity!.toFoodItem();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Step2DataChoiceScreen(selectedFood: foodItem),
      ),
    );
  }

  String _getSectionTitle() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      return 'Search Results';
    }
    if (_selectedCategory != 'All') {
      return '$_selectedCategory Products';
    }
    return 'All Food Products';
  }

  String _getSectionBadge() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      return '${_allFilteredCommodities.length} Found';
    }
    if (_selectedCategory != 'All') {
      return '${_allFilteredCommodities.length} Products';
    }
    return 'Showing ${_displayedCommodities.length} of ${_allFilteredCommodities.length}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const RecommendationFlowHeader(currentStep: 1),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 880),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Badge Tag
                      _buildHeaderBadge(),
                      const SizedBox(height: 12),

                      // Headline
                      Text(
                        'Food Commodities',
                        style: AppTypography.headlineLgMobile.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Subtitle
                      Text(
                        'Select from 255+ validated food commodities or search below to determine technical packaging requirements.',
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Primary Search Field
                      _buildSearchField(),
                      const SizedBox(height: 14),

                      // Category Filter Chips
                      if (_categories.isNotEmpty) _buildCategoryFilterBar(),
                      const SizedBox(height: 20),

                      // Main Content Body based on state
                      if (_isLoading)
                        _buildLoadingState()
                      else if (_errorMessage != null)
                        _buildErrorState()
                      else if (_displayedCommodities.isEmpty)
                        _buildNoResultsState()
                      else
                        _buildCatalogGridSection(),

                      const SizedBox(height: 24),

                      // Epistemic Grounding Note
                      _buildEpistemicBanner(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: StickyBottomActionBar(
        child: PackSenseButton(
          label: _selectedCommodity != null
              ? 'Continue with ${_selectedCommodity!.name}'
              : 'Select a Commodity',
          icon: Icons.arrow_forward,
          variant: ButtonVariant.primary,
          onPressed: _selectedCommodity != null ? _onContinue : null,
        ),
      ),
    );
  }

  Widget _buildHeaderBadge() {
    return Container(
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
            'COMMODITY INTAKE • 255+ PROFILES',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.secondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
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
          hintText: 'Search food product (e.g. Mango, Rice, Chips, Paneer...)',
          hintStyle: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7)),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.secondary,
            size: 22,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear,
                      size: 18, color: AppColors.onSurfaceVariant),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildCategoryFilterBar() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = cat == _selectedCategory;
          return GestureDetector(
            onTap: () => _onCategorySelected(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primaryContainer
                    : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primaryContainer
                      : AppColors.structuralBorder,
                  width: 1,
                ),
              ),
              child: Text(
                cat,
                style: AppTypography.labelSm.copyWith(
                  color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCatalogGridSection() {
    final hasMore =
        _displayedCommodities.length < _allFilteredCommodities.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header Bar
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _getSectionTitle(),
              style: AppTypography.titleMd.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _getSectionBadge(),
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Responsive Grid
        LayoutBuilder(
          builder: (context, constraints) {
            int crossAxisCount = 2;
            if (constraints.maxWidth >= 760) {
              crossAxisCount = 4;
            } else if (constraints.maxWidth >= 520) {
              crossAxisCount = 3;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _displayedCommodities.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.94,
              ),
              itemBuilder: (context, index) {
                final item = _displayedCommodities[index];
                final isSelected = _selectedCommodity != null &&
                    item.id == _selectedCommodity!.id;
                return _buildCommodityCard(item, isSelected);
              },
            );
          },
        ),

        // Load More button if not all matching items are shown
        if (hasMore) ...[
          const SizedBox(height: 18),
          Center(
            child: OutlinedButton.icon(
              onPressed: _onLoadMore,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(
                  color: AppColors.structuralBorder,
                  width: 1.5,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: AppColors.surfaceContainerLowest,
              ),
              icon: const Icon(Icons.expand_more, size: 20),
              label: Text(
                'Load More Commodities (${_allFilteredCommodities.length - _displayedCommodities.length} More)',
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCommodityCard(Commodity item, bool isSelected) {
    return GestureDetector(
      onTap: () => _onSelectCommodity(item),
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
              color: isSelected
                  ? AppColors.activeCardShadow
                  : AppColors.cardShadow,
              blurRadius: isSelected ? 12 : 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Stack(
          children: [
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
                        fontSize: 13.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.category,
                      style: AppTypography.labelSm.copyWith(
                        color: isSelected
                            ? AppColors.secondary
                            : AppColors.onSurfaceVariant,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
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
                              color: isSelected
                                  ? AppColors.secondary
                                  : AppColors.outlineVariant,
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

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            const SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Searching commodities...',
              style: AppTypography.bodyMd.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Container(
      padding: const EdgeInsets.all(28),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.structuralBorder, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerLow,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppColors.onSurfaceVariant,
              size: 28,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Commodity not currently available',
            style: AppTypography.titleMd.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            "We're expanding the PackSense knowledge base with over 255+ food profiles. Try searching broader terms (e.g. 'fruit', 'rice', 'milk', 'chilli') or check spelling.",
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _selectedCategory = 'All';
                _visibleCount = _pageSize;
              });
              _executeSearch();
            },
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Reset search & show all food products'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.errorContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.error.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Text(
            _errorMessage ??
                'Unable to load food commodities. Please try again.',
            style: AppTypography.bodyMd.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          PackSenseButton.secondary(
            label: 'Retry',
            icon: Icons.refresh,
            height: 38,
            onPressed: _loadInitialData,
          ),
        ],
      ),
    );
  }

  Widget _buildEpistemicBanner() {
    return Container(
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
                  'Selecting any food item loads tailored biological parameters (respiration, WVTR, OTR, lipid sensitivity, and shelf-life requirements) to compute packaging recommendations.',
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
    );
  }
}
