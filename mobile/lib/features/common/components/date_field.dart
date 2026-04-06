import 'package:bastetshelter/core/constants.dart';
import 'package:flutter/material.dart';

class DateField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final bool required;
  final ValueChanged<DateTime?> onChanged;

  const DateField({
    super.key,
    required this.label,
    required this.onChanged,
    this.value,
    this.firstDate,
    this.lastDate,
    this.required = true,
  });

  Future<void> _pick(BuildContext context) async {
    // Hide the keyboard if it's open before showing the date picker
    FocusScope.of(context).unfocus();

    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime.now(),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final hasValue = value != null;

    return InkWell(
      // Replaced GestureDetector with InkWell for the Material splash effect
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(
        8,
      ), // Adjust this if your TextFields are more rounded
      child: InputDecorator(
        isEmpty: !hasValue, // floats label when hasValue, sits inside when not
        decoration: InputDecoration(
          labelText: label,
          hintText: required
              ? 'Select date'
              : 'Optional', // hint shows when empty, no collision
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: hasValue
            ? Text(
                MaterialLocalizations.of(context).formatMediumDate(value!),
                style: tt.bodyMedium?.copyWith(color: AppColors.textPrimary),
              )
            : const SizedBox.shrink(), // nothing in child when empty — label + hint handle it
      ),
    );
  }
}
