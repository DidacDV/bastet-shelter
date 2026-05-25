import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/common/components/manage_list_card.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_model.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_task_model.dart';
import 'package:bastetshelter/features/shifts/presentation/components/shift_task_detail_bottomsheet.dart';
import 'package:flutter/material.dart';

class PendingShiftTaskCard extends StatelessWidget {
  final ShiftTask shiftTask;
  final bool isEven;
  final bool showAnimalName;
  final bool showParticipantName;
  final ShiftDetail? shiftDetail;
  final bool? isJoined;
  final int? currentParticipantId;
  final Future<void> Function() onAssignToMe;
  final Future<void> Function() onUnassign;
  final Future<void> Function() onToggleCompletion;

  const PendingShiftTaskCard({
    super.key,
    required this.shiftTask,
    required this.isEven,
    this.showAnimalName = false,
    this.showParticipantName = true,
    this.shiftDetail,
    this.isJoined,
    this.currentParticipantId,
    required this.onAssignToMe,
    required this.onUnassign,
    required this.onToggleCompletion,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
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
          if (showParticipantName && shiftTask.participant != null) ...[
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
          if (showAnimalName && shiftTask.animal != null) ...[
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
            isJoined: isJoined ?? shiftDetail?.isJoined ?? false,
            currentParticipantId:
                currentParticipantId ?? shiftDetail?.myParticipantId,
            onAssignToMe: onAssignToMe,
            onUnassign: onUnassign,
            onToggleCompletion: onToggleCompletion,
          ),
        );
      },
    );
  }
}
