import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/adoption_step_details.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_process/components/steps/step_common_info.dart';
import 'package:bastetshelter/features/common/components/fields/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ScheduledStepView extends ConsumerWidget {
  final AdoptionStepDetails step;
  final int processId;
  final String sectionTitle;
  final DateTime? scheduledAt;
  final Future<void> Function(DateTime) onSchedule;

  const ScheduledStepView({
    super.key,
    required this.step,
    required this.processId,
    required this.sectionTitle,
    required this.scheduledAt,
    required this.onSchedule,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepCommonInfo(step: step, processId: processId),
        const SizedBox(height: 26),
        const Divider(),
        const SizedBox(height: 26),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sectionTitle,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 26),
              DateField(
                label: context.l10n.t('adoption.scheduledDate'),
                value: scheduledAt,
                required: false,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                onChanged: (date) async {
                  if (date == null) return;
                  await onSchedule(date);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
