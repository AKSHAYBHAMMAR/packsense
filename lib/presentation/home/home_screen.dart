import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/app_top_bar.dart';
import '../../core/widgets/packsense_button.dart';
import '../../data/models/food_properties.dart';
import '../../data/repositories/packaging_repository.dart';
import '../materials/all_materials_screen.dart';
import '../recommendation_flow/step1_food_selection_screen.dart';
import '../recommendation_flow/step4_recommendation_result_screen.dart';
import 'widgets/material_category_card.dart';
import 'widgets/quick_metrics_strip.dart';
import 'widgets/recent_analysis_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentNavIndex = 0;
  final PackagingRepository _repository = PackagingRepository();

  void _navigateToRecommendationFlow() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const Step1FoodSelectionScreen(),
      ),
    );
  }

  void _navigateToMaterials() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const AllMaterialsScreen(),
      ),
    );
  }

  void _openRecentDetail(RecentAnalysisItem item) {
    final properties =
        FoodProperties.estimateForCommodity(item.foodName).copyWith(
      isMeasured: item.isMeasured,
    );
    final result = _repository.analyzePackaging(properties);
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
      appBar: const AppTopBar(
        title: 'PackSense',
        subtitle: 'Smarter Packaging. Better Food.',
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Section Card
                _buildHeroCard(),
                const SizedBox(height: 20),

                // Quick Metrics Strip
                const QuickMetricsStrip(),
                const SizedBox(height: 24),

                // Explore Packaging Materials Section
                _buildExploreMaterialsSection(),
                const SizedBox(height: 24),

                // Recent Analysis Section
                _buildRecentAnalysisSection(),
                const SizedBox(height: 20),

                // Pro Tip Banner
                _buildProTipBanner(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.structuralBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bio-Barrier Engine Tag
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
                  'BIO-BARRIER ENGINE V2.4',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Hero Headline
          Text(
            'Find the right packaging for your food.',
            style: AppTypography.headlineLgMobile.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),

          // Subtitle
          Text(
            'PackSense analyzes food properties, storage conditions, shelf-life requirements, cost and sustainability preferences to recommend suitable packaging.',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),

          // CTA Buttons
          PackSenseButton(
            label: 'Get Packaging Recommendation',
            icon: Icons.auto_awesome,
            variant: ButtonVariant.darkContainer,
            onPressed: _navigateToRecommendationFlow,
          ),
          const SizedBox(height: 10),
          PackSenseButton.secondary(
            label: 'Explore Materials',
            icon: Icons.category,
            height: 48,
            onPressed: _navigateToMaterials,
          ),

          // Micro-Flow Diagram Strip
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0x1FE3EAE1), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildFlowStep('Home', isActive: true),
                const Icon(Icons.arrow_forward,
                    size: 14, color: AppColors.outlineVariant),
                _buildFlowStep('Food Details'),
                const Icon(Icons.arrow_forward,
                    size: 14, color: AppColors.outlineVariant),
                _buildFlowStep('Recommendation'),
                const Icon(Icons.arrow_forward,
                    size: 14, color: AppColors.outlineVariant),
                _buildFlowStep('Compare'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlowStep(String text, {bool isActive = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive
            ? AppColors.secondaryContainer.withOpacity(0.5)
            : AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isActive
              ? AppColors.secondary.withOpacity(0.3)
              : AppColors.structuralBorder,
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: AppTypography.labelSm.copyWith(
          color: isActive ? AppColors.secondary : AppColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildExploreMaterialsSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Explore Packaging Materials',
              style:
                  AppTypography.titleLg.copyWith(fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: _navigateToMaterials,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'All Materials',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        MaterialCategoryGrid(
          onSelect: (_) => _navigateToMaterials(),
        ),
      ],
    );
  }

  Widget _buildRecentAnalysisSection() {
    final recentItems = _repository.getRecentAnalyses();
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Analysis',
              style:
                  AppTypography.titleLg.copyWith(fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Showing all stored analyses.')),
                );
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'View All',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: recentItems.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = recentItems[index];
            return RecentAnalysisCard(
              item: item,
              onTap: () => _openRecentDetail(item),
            );
          },
        ),
      ],
    );
  }

  Widget _buildProTipBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.structuralBorder, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.tips_and_updates,
            color: AppColors.secondary,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: AppTypography.bodySm.copyWith(
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
                children: const [
                  TextSpan(
                    text: 'Pro Tip: ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                  TextSpan(
                    text:
                        'Combining moisture-absorbing pads with perforated PLA reduces condensation mould by 68%.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.structuralBorder, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 12,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(0, Icons.home, 'Home'),
              _buildNavItem(1, Icons.history, 'History'),
              _buildNavItem(2, Icons.person, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final isSelected = _currentNavIndex == index;
    return InkWell(
      onTap: () {
        setState(() => _currentNavIndex = index);
        if (index != 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$label tab clicked'),
              duration: const Duration(seconds: 1),
            ),
          );
        }
      },
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected
                  ? AppColors.onSecondaryContainer
                  : AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTypography.labelSm.copyWith(
                fontSize: 11,
                color: isSelected
                    ? AppColors.onSecondaryContainer
                    : AppColors.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
