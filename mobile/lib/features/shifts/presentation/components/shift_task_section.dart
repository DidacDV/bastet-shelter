import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/common/components/confirmation_dialog.dart';
import 'package:bastetshelter/features/common/components/manage_list_card.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_model.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_task_model.dart';
import 'package:bastetshelter/features/shifts/presentation/components/add_shift_tasks_bottomsheet.dart';
import 'package:bastetshelter/features/shifts/presentation/components/shift_task_detail_bottomsheet.dart';
import 'package:bastetshelter/providers/shifts/shift_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shift_detail_shared.dart';

class ShiftTasksSection extends ConsumerWidget {
  final int shiftId;
  final ShiftDetail shiftDetail;
  final bool isManager;

  const ShiftTasksSection({
    super.key,
    required this.shiftId,
    required this.shiftDetail,
    required this.isManager,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final notifier = ref.read(shiftDetailProvider(shiftId).notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: context.l10n.t('tasks.title'),
          tt: tt,
          padding: EdgeInsets.zero,
          trailing: isManager
              ? TextButton.icon(
                  onPressed: () {
                    showAddShiftTasksBottomSheet(
                      context: context,
                      onSave: (selectedIds, animalId) async {
                        await notifier.addTasksToShift(selectedIds, animalId);
                      },
                    );
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(context.l10n.t('tasks.addTask')),
                )
              : null,
        ),
        const SizedBox(height: 6),
        if (shiftDetail.shiftTasks.isEmpty)
          _EmptyTasksState(tt: tt)
        else
          _ShiftTaskList(
            shiftId: shiftId,
            shiftDetail: shiftDetail,
            isManager: isManager,
          ),
      ],
    );
  }
}

class _EmptyTasksState extends StatelessWidget {
  final TextTheme tt;

  const _EmptyTasksState({required this.tt});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Text(
        context.l10n.t('shifts.noAssignedTasks'),
        textAlign: TextAlign.center,
        style: tt.bodyMedium?.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}

//trying new format to have less files: create subcomponents in the main component file
class _ShiftTaskList extends StatelessWidget {
  final int shiftId;
  final ShiftDetail shiftDetail;
  final bool isManager;

  const _ShiftTaskList({
    required this.shiftId,
    required this.shiftDetail,
    required this.isManager,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxHeight: 210),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Scrollbar(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.all(8),
              itemCount: shiftDetail.shiftTasks.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final shiftTask = shiftDetail.shiftTasks[index];
                return _ShiftTaskItem(
                  shiftId: shiftId,
                  shiftDetail: shiftDetail,
                  shiftTask: shiftTask,
                  isManager: isManager,
                  isEven: index.isEven,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _ShiftTaskItem extends ConsumerWidget {
  final int shiftId;
  final ShiftDetail shiftDetail;
  final ShiftTask shiftTask;
  final bool isManager;
  final bool isEven;

  const _ShiftTaskItem({
    required this.shiftId,
    required this.shiftDetail,
    required this.shiftTask,
    required this.isManager,
    required this.isEven,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final notifier = ref.read(shiftDetailProvider(shiftId).notifier);
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
          if (shiftTask.participant != null) ...[
            const SizedBox(height: 4),
            Text(
              context.l10n
                  .t('shifts.assignedToName')
                  .replaceAll(
                    '{name}',
                    '${shiftTask.participant?.name} ${shiftTask.participant?.lastName1}',
                  ),
              style: tt.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
            isJoined: shiftDetail.isJoined,
            currentParticipantId: shiftDetail.myParticipantId,
            onAssignToMe: () async {
              final int? participantId = shiftDetail.myParticipantId;
              if (participantId != null) {
                await notifier.assignTask(shiftTask.id, participantId);
              }
            },
            onUnassign: () async {
              await notifier.unassignTask(shiftTask.id);
            },
            onToggleCompletion: () async {
              if (isCompleted) {
                await notifier.uncompleteTask(shiftTask.id);
              } else {
                await notifier.completeTask(shiftTask.id);
              }
            },
          ),
        );
      },
      onEdit: null,
      onDelete: isManager
          ? () async {
              final confirm = await ConfirmationDialog.show(
                context: context,
                title: context.l10n.t('shifts.removeTaskTitle'),
                message: context.l10n.t('shifts.removeTaskMessage'),
                confirmText: context.l10n.t('shifts.remove'),
                isDestructive: true,
              );
              if (confirm) {
                notifier.removeTask(shiftTask.id);
              }
            }
          : null,
    );
  }
}
