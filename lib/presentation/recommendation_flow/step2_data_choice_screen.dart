import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/epistemic_tag.dart';
import '../../core/widgets/packsense_button.dart';
import '../../core/widgets/segmented_progress.dart';
import '../../data/models/food_item.dart';
import '../../data/models/food_properties.dart';
import '../../data/repositories/packaging_repository.dart';
import 'step3_food_details_screen.dart';
import 'step4_recommendation_result_screen.dart';

class Step2DataChoiceScreen extends StatefulWidget {
  final FoodItem selectedFood;

  const Step2DataChoiceScreen({
    super.key,
    required this.selectedFood,
  });

  @override
  State<Step2DataChoiceScreen> createState() => _Step2DataChoiceScreenState();
}

class _Step2DataChoiceScreenState extends State<Step2DataChoiceScreen> {
  bool _isAccordionExpanded = false;
  final PackagingRepository _repository = PackagingRepository();

  void _onEnterMyData() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Step3FoodDetailsScreen(
          foodItem: widget.selectedFood,
          initialProperties:
              FoodProperties.estimateForCommodity(widget.selectedFood.name)
                  .copyWith(
            isMeasured: true,
          ),
        ),
      ),
    );
  }

  void _onEstimateForMe() {
    // Estimate properties and compute recommendation
    final estimatedProps =
        FoodProperties.estimateForCommodity(widget.selectedFood.name).copyWith(
      isMeasured: false,
    );
    final result = _repository.analyzePackaging(estimatedProps);

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => Step4RecommendationResultScreen(recommendation: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const RecommendationFlowHeader(currentStep: 2),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selected Food Summary Pill
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(999),
                    border:
                        Border.all(color: AppColors.structuralBorder, width: 1),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.selectedFood.emoji,
                          style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      Text(
                        widget.selectedFood.name,
                        style: AppTypography.titleMd.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (widget.selectedFood.scientificName != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.outlineVariant,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          widget.selectedFood.scientificName!,
                          style: AppTypography.labelSm.copyWith(
                            color: AppColors.onSurfaceVariant,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Headline
                Text(
                  'Do you have product data?',
                  style: AppTypography.headlineLgMobile.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),

                // Subtitle
                Text(
                  'PackSense can use your lab measurements or estimate properties automatically based on ${widget.selectedFood.name} physiology.',
                  style: AppTypography.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),

                // CARD 1: Measured Data
                _buildMeasuredCard(),
                const SizedBox(height: 16),

                // CARD 2: AI Estimated Data
                _buildAiEstimatedCard(),
                const SizedBox(height: 24),

                // Accordion: Why do we ask?
                _buildWhyDoWeAskAccordion(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMeasuredCard() {
    return Container(
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const EpistemicTag.measured(),
              const Icon(Icons.biotech, color: AppColors.outline, size: 22),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'I HAVE MEASURED DATA',
            style: AppTypography.titleLg.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'I know values such as moisture, pH, fat/oil content or respiration rate.',
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          PackSenseButton(
            label: 'Enter My Data',
            icon: Icons.arrow_forward,
            variant: ButtonVariant.ghost,
            onPressed: _onEnterMyData,
          ),
        ],
      ),
    );
  }

  Widget _buildAiEstimatedCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryContainer, width: 2),
        boxShadow: const [
          BoxShadow(
            color: AppColors.activeCardShadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const EpistemicTag.aiEstimate(),
              const Icon(Icons.auto_awesome,
                  color: AppColors.primaryContainer, size: 22),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            "I DON'T HAVE MEASUREMENTS",
            style: AppTypography.titleLg.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "I don't know the product properties. Let PackSense estimate them from food commodity science.",
            style: AppTypography.bodyMd.copyWith(
              color: AppColors.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          PackSenseButton(
            label: 'Estimate for Me',
            icon: Icons.psychology,
            variant: ButtonVariant.darkContainer,
            onPressed: _onEstimateForMe,
          ),
        ],
      ),
    );
  }

  Widget _buildWhyDoWeAskAccordion() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.structuralBorder, width: 1),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: _isAccordionExpanded,
          onExpansionChanged: (expanded) {
            setState(() => _isAccordionExpanded = expanded);
          },
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: const Icon(Icons.info_outline,
              color: AppColors.secondary, size: 22),
          title: Text(
            'Why do we ask?',
            style: AppTypography.titleMd.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(color: Color(0x1FE3EAE1), height: 1),
                  const SizedBox(height: 12),
                  Text(
                    'These properties help PackSense calculate precise moisture (WVTR), oxygen (OTR), and gas-exchange requirements.',
                    style: AppTypography.bodySm.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.verified,
                          size: 16, color: AppColors.secondary),
                      const SizedBox(width: 6),
                      Text(
                        'ISO 15106 compliant models',
                        style: AppTypography.labelSm.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
