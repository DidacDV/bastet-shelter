import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/bottom_sheet/form_bottom_sheet.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:bastetshelter/features/common/components/animal_avatar.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_task_model.dart';
import 'package:flutter/material.dart';

class ShiftTaskDetailBottomSheet extends StatefulWidget {
  final ShiftTask shiftTask;
  final bool isJoined;
  final int?
  currentParticipantId; //the user that is logged participant ID for this shift

  final Future<void> Function() onAssignToMe;
  final Future<void> Function() onUnassign;
  final Future<void> Function() onToggleCompletion;

  const ShiftTaskDetailBottomSheet({
    super.key,
    required this.shiftTask,
    required this.isJoined,
    required this.currentParticipantId,
    required this.onAssignToMe,
    required this.onUnassign,
    required this.onToggleCompletion,
  });

  @override
  State<ShiftTaskDetailBottomSheet> createState() =>
      _ShiftTaskDetailBottomSheetState();
}

class _ShiftTaskDetailBottomSheetState
    extends State<ShiftTaskDetailBottomSheet> {
  bool _loadingPrimary = false;
  bool _loadingSecondary = false;

  Future<void> _handleAction(
    Future<void> Function() action,
    bool isPrimary,
  ) async {
    setState(() {
      isPrimary ? _loadingPrimary = true : _loadingSecondary = true;
    });

    await action();

    if (mounted) {
      setState(() {
        isPrimary ? _loadingPrimary = false : _loadingSecondary = false;
      });
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final task = widget.shiftTask;
    final isCompleted = task.status == ShiftTaskStatus.completed;

    final isUnassigned = task.participant == null;
    final isAssignedToMe =
        !isUnassigned &&
        widget.currentParticipantId != null &&
        task.participant?.id == widget.currentParticipantId;
    final isAssignedToOther = !isUnassigned && !isAssignedToMe;
    return FormBottomSheet(
      title: task.task.title,
      actions: [
        //CASE 1: Assigned to ME
        if (isAssignedToMe) ...[
          PrimaryButton(
            label: isCompleted ? 'Mark as Pending' : 'Mark as Completed',
            backgroundColor: isCompleted
                ? AppColors.surface
                : AppColors.primary,
            textColor: isCompleted ? AppColors.primary : AppColors.surface,
            isLoading: _loadingPrimary,
            onPressed: () => _handleAction(widget.onToggleCompletion, true),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: _loadingSecondary
                  ? null
                  : () => _handleAction(widget.onUnassign, false),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loadingSecondary
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: AppColors.error,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Unassign Me',
                      style: TextStyle(
                        color: AppColors.error,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],

        //CASE 2: Unassigned
        if (isUnassigned) ...[
          if (widget.isJoined)
            PrimaryButton(
              label: 'Assign to Me',
              isLoading: _loadingPrimary,
              onPressed: () => _handleAction(widget.onAssignToMe, true),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.outline.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Join shift to assign tasks',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],

        //CASE 3: Assigned to someone else
        if (isAssignedToOther)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.outline.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Task is already assigned',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
      children: [
        Row(
          children: [
            Icon(
              isCompleted
                  ? Icons.check_circle_rounded
                  : Icons.pending_actions_rounded,
              color: isCompleted ? AppColors.primary : AppColors.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 6),
            Text(
              isCompleted ? 'Completed' : 'Pending',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isCompleted
                    ? AppColors.primary
                    : AppColors.textSecondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        Text(
          'Description',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          task.task.description,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const Divider(height: 32, color: AppColors.outline),

        if (task.animal != null) ...[
          Text(
            'Linked Animal',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: AnimalAvatar(imageUrl: task.animal?.imageUrl),
            title: Text(
              task.animal!.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('ID: ${task.animal!.id}'),
          ),
          const Divider(height: 24, color: AppColors.outline),
        ],

        Text(
          'Assigned To',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: isUnassigned
                  ? AppColors.outline
                  : AppColors.primaryTint,
              child: Icon(
                isUnassigned ? Icons.person_outline : Icons.person,
                color: isUnassigned
                    ? AppColors.textSecondary
                    : AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              isUnassigned
                  ? 'Unassigned'
                  : '${task.participant?.name ?? ''} ${task.participant?.lastName1 ?? ''}'
                        .trim(),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isUnassigned
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
                fontStyle: isUnassigned ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
