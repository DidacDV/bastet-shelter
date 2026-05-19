import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/medical_treatments/data/models/medical_treatment_model.dart';
import 'package:flutter/material.dart';

class FrequencyDropdown extends StatefulWidget {
  final MedicineFrequency? initialItem;
  final ValueChanged<MedicineFrequency?>? onChanged;

  const FrequencyDropdown({super.key, this.initialItem, this.onChanged});

  @override
  State<FrequencyDropdown> createState() => _FrequencyDropdownState();
}

class _FrequencyDropdownState extends State<FrequencyDropdown> {
  MedicineFrequency? selectedItem;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DropdownMenu<MedicineFrequency>(
        hintText: context.l10n.t('medical.selectFrequency'),
        initialSelection: widget.initialItem,
        requestFocusOnTap: true,
        showTrailingIcon: true,
        dropdownMenuEntries: MedicineFrequency.values
            .map(
              (f) => DropdownMenuEntry(
                value: f,
                label: _localizedFrequency(context, f),
              ),
            )
            .toList(),
        onSelected: (MedicineFrequency? newValue) {
          setState(() {
            selectedItem = newValue;
          });
          widget.onChanged?.call(selectedItem);
        },
      ),
    );
  }

  String _localizedFrequency(
    BuildContext context,
    MedicineFrequency frequency,
  ) => switch (frequency) {
    MedicineFrequency.daily => context.l10n.t('medical.frequencyDaily'),
    MedicineFrequency.weekly => context.l10n.t('medical.frequencyWeekly'),
    MedicineFrequency.monthly => context.l10n.t('medical.frequencyMonthly'),
    MedicineFrequency.asNeeded => context.l10n.t('medical.frequencyAsNeeded'),
  };
}
