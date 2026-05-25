import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/animal_pickup_step_details.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_process/components/steps/step_common_info.dart';
import 'package:bastetshelter/features/common/components/fields/date_field.dart';
import 'package:bastetshelter/providers/adoption/adoption_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimalPickupStepView extends ConsumerWidget {
  const AnimalPickupStepView({
    super.key,
    required this.step,
    required this.processId,
  });
  final AnimalPickupStepDetails step;
  final int processId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;

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
                context.l10n.t('adoption.pickupSchedule'),
                style: tt.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 26),
              DateField(
                label: context.l10n.t('adoption.scheduledDate'),
                value: step.scheduledAt,
                required: false,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                onChanged: (date) async {
                  if (date == null) {
                    return;
                  }
                  await ref
                      .read(adoptionDetailProvider(processId).notifier)
                      .scheduleAnimalPickup(date);
                },
              ),
              const SizedBox(height: 20),
              DateField(
                label: context.l10n.t('adoption.actualPickupDate'),
                value: step.actualPickupAt,
                required: false,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                onChanged: (date) async {
                  if (date == null) {
                    return;
                  }
                  await ref
                      .read(adoptionDetailProvider(processId).notifier)
                      .setAnimalPickupActualDate(date, step.id);
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
