import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/common/components/layout/app_bar.dart';
import 'package:bastetshelter/features/common/components/manage_list_card.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_task_model.dart';
import 'package:bastetshelter/features/shifts/presentation/components/shift_task_detail_bottomsheet.dart';
import 'package:bastetshelter/providers/tasks/my_tasks_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class MyTasksScreen extends ConsumerWidget {
  const MyTasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(myTasksProvider);
    final tt = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: BastetAppBar(
        customTitle: context.l10n.t('tasks.myAssignedTitle'),
        showBackButton: true,
        showConfig: false,
      ),
      body: tasksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            context.l10n.t('tasks.loadError').replaceAll('{error}', '$e'),
          ),
        ),
        data: (groups) {
          if (groups.isEmpty) {
            return Center(
              child: Text(
                context.l10n.t('tasks.noUpcomingAssigned'),
                style: tt.bodyLarge?.copyWith(color: AppColors.textSecondary),
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: groups.length,
            separatorBuilder: (_, _) => const SizedBox(height: 24),
            itemBuilder: (context, index) {
              final group = groups[index];
              final shift = group.shift;
              final tasks = group.tasks;

              final dayStr = DateFormat('EEE, MMM d').format(shift.day);
              final startStr = DateFormat('HH:mm').format(shift.startTime);
              final endStr = DateFormat('HH:mm').format(shift.endTime);

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 12),
                    child: Text(
                      '$dayStr  •  $startStr - $endStr',
                      style: tt.titleMedium?.copyWith(
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
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(8),
                        itemCount: tasks.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, taskIndex) {
                          final task = tasks[taskIndex];
                          return _MyTaskItem(
                            shiftTask: task,
                            isEven: taskIndex.isEven,
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
    );
  }
}

class _MyTaskItem extends ConsumerWidget {
  final ShiftTask shiftTask;
  final bool isEven;

  const _MyTaskItem({required this.shiftTask, required this.isEven});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final notifier = ref.read(myTasksProvider.notifier);
    final isCompleted = shiftTask.status == ShiftTaskStatus.completed;

    return ManageListCard(
      title: shiftTask.task.title,
      leadingIcon: isCompleted
          ? Icons.check_circle_rounded
          : Icons.radio_button_unchecked_rounded,
      isEven: isEven,
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            shiftTask.task.description,
            style: tt.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              decoration: isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
          if (shiftTask.animal != null) ...[
            const SizedBox(height: 4),
            Text(
              context.l10n
                  .t('common.animalName')
                  .replaceAll('{animal}', shiftTask.animal?.name ?? ''),
              style: tt.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          builder: (_) => ShiftTaskDetailBottomSheet(
            shiftTask: shiftTask,
            isJoined: true,
            currentParticipantId: shiftTask.participant?.id,
            onAssignToMe: () async {
              //needed to satisfy constructor?
            },
            onUnassign: () async {
              await notifier.unassignTask(shiftTask.id, shiftTask.shiftId);
            },
            onToggleCompletion: () async {
              await notifier.toggleCompletion(shiftTask);
            },
          ),
        );
      },
    );
  }
}
