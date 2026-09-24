import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/custom_card.dart';

class MaterialCategory {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isBio;

  const MaterialCategory({
    required this.title,
    required this.subtitle,
    required this.icon,
    this.isBio = false,
  });
}

class MaterialCategoryGrid extends StatelessWidget {
  final Function(MaterialCategory)? onSelect;

  const MaterialCategoryGrid({super.key, this.onSelect});

  static const List<MaterialCategory> categories = [
    MaterialCategory(
      title: 'PET / HDPE',
      subtitle: 'Rigid & Moisture Barrier',
      icon: Icons.recycling,
    ),
    MaterialCategory(
      title: 'LDPE / PP',
      subtitle: 'Films & Flexible Pouches',
      icon: Icons.layers,
    ),
    MaterialCategory(
      title: 'Glass & Aluminum',
      subtitle: 'Total Barrier & Inert',
      icon: Icons.wine_bar,
    ),
    MaterialCategory(
      title: 'Bio / Compostable',
      subtitle: 'PLA, PHA & Molded Fiber',
      icon: Icons.eco,
      isBio: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: categories.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (context, index) {
        final cat = categories[index];
        return CustomOrganicCard(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          borderRadius: 12,
          onTap: () => onSelect?.call(cat),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: cat.isBio
                      ? AppColors.secondaryContainer.withOpacity(0.4)
                      : AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  cat.icon,
                  color: cat.isBio ? AppColors.secondary : AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      cat.title,
                      style: AppTypography.titleMd.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cat.subtitle,
                      style: AppTypography.labelMd.copyWith(
                        color: cat.isBio
                            ? AppColors.secondary
                            : AppColors.onSurfaceVariant,
                        fontSize: 10,
                        fontWeight:
                            cat.isBio ? FontWeight.w600 : FontWeight.w400,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
