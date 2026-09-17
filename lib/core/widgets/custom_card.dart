import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Organic plane card with subtle hairline border and soft ambient shadow
class CustomOrganicCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final bool isSelected;
  final VoidCallback? onTap;
  final double borderRadius;
  final Color? backgroundColor;

  const CustomOrganicCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.isSelected = false,
    this.onTap,
    this.borderRadius = 16.0,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final border = isSelected
        ? Border.all(color: AppColors.primaryContainer, width: 2)
        : Border.all(color: AppColors.structuralBorder, width: 1);

    final shadows = isSelected
        ? const [
            BoxShadow(
              color: AppColors.activeCardShadow,
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ]
        : const [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ];

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        boxShadow: shadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(borderRadius),
          onTap: onTap,
          child: Padding(
            padding: padding,
            child: child,
          ),
        ),
      ),
    );
  }
}
