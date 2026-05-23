import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/animals/data/animal_type_enum.dart';
import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String label;
  const SectionHeader({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class FormLabel extends StatelessWidget {
  final String label;
  const FormLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class AnimalTypeSelector extends StatelessWidget {
  final AnimalTypeEnum selected;
  final ValueChanged<AnimalTypeEnum> onChanged;

  const AnimalTypeSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AnimalTypeEnum.values.map((type) {
        final isSelected = selected == type;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              child: OutlinedButton(
                onPressed: () => onChanged(type),
                style: OutlinedButton.styleFrom(
                  backgroundColor: isSelected
                      ? AppColors.primary.withValues(alpha: 0.08)
                      : Colors.transparent,
                  foregroundColor: isSelected
                      ? AppColors.primary
                      : AppColors.textSecondary,
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : AppColors.outline,
                    width: isSelected ? 2 : 1.5,
                  ),
                ),
                child: Text(
                  type == AnimalTypeEnum.cat
                      ? context.l10n.t('animals.typeCat')
                      : context.l10n.t('animals.typeDog'),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class InAdoptionToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const InAdoptionToggle({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.outline, width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.t('animals.availableForAdoptionShort'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}
