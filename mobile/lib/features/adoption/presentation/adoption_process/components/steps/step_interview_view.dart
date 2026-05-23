import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/interview_step_details.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_process/components/scheduled_step_view.dart';
import 'package:bastetshelter/providers/adoption/adoption_detail_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InterviewStepView extends ConsumerWidget {
  const InterviewStepView({
    super.key,
    required this.step,
    required this.processId,
  });
  final InterviewStepDetails step;
  final int processId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScheduledStepView(
      step: step,
      processId: processId,
      sectionTitle: context.l10n.t('adoption.interviewSchedule'),
      scheduledAt: step.scheduledAt,
      onSchedule: (date) => ref
          .read(adoptionDetailProvider(processId).notifier)
          .scheduleInterview(date),
    );
  }
}
