import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/core/localization/localized_mappers.dart';
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
                label: context.localizedMedicineFrequency(f),
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
}
