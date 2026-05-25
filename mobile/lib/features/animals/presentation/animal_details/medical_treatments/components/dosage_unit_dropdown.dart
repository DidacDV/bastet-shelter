import 'package:bastetshelter/core/localization/localized_mappers.dart';
import 'package:bastetshelter/features/medical_treatments/data/models/medical_treatment_model.dart';
import 'package:flutter/material.dart';

class DosageUnitDropdown extends StatefulWidget {
  final DosageUnit? initialItem;
  final ValueChanged<DosageUnit?>? onChanged;

  const DosageUnitDropdown({super.key, this.initialItem, this.onChanged});

  @override
  State<DosageUnitDropdown> createState() => _DosageUnitDropdownState();
}

class _DosageUnitDropdownState extends State<DosageUnitDropdown> {
  late DosageUnit? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialItem;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<DosageUnit>(
      initialSelection: _selected,
      requestFocusOnTap: false,
      dropdownMenuEntries: DosageUnit.values
          .map(
            (u) => DropdownMenuEntry(
              value: u,
              label: context.localizedDosageUnit(u),
            ),
          )
          .toList(),
      onSelected: (DosageUnit? newValue) {
        setState(() => _selected = newValue);
        widget.onChanged?.call(newValue);
      },
    );
  }
}
