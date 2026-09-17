import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Floating / Sticky bottom action bar with subtle top border and blur/shadow
class StickyBottomActionBar extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const StickyBottomActionBar({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.96),
        border: const Border(
          top: BorderSide(color: AppColors.structuralBorder, width: 1),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F1B4332), // 0px -4px 16px rgba(27,67,50,0.06)
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
