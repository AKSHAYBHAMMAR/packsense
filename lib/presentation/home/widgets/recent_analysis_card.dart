import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_card.dart';
import '../../../core/widgets/epistemic_tag.dart';
import '../../../data/models/analysis_history_item.dart';
import '../../../data/repositories/packaging_repository.dart';

class RecentAnalysisCard extends StatelessWidget {
  final RecentAnalysisItem? item;
  final AnalysisHistoryItem? historyItem;
  final VoidCallback? onTap;

  const RecentAnalysisCard({
    super.key,
    required RecentAnalysisItem this.item,
    this.onTap,
  }) : historyItem = null;

  const RecentAnalysisCard.fromHistory({
    super.key,
    required AnalysisHistoryItem this.historyItem,
    this.onTap,
  }) : item = null;

  String get _foodName => item?.foodName ?? historyItem?.foodName ?? '';
  String get _foodEmoji => item?.foodEmoji ?? historyItem?.foodEmoji ?? '📦';
  String get _timeAgo => item?.timeAgo ?? historyItem?.timeAgo ?? '';
  String get _materialName =>
      item?.materialName ?? historyItem?.materialName ?? '';
  String get _specsSummary =>
      item?.specsSummary ?? historyItem?.specsSummary ?? '';
  bool get _isMeasured => item?.isMeasured ?? historyItem?.isMeasured ?? false;

  @override
  Widget build(BuildContext context) {
    return CustomOrganicCard(
      padding: const EdgeInsets.all(16),
      borderRadius: 12,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    _foodEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            _foodName,
                            style: AppTypography.titleMd.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '• $_timeAgo',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _materialName,
                      style: AppTypography.bodySm.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _specsSummary,
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.onSurfaceVariant,
                        fontSize: 11,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.only(top: 10),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(color: Color(0x1FE3EAE1), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _isMeasured
                    ? const EpistemicTag.measured()
                    : const EpistemicTag.aiEstimate(),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View Details',
                      style: AppTypography.labelSm.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
