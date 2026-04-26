import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/adoption/data/adoption_enums.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_process/adoption_process_summary.dart';
import 'package:bastetshelter/features/common/components/section_badge.dart';
import 'package:flutter/material.dart';

class AdoptionCard extends StatelessWidget {
  final AdoptionProcessSummary process;
  final VoidCallback onTap;

  const AdoptionCard({super.key, required this.process, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: process.animalImageUrl != null
                  ? Image.network(
                      process.animalImageUrl!,
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 90,
                      height: 90,
                      color: AppColors.primaryTint,
                      child: const Icon(
                        Icons.pets_rounded,
                        color: AppColors.primary,
                        size: 32,
                      ),
                    ),
            ),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            process.animalName,
                            style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SectionBadge(
                          label: process.status.value,
                          color: process.statusColor,
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      process.adoptantName,
                      style: tt.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        //current step
                        if (process.currentStep != null)
                          _StepPill(label: process.currentStep!.type.label),

                        const Spacer(),

                        Text(
                          MaterialLocalizations.of(
                            context,
                          ).formatMediumDate(process.startDate),
                          style: tt.labelSmall?.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StepPill extends StatelessWidget {
  final String label;
  const _StepPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
