import 'package:bastetshelter/features/medical_treatments/data/models/medical_treatment_model.dart';
import 'package:flutter/material.dart';

class DosageUnitSelector extends StatefulWidget {
  final DosageUnit? initialItem;
  final ValueChanged<DosageUnit?>? onChanged;

  const DosageUnitSelector({super.key, this.initialItem, this.onChanged});

  @override
  State<DosageUnitSelector> createState() => _DosageUnitSelectorState();
}

class _DosageUnitSelectorState extends State<DosageUnitSelector> {
  late Set<DosageUnit> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {widget.initialItem ?? DosageUnit.units};
  }

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<DosageUnit>(
      segments: DosageUnit.values
          .map((u) => ButtonSegment(value: u, label: Text(u.label)))
          .toList(),
      selected: _selected,
      onSelectionChanged: (Set<DosageUnit> newSelection) {
        setState(() => _selected = newSelection);
        widget.onChanged?.call(newSelection.firstOrNull);
      },
      multiSelectionEnabled: false,
    );
  }
}
