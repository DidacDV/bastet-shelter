import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/navigation_service.dart';
import 'package:bastetshelter/features/common/components/bottom_sheet/form_bottom_sheet.dart';
import 'package:bastetshelter/features/common/components/fields/app_text_field.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:flutter/material.dart';

class StepNotesBottomSheet extends StatefulWidget {
  final String? initialNotes;
  final Future<void> Function(String notes) onSave;

  const StepNotesBottomSheet({
    super.key,
    this.initialNotes,
    required this.onSave,
  });

  @override
  State<StepNotesBottomSheet> createState() => _StepNotesBottomSheetState();
}

class _StepNotesBottomSheetState extends State<StepNotesBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _notesController;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.initialNotes);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    try {
      await widget.onSave(_notesController.text.trim());
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      NavigationService.instance.showSnackBar(
        'An error occurred while saving the notes.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialNotes?.isNotEmpty == true;

    return FormBottomSheet(
      title: isEditing ? 'Edit Notes' : 'Add Notes',
      actions: [
        PrimaryButton(
          label: 'Save Notes',
          isLoading: _loading,
          onPressed: _submit,
        ),
      ],
      children: [
        Form(
          key: _formKey,
          child: AppTextField(
            controller: _notesController,
            label: 'Step Notes',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter some notes.';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}

Future<void> showStepNotesBottomSheet({
  required BuildContext context,
  String? initialNotes,
  required Future<void> Function(String notes) onSave,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) =>
        StepNotesBottomSheet(initialNotes: initialNotes, onSave: onSave),
  );
}
