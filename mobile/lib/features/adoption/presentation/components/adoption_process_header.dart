import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_process/adoption_process_details.dart';
import 'package:bastetshelter/features/common/components/section_badge.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AdoptionProcessHeader extends StatelessWidget {
  const AdoptionProcessHeader({
    super.key,
    required this.process,
    required this.animalName,
    required this.adoptantName,
    this.animalImageUrl,
  });

  final AdoptionProcessDetails process;
  final String animalName;
  final String adoptantName;
  final String? animalImageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fmt = DateFormat('dd MMM yyyy');

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: animalImageUrl != null
                ? Image.network(
                    animalImageUrl!,
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                  )
                : Container(
                    width: 80,
                    height: 80,
                    color: AppColors.primaryTint,
                    child: const Icon(
                      Icons.pets_rounded,
                      color: AppColors.primary,
                      size: 36,
                    ),
                  ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        animalName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      _InfoItem(
                        label: 'Adoptant',
                        value: adoptantName,
                        alignment: CrossAxisAlignment.start,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SectionBadge(label: process.status.value),
                    const SizedBox(height: 12),
                    _InfoItem(
                      label: 'Start Date',
                      value: fmt.format(process.startDate),
                      alignment: CrossAxisAlignment.center,
                    ),
                    if (process.endDate != null) ...[
                      const SizedBox(height: 8),
                      _InfoItem(
                        label: 'End Date',
                        value: fmt.format(process.endDate!),
                        alignment: CrossAxisAlignment.center,
                      ),
                    ],
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

class _InfoItem extends StatelessWidget {
  const _InfoItem({
    required this.label,
    required this.value,
    this.alignment = CrossAxisAlignment.start,
  });

  final String label;
  final String value;
  final CrossAxisAlignment alignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
            fontWeight: FontWeight.w600,
          ),
          textAlign: alignment == CrossAxisAlignment.center
              ? TextAlign.center
              : TextAlign.start,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: alignment == CrossAxisAlignment.center
              ? TextAlign.center
              : TextAlign.start,
        ),
      ],
    );
  }
}
