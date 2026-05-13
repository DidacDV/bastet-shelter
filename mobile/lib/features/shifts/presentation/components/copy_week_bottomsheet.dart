import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/bottom_sheet/form_bottom_sheet.dart';
import 'package:bastetshelter/features/common/components/fields/date_chip.dart';
import 'package:bastetshelter/features/common/components/fields/week_picker_chip.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:bastetshelter/providers/shifts/shift_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CopyWeekBottomSheet extends ConsumerStatefulWidget {
  final int refugeId;
  final DateTime targetWeekStart;

  const CopyWeekBottomSheet({
    super.key,
    required this.refugeId,
    required this.targetWeekStart,
  });

  @override
  ConsumerState<CopyWeekBottomSheet> createState() =>
      _CopyWeekBottomSheetState();
}

class _CopyWeekBottomSheetState extends ConsumerState<CopyWeekBottomSheet> {
  late DateTime _sourceWeekStart;
  bool _copyTasks = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    //source week defaults to week before the target week
    _sourceWeekStart = widget.targetWeekStart.subtract(const Duration(days: 7));
  }

  Future<void> _submit() async {
    setState(() => _loading = true);

    try {
      await ref
          .read(
            shiftsProvider(widget.refugeId, widget.targetWeekStart).notifier,
          )
          .copyWeek(
            sourceWeekStart: _sourceWeekStart,
            targetWeekStart: widget.targetWeekStart,
            copyTasks: _copyTasks,
          );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    const double _arrowAreaWidth = 24 + 12 * 2;

    return FormBottomSheet(
      title: 'Copy Previous Shifts',
      actions: [
        PrimaryButton(
          label: 'Copy Shifts',
          isLoading: _loading,
          onPressed: _submit,
        ),
      ],
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primaryTint,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Select a past week to duplicate. Time slots and max participants will be copied. Days that already have shifts will be safely skipped.',
                  style: tt.bodySmall?.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(child: Text('From (Source)', style: tt.labelLarge)),
            const SizedBox(width: _arrowAreaWidth),
            Expanded(child: Text('To (Target)', style: tt.labelLarge)),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: WeekPickerChip(
                label: 'Week',
                date: _sourceWeekStart,
                onWeekSelected: (newDate) {
                  setState(() => _sourceWeekStart = newDate);
                },
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: AppColors.textSecondary,
              ),
            ),

            Expanded(
              child: DateChip(
                label: 'Week',
                date: widget.targetWeekStart,
                backgroundColor: AppColors.surface,
                canEdit: false,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Card(
          elevation: 0,
          color: _copyTasks ? AppColors.primaryTint : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _copyTasks ? AppColors.primary : AppColors.outline,
              width: _copyTasks ? 1.5 : 1,
            ),
          ),
          child: CheckboxListTile(
            value: _copyTasks,
            activeColor: AppColors.primary,
            title: Text(
              'Include Tasks',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              'Template tasks attached to the source shifts will be brought over (assigned uncompleted).',
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            onChanged: (val) {
              setState(() => _copyTasks = val ?? false);
            },
          ),
        ),
      ],
    );
  }
}

void showCopyWeekBottomSheet({
  required BuildContext context,
  required int refugeId,
  required DateTime targetWeekStart,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => CopyWeekBottomSheet(
      refugeId: refugeId,
      targetWeekStart: targetWeekStart,
    ),
  );
}
