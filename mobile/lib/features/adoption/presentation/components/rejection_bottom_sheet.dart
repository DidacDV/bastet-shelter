import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/bottom_sheet/form_bottom_sheet.dart';
import 'package:bastetshelter/features/common/components/fields/app_text_field.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:flutter/material.dart';

class RejectAdoptionBottomSheet extends StatefulWidget {
  final Future<void> Function(String reason) onReject;

  const RejectAdoptionBottomSheet({super.key, required this.onReject});

  @override
  State<RejectAdoptionBottomSheet> createState() =>
      _RejectAdoptionBottomSheetState();
}

class _RejectAdoptionBottomSheetState extends State<RejectAdoptionBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);

    try {
      await widget.onReject(_reasonController.text.trim());
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormBottomSheet(
      title: 'Reject Adoption',
      leading: const Icon(Icons.warning_amber_rounded, color: AppColors.error),
      actions: [
        PrimaryButton(
          label: 'Confirm Rejection & Notify',
          isLoading: _loading,
          onPressed: _submit,
        ),
      ],
      children: [
        Text(
          'This will cancel the adoption process and notify the adoptant. This action cannot be undone.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        Form(
          key: _formKey,
          child: AppTextField(
            controller: _reasonController,
            label: 'Reason for rejection',
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please provide a reason.';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}

Future<void> showRejectAdoptionBottomSheet({
  required BuildContext context,
  required Future<void> Function(String reason) onReject,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => RejectAdoptionBottomSheet(onReject: onReject),
  );
}
