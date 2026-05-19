import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/common/components/animal_picker_bottomsheet.dart';
import 'package:bastetshelter/features/common/components/bottom_sheet/form_bottom_sheet.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:bastetshelter/providers/tasks/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddShiftTasksBottomSheet extends ConsumerStatefulWidget {
  final Future<void> Function(List<int> selectedTaskIds, int? animalId) onSave;

  const AddShiftTasksBottomSheet({super.key, required this.onSave});

  @override
  ConsumerState<AddShiftTasksBottomSheet> createState() =>
      _AddShiftTasksBottomSheetState();
}

class _AddShiftTasksBottomSheetState
    extends ConsumerState<AddShiftTasksBottomSheet> {
  final Set<int> _selectedTaskIds = {};

  dynamic _selectedAnimal;
  bool _loading = false;

  Future<void> _submit() async {
    if (_selectedTaskIds.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() => _loading = true);
    await widget.onSave(_selectedTaskIds.toList(), _selectedAnimal?.id);

    if (mounted) {
      setState(() => _loading = false);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksProvider);
    final theme = Theme.of(context);

    return FormBottomSheet(
      title: context.l10n.t('shifts.addTasksToShift'),
      actions: [
        if (_selectedTaskIds.isNotEmpty) ...[
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              icon: Icon(
                _selectedAnimal == null ? Icons.pets : Icons.check_circle,
                color: AppColors.primary,
              ),
              label: Text(
                _selectedAnimal == null
                    ? context.l10n.t('shifts.linkWithAnimal')
                    : context.l10n
                          .t('shifts.linkedToAnimal')
                          .replaceAll('{animal}', _selectedAnimal.name),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final pickedAnimal = await showAnimalPickerBottomSheet(context);
                if (pickedAnimal != null && mounted) {
                  setState(() => _selectedAnimal = pickedAnimal);
                }
              },
            ),
          ),
          const SizedBox(height: 12),
        ],

        PrimaryButton(
          label: _selectedTaskIds.isEmpty
              ? context.l10n.t('common.cancel')
              : context.l10n
                    .t('shifts.addTasksCount')
                    .replaceAll('{count}', '${_selectedTaskIds.length}'),
          isLoading: _loading,
          onPressed: _submit,
        ),
      ],
      children: [
        Text(
          context.l10n.t('shifts.selectTasksToAssign'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),

        tasksAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Text(
              context.l10n
                  .t('common.errorWithMessage')
                  .replaceAll('{error}', '$e'),
            ),
          ),
          data: (tasks) {
            if (tasks.isEmpty) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primaryTint,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline),
                ),
                child: Text(context.l10n.t('shifts.noTemplateTasks')),
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tasks.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final task = tasks[index];
                final isSelected = _selectedTaskIds.contains(task.id);

                return Card(
                  color: isSelected ? AppColors.primaryTint : AppColors.surface,
                  elevation: 0,
                  clipBehavior: Clip.antiAlias,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.outline,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: isSelected,
                    activeColor: AppColors.primary,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    title: Text(
                      task.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      task.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selectedTaskIds.add(task.id);
                        } else {
                          _selectedTaskIds.remove(task.id);
                        }
                      });
                    },
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

void showAddShiftTasksBottomSheet({
  required BuildContext context,
  required Future<void> Function(List<int> selectedTaskIds, int? animalId)
  onSave,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => AddShiftTasksBottomSheet(onSave: onSave),
  );
}
