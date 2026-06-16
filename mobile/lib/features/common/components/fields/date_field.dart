import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final hasValue = value != null;

    if (label.isEmpty) {
      return InkWell(
        onTap: () => _pick(context),
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(
              color: AppColors.textSecondary.withValues(alpha: 0.4),
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hasValue
                    ? DateFormat('dd/MM/yyyy').format(value!)
                    : (required
                          ? context.l10n.t('common.selectDate')
                          : context.l10n.t('common.optional')),
                style: tt.bodyMedium?.copyWith(
                  color: hasValue
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.calendar_today_outlined, size: 18),
            ],
          ),
        ),
      );
    }

    return InkWell(
      onTap: () => _pick(context),
      borderRadius: BorderRadius.circular(14),
      child: InputDecorator(
        isEmpty: !hasValue,
        decoration: InputDecoration(
          labelText: label,
          hintText: required
              ? context.l10n.t('common.selectDate')
              : context.l10n.t('common.optional'),
          suffixIcon: const Icon(Icons.calendar_today_outlined, size: 18),
        ),
        child: Text(
          hasValue ? DateFormat('dd/MM/yyyy').format(value!) : '',
          style: tt.bodyMedium?.copyWith(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Future<void> _pick(BuildContext context) async {
    FocusScope.of(context).unfocus();

    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? DateTime.now(),
      firstDate: firstDate ?? DateTime(2000),
      lastDate: lastDate ?? DateTime.now(),
    );
    if (picked != null) onChanged(picked);
  }
}
