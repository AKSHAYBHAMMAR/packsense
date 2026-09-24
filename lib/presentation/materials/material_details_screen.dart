import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/custom_card.dart';
import '../../core/widgets/packsense_button.dart';
import '../../data/models/packaging_material.dart';

class MaterialDetailsScreen extends StatelessWidget {
  final PackagingMaterial material;
  final String? foodName;

  const MaterialDetailsScreen({
    super.key,
    required this.material,
    this.foodName,
  });

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
                  IconButton(
                    icon:
                        const Icon(Icons.arrow_back, color: AppColors.primary),
                    onPressed: () => Navigator.maybePop(context),
                    splashRadius: 24,
                  ),
                  Text(
                    'Material Specification',
                    style: AppTypography.titleMd.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 48), // Balances the back button
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
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                CustomOrganicCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              material.category.toUpperCase(),
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              material.polymerCode,
                              style: AppTypography.labelSm.copyWith(
                                color: AppColors.onSecondaryContainer,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        material.name,
                        style: AppTypography.headlineSm.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        material.description,
                        style: AppTypography.bodyMd.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Technical Barrier Parameters
                Text('Technical Barrier Parameters',
                    style: AppTypography.titleLg),
                const SizedBox(height: 12),
                CustomOrganicCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildParamRow(
                          'Oxygen Transmission (OTR)', material.otrSpec),
                      const Divider(color: Color(0x1FE3EAE1), height: 20),
                      _buildParamRow(
                          'Water Vapor Transmission (WVTR)', material.wvtrSpec),
                      const Divider(color: Color(0x1FE3EAE1), height: 20),
                      _buildParamRow('Caliper / Thickness', material.thickness),
                      const Divider(color: Color(0x1FE3EAE1), height: 20),
                      _buildParamRow(
                          'Durability & Puncture', material.durability),
                      const Divider(color: Color(0x1FE3EAE1), height: 20),
                      _buildParamRow(
                          'Recycling / Stream', material.recyclabilityCode),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Key Performance Highlights
                Text('Key Performance Highlights',
                    style: AppTypography.titleLg),
                const SizedBox(height: 12),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: material.keyFeatures.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final feature = material.keyFeatures[index];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: AppColors.structuralBorder, width: 1),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: AppColors.secondary, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              feature,
                              style: AppTypography.bodyMd.copyWith(
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w500,
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
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.structuralBorder, width: 1),
          ),
        ),
        child: SafeArea(
          top: false,
          child: PackSenseButton(
            label: 'Request Supplier Quotes',
            icon: Icons.storefront,
            variant: ButtonVariant.primary,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AppColors.primaryContainer,
                  content:
                      Text('Supplier quote request sent for ${material.name}.'),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildParamRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            label,
            style: AppTypography.labelSm.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: AppTypography.titleMd.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
