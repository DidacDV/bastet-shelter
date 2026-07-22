import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/common/components/fields/date_chip.dart';
import 'package:flutter/material.dart';

class WeekPickerChip extends StatelessWidget {
  DateTime mondayOf(DateTime d) => d.subtract(Duration(days: d.weekday - 1));

  final DateTime date;
  final ValueChanged<DateTime> onWeekSelected;
  final ValueChanged<DateTime>? onDaySelected;
  final String label;
  final bool showArrows;

  const WeekPickerChip({
    super.key,
    required this.date,
    required this.onWeekSelected,
    this.onDaySelected,
    this.label = 'Week s',
    this.showArrows = false,
  });

  Future<void> _pickWeek(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: context.l10n.t('common.selectAnyDayInWeek'),
    );
    if (picked != null) {
      onDaySelected?.call(picked);
      onWeekSelected(mondayOf(picked));
    }
  }

  void _previousWeek() {
    final daysSinceMonday = date.weekday - DateTime.monday;
    final newWeekStart = date.subtract(Duration(days: daysSinceMonday + 7));
    onDaySelected?.call(newWeekStart);
    onWeekSelected(newWeekStart);
  }

  void _nextWeek() {
    final daysSinceMonday = date.weekday - DateTime.monday;
    final newWeekStart = date.add(Duration(days: 7 - daysSinceMonday));
    onDaySelected?.call(newWeekStart);
    onWeekSelected(newWeekStart);
  }

  @override
  Widget build(BuildContext context) {
    final chip = DateChip(
      label: label == 'Week of' ? context.l10n.t('shifts.weekOf') : label,
      date: date,
      backgroundColor: AppColors.surface,
      canEdit: true,
      onEdit: () => _pickWeek(context),
    );

    if (!showArrows) return chip;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          color: AppColors.textSecondary,
          onPressed: _previousWeek,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
        chip,
        IconButton(
          icon: const Icon(Icons.chevron_right_rounded),
          color: AppColors.textSecondary,
          onPressed: _nextWeek,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}