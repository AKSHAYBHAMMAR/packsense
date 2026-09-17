import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

enum ButtonVariant {
  primary,
  secondary,
  ghost,
  darkContainer,
}

/// Standard 52px pill buttons strictly adhering to Stitch DESIGN.md
class PackSenseButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Widget? iconWidget;
  final ButtonVariant variant;
  final bool isLoading;
  final double height;
  final double? width;

  const PackSenseButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconWidget,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.height = 52.0,
    this.width,
  });

  const PackSenseButton.secondary({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconWidget,
    this.isLoading = false,
    this.height = 52.0,
    this.width,
  }) : variant = ButtonVariant.secondary;

  const PackSenseButton.darkContainer({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconWidget,
    this.isLoading = false,
    this.height = 52.0,
    this.width,
  }) : variant = ButtonVariant.darkContainer;

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Border? border;
    List<BoxShadow> shadows = [];

    switch (variant) {
      case ButtonVariant.primary:
        bgColor = AppColors.primaryAccent;
        textColor = AppColors.onPrimary;
        shadows = [
          const BoxShadow(
            color: AppColors.buttonShadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ];
        break;
      case ButtonVariant.darkContainer:
        bgColor = AppColors.primaryContainer;
        textColor = AppColors.onPrimary;
        shadows = [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.2),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ];
        break;
      case ButtonVariant.secondary:
        bgColor = AppColors.surfaceContainerLowest;
        textColor = AppColors.primary;
        border = Border.all(color: AppColors.structuralBorder, width: 1);
        break;
      case ButtonVariant.ghost:
        bgColor = AppColors.surfaceContainerLow;
        textColor = AppColors.primary;
        border = Border.all(color: AppColors.structuralBorder, width: 1);
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: onPressed == null ? bgColor.withOpacity(0.5) : bgColor,
        borderRadius: BorderRadius.circular(999),
        border: border,
        boxShadow: onPressed == null ? [] : shadows,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation<Color>(textColor),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (iconWidget != null) ...[
                        iconWidget!,
                        const SizedBox(width: 8),
                      ] else if (icon != null) ...[
                        Icon(icon, size: 20, color: textColor),
                        const SizedBox(width: 8),
                      ],
                      Text(
                        label,
                        style: AppTypography.titleMd.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
