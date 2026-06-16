import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/common/components/app_statuses/empty_state.dart';
import 'package:bastetshelter/features/shifts/presentation/components/pending_shift_task_card.dart';
import 'package:bastetshelter/providers/animals/animal_pending_tasks_provider.dart';
import 'package:bastetshelter/providers/shifts/shift_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class AnimalTasksTab extends ConsumerWidget {
  final int animalId;

  const AnimalTasksTab({super.key, required this.animalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(animalPendingTasksProvider(animalId));
    final theme = Theme.of(context);
    final String currentLocale = Localizations.localeOf(context).toString();

    final todayLabel = DateFormat(
      'EEEE, d MMM',
      currentLocale,
    ).format(DateTime.now());
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: AppConstants.tabsPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.task_alt,
                    size: 24,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.t('animals.todayPendingTasks'),
                    style: theme.textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                todayLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: tasksAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                context.l10n.t('animals.loadPendingTasksError'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
            data: (groups) {
              if (groups.isEmpty) {
                return AppEmptyState(
                  icon: Icons.task_alt,
                  title: context.l10n.t('animals.noPendingTasksToday'),
                  message: context.l10n.t('animals.noPendingTasksTodayMessage'),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
                itemCount: groups.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, groupIndex) {
                  final group = groups[groupIndex];
                  final shift = group.shift;
                  final tasks = group.tasks;
                  final shiftDetailAsync = ref.watch(
                    shiftDetailProvider(shift.id),
                  );
                  final startStr = DateFormat('HH:mm').format(shift.startTime);
                  final endStr = DateFormat('HH:mm').format(shift.endTime);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (groups.length > 1)
                        Padding(
                          padding: const EdgeInsets.only(left: 8, bottom: 8),
                          child: Text(
                            '$startStr - $endStr',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.outline),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: shiftDetailAsync.when(
                            loading: () => const Padding(
                              padding: EdgeInsets.all(24),
                              child: Center(child: CircularProgressIndicator()),
                            ),
                            error: (_, _) => Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                context.l10n.t('animals.loadPendingTasksError'),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                            data: (shiftDetail) {
                              final notifier = ref.read(
                                animalPendingTasksProvider(animalId).notifier,
                              );

                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(8),
                                itemCount: tasks.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 8),
                                itemBuilder: (context, taskIndex) {
                                  final task = tasks[taskIndex];

                                  return PendingShiftTaskCard(
                                    shiftTask: task,
                                    isEven: taskIndex.isEven,
                                    shiftDetail: shiftDetail,
                                    onAssignToMe: () async {
                                      final participantId =
                                          shiftDetail.myParticipantId;
                                      if (participantId != null) {
                                        await notifier.assignTask(
                                          task.id,
                                          shift.id,
                                          participantId,
                                        );
                                      }
                                    },
                                    onUnassign: () async {
                                      await notifier.unassignTask(
                                        task.id,
                                        shift.id,
                                      );
                                    },
                                    onToggleCompletion: () async {
                                      await notifier.toggleCompletion(task);
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
