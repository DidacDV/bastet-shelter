import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/fields/date_chip.dart';
import 'package:flutter/material.dart';

class WeekPickerChip extends StatelessWidget {
  DateTime mondayOf(DateTime d) => d.subtract(Duration(days: d.weekday - 1));
  final DateTime date;
  final ValueChanged<DateTime> onWeekSelected;
  final String label;

  const WeekPickerChip({
    super.key,
    required this.date,
    required this.onWeekSelected,
    this.label = 'Week of',
  });

  Future<void> _pickWeek(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Select any day in the week',
    );
    if (picked != null) {
      onWeekSelected(mondayOf(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return DateChip(
      label: label,
      date: date,
      backgroundColor: AppColors.surface,
      canEdit: true,
      onEdit: () => _pickWeek(context),
    );
  }
}
