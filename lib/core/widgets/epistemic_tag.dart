import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum EpistemicType {
  measured,
  aiEstimated,
}

/// Epistemic status pill component strictly adhering to Stitch DESIGN.md
/// - Measured: #D8F3DC bg, #B7E4C7 border, #2D6A4F text & 6px dot
/// - AI Estimate: #FFF3CD bg, #FFE69C border, #B07D00 text & 6px dot
class EpistemicTag extends StatelessWidget {
  final EpistemicType type;
  final String? customLabel;
  final bool animateDot;

  const EpistemicTag({
    super.key,
    required this.type,
    this.customLabel,
    this.animateDot = false,
  });

  const EpistemicTag.measured({
    super.key,
    this.customLabel,
    this.animateDot = false,
  }) : type = EpistemicType.measured;

  const EpistemicTag.aiEstimate({
    super.key,
    this.customLabel,
    this.animateDot = false,
  }) : type = EpistemicType.aiEstimated;

  @override
  Widget build(BuildContext context) {
    final bool isMeasured = type == EpistemicType.measured;
    final Color bgColor =
        isMeasured ? AppColors.measuredBg : AppColors.aiEstimateBg;
    final Color borderColor =
        isMeasured ? AppColors.measuredBorder : AppColors.aiEstimateBorder;
    final Color textColor =
        isMeasured ? AppColors.measuredText : AppColors.aiEstimateText;
    final Color dotColor =
        isMeasured ? AppColors.measuredDot : AppColors.aiEstimateDot;
    final String label =
        customLabel ?? (isMeasured ? 'MEASURED' : 'AI ESTIMATE');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: dotColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}
