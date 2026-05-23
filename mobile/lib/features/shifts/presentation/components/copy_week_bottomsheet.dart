import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
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
  bool _skipDaysWithShifts = false;
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
            skipDaysWithShifts: _skipDaysWithShifts,
          );

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n
                  .t('common.errorWithMessage')
                  .replaceAll('{error}', '$e'),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    const double arrowAreaWidth = 24 + 12 * 2;

    return FormBottomSheet(
      title: context.l10n.t('shifts.copyPreviousShifts'),
      actions: [
        PrimaryButton(
          label: context.l10n.t('shifts.copyShifts'),
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
                  context.l10n.t('shifts.copyWeekHelp'),
                  style: tt.bodySmall?.copyWith(color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: Text(
                context.l10n.t('shifts.fromSource'),
                style: tt.labelLarge,
              ),
            ),
            const SizedBox(width: arrowAreaWidth),
            Expanded(
              child: Text(
                context.l10n.t('shifts.toTarget'),
                style: tt.labelLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: WeekPickerChip(
                label: context.l10n.t('shifts.week'),
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
                label: context.l10n.t('shifts.week'),
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
              context.l10n.t('shifts.includeTasks'),
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              context.l10n.t('shifts.includeTasksSubtitle'),
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            onChanged: (val) {
              setState(() => _copyTasks = val ?? false);
            },
          ),
        ),
        Card(
          elevation: 0,
          color: _skipDaysWithShifts
              ? AppColors.primaryTint
              : AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _skipDaysWithShifts
                  ? AppColors.primary
                  : AppColors.outline,
              width: _skipDaysWithShifts ? 1.5 : 1,
            ),
          ),
          child: CheckboxListTile(
            value: _skipDaysWithShifts,
            activeColor: AppColors.primary,
            title: Text(
              context.l10n.t('shifts.skipDaysWithShifts'),
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              context.l10n.t('shifts.skipDaysWithShiftsSubtitle'),
              style: tt.bodySmall?.copyWith(color: AppColors.textSecondary),
            ),
            onChanged: (val) {
              setState(() => _skipDaysWithShifts = val ?? false);
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
