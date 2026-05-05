import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/utils/validators.dart';
import 'package:bastetshelter/features/common/components/bottom_sheet/form_bottom_sheet.dart';
import 'package:bastetshelter/features/common/components/fields/app_text_field.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:bastetshelter/features/tasks/data/task_model.dart';
import 'package:bastetshelter/providers/tasks/task_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskFormBottomSheet extends ConsumerStatefulWidget {
  final Task? existingTask;

  const TaskFormBottomSheet({super.key, this.existingTask});

  @override
  ConsumerState<TaskFormBottomSheet> createState() =>
      _TaskFormBottomSheetState();
}

class _TaskFormBottomSheetState extends ConsumerState<TaskFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _numPeopleController;

  bool _loading = false;
  late final bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.existingTask != null;
    _titleController = TextEditingController(
      text: widget.existingTask?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: widget.existingTask?.description ?? '',
    );
    _numPeopleController = TextEditingController(
      text: widget.existingTask != null
          ? widget.existingTask!.numPeople.toString()
          : '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _numPeopleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    try {
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final numPeople = int.parse(_numPeopleController.text.trim());

      if (_isEditing) {
        await ref
            .read(tasksProvider.notifier)
            .updateTask(
              id: widget.existingTask!.id,
              title: title,
              description: description,
              numPeople: numPeople,
            );
      } else {
        await ref
            .read(tasksProvider.notifier)
            .addTask(
              title: title,
              description: description,
              numPeople: numPeople,
            );
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving task: $e')));
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBottomSheet(
      title: _isEditing ? 'Edit Task' : 'New Task',
      actions: [
        PrimaryButton(
          label: _isEditing ? 'Save Changes' : 'Create Task',
          isLoading: _loading,
          onPressed: _save,
        ),
      ],
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppTextField(
                controller: _titleController,
                label: 'Task Title',
                validator: (v) => Validators.validateRequired(v, 'title'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _descriptionController,
                label: 'Description',
                textInputAction: TextInputAction.newline,
                keyboardType: TextInputType.multiline,
                validator: (v) => Validators.validateRequired(v, 'description'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 16),
              AppTextField(
                controller: _numPeopleController,
                label: 'Persons needed',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) => Validators.validatePositiveNumber(
                  v,
                  fieldName: 'persons needed',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Future<void> showTaskFormBottomSheet({
  required BuildContext context,
  Task? existingTask,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => TaskFormBottomSheet(existingTask: existingTask),
  );
}
