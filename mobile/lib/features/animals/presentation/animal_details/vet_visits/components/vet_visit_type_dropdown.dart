import 'package:bastetshelter/features/medicine/data/models/vet_visit_model.dart';
import 'package:flutter/material.dart';

class VetVisitTypeDropdown extends StatefulWidget {
  final VetVisitType initialItem;
  final ValueChanged<VetVisitType?>? onChanged;

  const VetVisitTypeDropdown({
    super.key,
    required this.initialItem,
    this.onChanged,
  });

  @override
  State<VetVisitTypeDropdown> createState() => _VetVisitTypeDropdownState();
}

class _VetVisitTypeDropdownState extends State<VetVisitTypeDropdown> {
  late VetVisitType _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialItem;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DropdownMenu<VetVisitType>(
        initialSelection: _selected,
        menuHeight: 250,
        dropdownMenuEntries: VetVisitType.values
            .map((t) => DropdownMenuEntry(value: t, label: t.label))
            .toList(),
        onSelected: (VetVisitType? newValue) {
          setState(() => _selected = newValue ?? _selected);
          widget.onChanged?.call(newValue);
        },
      ),
    );
  }
}
