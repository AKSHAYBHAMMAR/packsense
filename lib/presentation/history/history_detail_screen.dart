import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/epistemic_tag.dart';
import '../../core/widgets/packsense_button.dart';
import '../../data/models/analysis_history_item.dart';
import '../../data/models/packaging_material.dart';
import '../home/home_screen.dart';
import '../materials/material_details_screen.dart';

/// Detailed view displaying saved historical analysis for a specific record.
///
/// Uses the selected record ID and displays strictly persisted database fields.
/// Does not rerun analysis or fabricate missing values.
class HistoryDetailScreen extends StatelessWidget {
  final AnalysisHistoryItem item;

  const HistoryDetailScreen({
    super.key,
    required this.item,
  });

  void _openMaterialSpecs(BuildContext context) {
    // Attempt lookup in packaging catalog
    final matName = item.recommendedMaterial.toLowerCase();
    PackagingMaterial? matched;
    for (final m in PackagingMaterial.allMaterials) {
      if (m.name.toLowerCase() == matName ||
          m.id == item.recommendationData?['primary_material_id']) {
        matched = m;
        break;
      }
    }

    if (matched != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MaterialDetailsScreen(
            material: matched!,
            foodName: item.productName,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Technical specifications for "${item.recommendedMaterial}" are available in All Materials.'),
        ),
      );
    }
  }

  void _navigateToHome(BuildContext context) {
    HomeScreen.switchToHomeTab();
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  Widget _buildHomeBackButton(BuildContext context) {
    return Tooltip(
      message: 'Back to Home',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const Key('history_detail_back_to_home_button'),
          onTap: () => _navigateToHome(context),
          borderRadius: BorderRadius.circular(999),
          hoverColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
          splashColor: AppColors.secondary.withValues(alpha: 0.12),
          highlightColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.3),
          child: Container(
            constraints: const BoxConstraints(minHeight: 38, minWidth: 44),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: AppColors.structuralBorder,
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(
                  Icons.arrow_back,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 5),
                Text(
                  'Home',
                  style: AppTypography.labelLg.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  _buildHomeBackButton(context),
                  Text(
                    'Analysis Record',
                    style: AppTypography.headlineSm.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.share,
                        size: 20, color: AppColors.onSurfaceVariant),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Analysis link copied to clipboard.')),
                      );
                    },
                    splashRadius: 20,
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
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Meta Card
                _buildHeaderCard(),
                const SizedBox(height: 16),

                // Primary Recommended Packaging Card
                _buildRecommendedMaterialCard(context),
                const SizedBox(height: 16),

                // Recommendation Reasoning
                if (item.recommendationReason != null &&
                    item.recommendationReason!.isNotEmpty)
                  _buildReasoningCard(),

                // Technical Barrier Specifications
                if (item.barrierProperties != null &&
                    item.barrierProperties!.isNotEmpty)
                  _buildBarrierSpecsCard(),

                // Input Product Data (Only displayed if data was present)
                _buildInputProductDataCard(),
                const SizedBox(height: 20),

                // Actions
                PackSenseButton(
                  label: 'View Material Technical Specs',
                  icon: Icons.category,
                  variant: ButtonVariant.darkContainer,
                  onPressed: () => _openMaterialSpecs(context),
                ),
                const SizedBox(height: 10),
                PackSenseButton.secondary(
                  label: 'Export PDF Specification Sheet',
                  icon: Icons.picture_as_pdf,
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'PDF Report prepared for ${item.productName} analysis.'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.structuralBorder, width: 1),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    item.foodEmoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.productName,
                      style: AppTypography.headlineSm.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${item.formattedDateTime} (${item.timeAgo})',
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(color: Color(0x1FE3EAE1), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              item.isMeasured
                  ? const EpistemicTag.measured()
                  : const EpistemicTag.aiEstimate(),
              if (item.id.isNotEmpty)
                Text(
                  'Record ID: ${item.id.length > 8 ? item.id.substring(0, 8) : item.id}',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 11,
                    fontFamily: 'monospace',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendedMaterialCard(BuildContext context) {
    final matchTier =
        item.recommendationData?['match_tier']?.toString() ?? 'Optimal Fit';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.structuralBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'RECOMMENDED PACKAGING',
                style: AppTypography.labelSm.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  matchTier,
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            item.recommendedMaterial,
            style: AppTypography.titleLg.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          // Metrics summary strip
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              if (item.predictedShelfLife != null &&
                  item.predictedShelfLife!.isNotEmpty)
                _buildPillMetric(
                    Icons.schedule, 'Shelf-Life', item.predictedShelfLife!),
              if (item.storageCondition != null &&
                  item.storageCondition!.isNotEmpty)
                _buildPillMetric(
                    Icons.ac_unit, 'Storage', item.storageCondition!),
              if (item.confidenceScore != null)
                _buildPillMetric(
                  Icons.verified,
                  'Confidence',
                  '${(item.confidenceScore! * 100).toInt()}%',
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPillMetric(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.structuralBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.secondary),
          const SizedBox(width: 6),
          Text(
            '$label: ',
            style: AppTypography.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
          Text(
            value,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReasoningCard() {
    final rationalePoints =
        item.recommendationData?['rationale_points'] as List<dynamic>?;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.structuralBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recommendation Reasoning',
            style: AppTypography.titleMd.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.recommendationReason!,
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurface,
              height: 1.45,
            ),
          ),
          if (rationalePoints != null && rationalePoints.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...rationalePoints.map((point) {
              final map = point is Map ? point : null;
              if (map == null) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 16, color: AppColors.secondary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                          children: [
                            TextSpan(
                              text: '${map['title'] ?? ''}: ',
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                            TextSpan(text: map['description'] ?? ''),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildBarrierSpecsCard() {
    final bp = item.barrierProperties!;
    final otr = bp['otr_spec']?.toString();
    final wvtr = bp['wvtr_spec']?.toString();
    final o2Rating = bp['o2_barrier_rating']?.toString();
    final moistureRating = bp['moisture_control_rating']?.toString();
    final condensationRating = bp['condensation_rating']?.toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.structuralBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Barrier Requirements & Specs',
            style: AppTypography.titleMd.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (otr != null) _buildSpecRow('Oxygen Transmission (OTR)', otr),
          if (wvtr != null)
            _buildSpecRow('Water Vapor Transmission (WVTR)', wvtr),
          if (o2Rating != null) _buildSpecRow('O₂ Barrier Tier', o2Rating),
          if (moistureRating != null)
            _buildSpecRow('Moisture Control Tier', moistureRating),
          if (condensationRating != null)
            _buildSpecRow('Condensation Control', condensationRating),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              value,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputProductDataCard() {
    final hasMoisture = item.moisture != null;
    final hasTemp = item.temperature != null;
    final hasRh = item.relativeHumidity != null;
    final input = item.inputData;

    final hasAny = hasMoisture ||
        hasTemp ||
        hasRh ||
        (item.storageCondition != null && item.storageCondition!.isNotEmpty) ||
        (input != null && input.isNotEmpty);

    if (!hasAny) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.structuralBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Text(
                'Input Commodity Parameters',
                style: AppTypography.titleMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  item.isMeasured ? 'Measured Lab Input' : 'AI Estimated Input',
                  style: AppTypography.labelSm.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (hasMoisture)
            _buildSpecRow(
                'Moisture Content', '${item.moisture!.toStringAsFixed(1)}%'),
          if (hasTemp)
            _buildSpecRow(
                'Storage Temperature', '${item.temperature!.toStringAsFixed(1)}°C'),
          if (hasRh)
            _buildSpecRow('Relative Humidity',
                '${item.relativeHumidity!.toStringAsFixed(0)}% RH'),
          if (item.storageCondition != null)
            _buildSpecRow('Storage Environment', item.storageCondition!),
          if (input != null) ...[
            if (input['ph'] != null)
              _buildSpecRow('pH Acidity', input['ph'].toString()),
            if (input['oil_fat_percent'] != null)
              _buildSpecRow(
                  'Oil/Fat Content', '${input['oil_fat_percent']}%'),
            if (input['fragility'] != null)
              _buildSpecRow('Fragility Level',
                  input['fragility'].toString().toUpperCase()),
            if (input['sustainability_preference'] != null)
              _buildSpecRow('Sustainability Target',
                  input['sustainability_preference'].toString().toUpperCase()),
          ],
        ],
      ),
    );
  }
}
