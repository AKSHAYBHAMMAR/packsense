import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/bottom_action_bar.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/epistemic_tag.dart';
import '../../core/widgets/packsense_button.dart';
import '../../data/models/packaging_material.dart';
import '../../data/models/recommendation.dart';
import '../../data/models/food_properties.dart';
import '../../data/repositories/history_repository.dart';
import '../../data/repositories/packaging_repository.dart';
import '../materials/material_details_screen.dart';

class Step4RecommendationResultScreen extends StatefulWidget {
  final PackagingRecommendationResult recommendation;
  final FoodProperties? foodProperties;

  const Step4RecommendationResultScreen({
    super.key,
    required this.recommendation,
    this.foodProperties,
  });

  @override
  State<Step4RecommendationResultScreen> createState() =>
      _Step4RecommendationResultScreenState();
}

class _Step4RecommendationResultScreenState
    extends State<Step4RecommendationResultScreen> {
  final PackagingRepository _repository = PackagingRepository();
  final HistoryRepository _historyRepository = HistoryRepository();
  bool _isSaved = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Persist complete analysis to Supabase after successful recommendation display
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _persistRecommendationAutomatically();
    });
  }

  Future<void> _persistRecommendationAutomatically() async {
    try {
      await _historyRepository.saveAnalysis(
        recommendation: widget.recommendation,
        properties: widget.foodProperties,
      );
      if (mounted) {
        setState(() => _isSaved = true);
      }
    } catch (e, st) {
      debugPrint('[PackSense] Auto-persist to Supabase logged: $e\n$st');
      // Do NOT break the recommendation result if save fails.
    }
  }

  Future<void> _saveToHistory() async {
    setState(() => _isSaving = true);
    final rec = widget.recommendation;

    try {
      await _historyRepository.saveAnalysis(
        recommendation: rec,
        properties: widget.foodProperties,
      );

      // Also add to packaging repository session list for backwards-compatibility
      _repository.addAnalysis(
        RecentAnalysisItem(
          id: 'analysis_${DateTime.now().millisecondsSinceEpoch}',
          foodName: rec.foodName,
          foodEmoji: rec.foodEmoji,
          timeAgo: 'Just now',
          materialName: rec.primaryMatch.name,
          specsSummary:
              'OTR: ${rec.primaryMatch.otrSpec} • Shelf-life: ${rec.targetShelfLife}',
          isMeasured: rec.basedOnMeasuredData,
        ),
      );

      if (mounted) {
        setState(() {
          _isSaved = true;
          _isSaving = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primaryContainer,
            content: Text(
              'Recommendation for ${rec.foodName} saved to History.',
              style: AppTypography.titleMd.copyWith(color: Colors.white),
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e, st) {
      debugPrint('[PackSense] Error saving history: $e\n$st');
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[800],
            content: Text(
              'Could not save to Supabase: $e',
              style: AppTypography.titleMd.copyWith(color: Colors.white),
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _exportPdfReport() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceContainerLowest,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.picture_as_pdf,
                    color: AppColors.secondary, size: 28),
                const SizedBox(width: 10),
                Text('Export PDF Report', style: AppTypography.titleLg),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Technical Packaging Specification Report generated for ${widget.recommendation.foodName}. Includes barrier analysis, permeability metrics, and supplier compliance sheet.',
              style: AppTypography.bodyMd,
            ),
            const SizedBox(height: 20),
            PackSenseButton(
              label: 'Download PDF Specification Sheet',
              icon: Icons.download,
              variant: ButtonVariant.primary,
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('PDF downloaded successfully.')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openMaterialDetails(PackagingMaterial material) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MaterialDetailsScreen(
          material: material,
          foodName: widget.recommendation.foodName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rec = widget.recommendation;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(
              bottom: BorderSide(color: AppColors.structuralBorder, width: 1),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: AppColors.primary),
                    onPressed: () => Navigator.maybePop(context),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                    splashRadius: 24,
                  ),
                  Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: const BoxDecoration(
                          color: AppColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'PackSense',
                        style: AppTypography.headlineSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share,
                            size: 20, color: AppColors.onSurfaceVariant),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('Share link copied to clipboard.')),
                          );
                        },
                        splashRadius: 20,
                      ),
                      IconButton(
                        icon: const Icon(Icons.help_outline,
                            size: 20, color: AppColors.onSurfaceVariant),
                        onPressed: () {
                          _showHelpDialog();
                        },
                        splashRadius: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selected Context Pill
                _buildContextPill(rec),
                const SizedBox(height: 16),

                // Main Hero Card: Packaging Match
                _buildHeroMatchCard(rec),
                const SizedBox(height: 20),

                // Section: Why this packaging?
                _buildWhyThisPackagingSection(rec),
                const SizedBox(height: 20),

                // Section: Key Specifications Bento Grid
                _buildKeySpecificationsSection(rec),
                const SizedBox(height: 20),

                // Section: Other Options (Alternative Packaging)
                _buildAlternativesSection(rec),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildStickyActionBar(),
    );
  }

  Widget _buildContextPill(PackagingRecommendationResult rec) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.structuralBorder, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(rec.foodEmoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
              Text(
                rec.foodName,
                style: AppTypography.labelMd.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 6),
              const Text('•',
                  style: TextStyle(color: AppColors.outlineVariant)),
              const SizedBox(width: 6),
              Text(
                rec.storageCondition,
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 6),
              const Text('•',
                  style: TextStyle(color: AppColors.outlineVariant)),
              const SizedBox(width: 6),
              Text(
                rec.targetShelfLife,
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(Icons.tune, size: 16, color: AppColors.secondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroMatchCard(PackagingRecommendationResult rec) {
    return CustomOrganicCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Status Tier
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECOMMENDED PACKAGING',
                style: AppTypography.labelMd.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.verified,
                        size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      rec.matchTier,
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Material Name & Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rec.primaryMatch.name,
                      style: AppTypography.headlineLgMobile.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      rec.primaryMatch.description,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: AppColors.structuralBorder, width: 1),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.layers,
                        size: 24, color: AppColors.secondary),
                    const SizedBox(height: 2),
                    Text(
                      rec.primaryMatch.polymerCode,
                      style: AppTypography.labelSm.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Epistemic Data Tag
          rec.basedOnMeasuredData
              ? const EpistemicTag.measured(
                  customLabel: 'BASED ON MEASURED DATA')
              : const EpistemicTag.aiEstimate(
                  customLabel: 'BASED ON AI ESTIMATE'),
          const SizedBox(height: 16),

          // Visual Barrier Transmission Bar Strip
          Container(
            padding: const EdgeInsets.only(top: 14),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0x1FE3EAE1), width: 1),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildBarrierMetricPill(
                      'O₂ BARRIER', rec.o2BarrierRating, AppColors.primary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildBarrierMetricPill('MOISTURE CONTROL',
                      rec.moistureControlRating, AppColors.primary),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildBarrierMetricPill('CONDENSATION',
                      rec.condensationRating, AppColors.secondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBarrierMetricPill(String label, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              fontSize: 9,
              color: AppColors.outline,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: AppTypography.labelSm.copyWith(
              fontSize: 11,
              color: valueColor,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildWhyThisPackagingSection(PackagingRecommendationResult rec) {
    return CustomOrganicCard(
      padding: const EdgeInsets.all(20),
      borderRadius: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_alt,
                  color: AppColors.secondary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Why this packaging?',
                style: AppTypography.titleLg.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            rec.rationaleSummary,
            style: AppTypography.bodySm.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // 4 Bullet Checkmark tags
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rec.rationalePoints.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final point = rec.rationalePoints[index];
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(10),
                  border:
                      Border.all(color: AppColors.structuralBorder, width: 1),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: AppColors.secondary,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurface,
                            height: 1.35,
                          ),
                          children: [
                            TextSpan(
                              text: '${point.title}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            TextSpan(text: point.description),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildKeySpecificationsSection(PackagingRecommendationResult rec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Key Specifications',
              style:
                  AppTypography.titleLg.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'Empirical Benchmarks',
              style: AppTypography.labelSm.copyWith(color: AppColors.outline),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rec.keySpecifications.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.05,
          ),
          itemBuilder: (context, index) {
            final spec = rec.keySpecifications[index];
            return CustomOrganicCard(
              padding: const EdgeInsets.all(14),
              borderRadius: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            spec.label.toUpperCase(),
                            style: AppTypography.labelSm.copyWith(
                              fontSize: 10,
                              color: AppColors.outline,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Icon(Icons.info_outline,
                              size: 14, color: AppColors.outline),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        spec.value,
                        style: AppTypography.headlineSm.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        spec.subtitle,
                        style: AppTypography.labelSm.copyWith(
                          fontSize: 10.5,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0x1FE3EAE1), width: 1),
                      ),
                    ),
                    child: Text(
                      spec.footerNote,
                      style: AppTypography.bodySm.copyWith(
                        fontSize: 10.5,
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        PackSenseButton.secondary(
          label: 'View Technical Details & Comparison',
          icon: Icons.analytics,
          height: 48,
          onPressed: () => _openMaterialDetails(rec.primaryMatch),
        ),
      ],
    );
  }

  Widget _buildAlternativesSection(PackagingRecommendationResult rec) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Other Options',
              style:
                  AppTypography.titleLg.copyWith(fontWeight: FontWeight.w700),
            ),
            Text(
              'Trade-off Analyses',
              style: AppTypography.labelSm.copyWith(color: AppColors.outline),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rec.alternatives.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final alt = rec.alternatives[index];
            return CustomOrganicCard(
              padding: const EdgeInsets.all(16),
              borderRadius: 14,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    alt.name,
                                    style: AppTypography.titleMd.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerLow,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    alt.ecoBadge,
                                    style: AppTypography.labelSm.copyWith(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              alt.description,
                              style: AppTypography.bodySm.copyWith(
                                color: AppColors.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        alt.costDelta,
                        style: AppTypography.labelSm.copyWith(
                          color: alt.costDelta.contains('-')
                              ? AppColors.secondary
                              : AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0x1FE3EAE1), width: 1),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.secondary,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              alt.ecoDetail,
                              style: AppTypography.labelSm.copyWith(
                                fontSize: 11,
                                color: AppColors.outline,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () => _openMaterialDetails(alt),
                          child: Text(
                            'Compare Spec',
                            style: AppTypography.labelMd.copyWith(
                              color: AppColors.secondary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildStickyActionBar() {
    return StickyBottomActionBar(
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: PackSenseButton(
              label: _isSaved
                  ? 'Saved'
                  : (_isSaving ? 'Saving...' : 'Save to History'),
              icon: _isSaved ? Icons.bookmark : Icons.bookmark_border,
              variant: ButtonVariant.ghost,
              onPressed: (_isSaved || _isSaving) ? null : _saveToHistory,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: PackSenseButton(
              label: 'Export PDF Report',
              icon: Icons.picture_as_pdf,
              variant: ButtonVariant.primary,
              onPressed: _exportPdfReport,
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Packaging Recommendation', style: AppTypography.titleLg),
        content: Text(
          'Our AI engine cross-references USDA produce respiration datasets with barrier permeability specifications to find the exact equilibrium MAP matrix.',
          style: AppTypography.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close',
                style:
                    AppTypography.titleMd.copyWith(color: AppColors.secondary)),
          ),
        ],
      ),
    );
  }
}
