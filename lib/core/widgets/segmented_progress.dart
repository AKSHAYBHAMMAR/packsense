import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

/// 4-Segmented Progress bar matching Stitch linear multi-step navigation
class SegmentedProgressBar extends StatelessWidget {
  final int currentStep; // 1 to 4
  final int totalSteps;

  const SegmentedProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final bool isCompletedOrCurrent = index < currentStep;
        return Expanded(
          child: Container(
            height: 6,
            margin: EdgeInsets.only(
              right: index < totalSteps - 1 ? 6 : 0,
            ),
            decoration: BoxDecoration(
              color: isCompletedOrCurrent
                  ? AppColors.primaryContainer
                  : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(999),
            ),
          ),
        );
      }),
    );
  }
}

/// Header for multi-step recommendation flow with back button, step indicator, and progress bar
class RecommendationFlowHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  final VoidCallback? onHelp;

  const RecommendationFlowHeader({
    super.key,
    required this.currentStep,
    this.totalSteps = 4,
    this.onBack,
    this.onHelp,
  });

  @override
  Size get preferredSize => const Size.fromHeight(80);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface.withOpacity(0.95),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: AppColors.primary),
                    onPressed: onBack ?? () => Navigator.maybePop(context),
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                    splashRadius: 24,
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainer,
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                          color: AppColors.structuralBorder, width: 1),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
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
                          'Step $currentStep of $totalSteps',
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.help_outline,
                        color: AppColors.onSurfaceVariant, size: 22),
                    onPressed: onHelp ??
                        () {
                          _showHelpDialog(context);
                        },
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints(minWidth: 40, minHeight: 40),
                    splashRadius: 24,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SegmentedProgressBar(
                currentStep: currentStep,
                totalSteps: totalSteps,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.biotech, color: AppColors.secondary),
            const SizedBox(width: 8),
            Text('PackSense Bio-Intelligence', style: AppTypography.titleLg),
          ],
        ),
        content: Text(
          'PackSense uses bio-metric respiration algorithms and food barrier modeling to compute optimal packaging materials for your food commodity.',
          style: AppTypography.bodyMd,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Understood',
                style:
                    AppTypography.titleMd.copyWith(color: AppColors.secondary)),
          ),
        ],
      ),
    );
  }
}
