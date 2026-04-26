import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/shelter_visit_step_details.dart';
import 'package:bastetshelter/features/adoption/presentation/components/scheduled_step_view.dart';
import 'package:bastetshelter/providers/adoption/adoption_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShelterVisitStepView extends ConsumerWidget {
  const ShelterVisitStepView({
    super.key,
    required this.step,
    required this.processId,
  });
  final ShelterVisitStepDetails step;
  final int processId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScheduledStepView(
      step: step,
      processId: processId,
      sectionTitle: 'Visit Schedule',
      scheduledAt: step.scheduledAt,
      onSchedule: (date) => ref
          .read(adoptionDetailProvider(processId).notifier)
          .scheduleShelterVisit(date),
    );
  }
}
