import 'package:bastetshelter/features/medical/data/models/medicine_model.dart';
import 'package:flutter/material.dart';

class MedicineDropdown extends StatefulWidget {
  final List<Medicine> items;
  final Medicine? initialItem;
  final ValueChanged<Medicine?>? onChanged;

  const MedicineDropdown({
    super.key,
    required this.items,
    this.initialItem,
    this.onChanged,
  });

  @override
  State<MedicineDropdown> createState() => _MedicineDropdownState();
}

class _MedicineDropdownState extends State<MedicineDropdown> {
  // ignore: unused_field
  Medicine? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialItem;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DropdownMenu<Medicine>(
        hintText: 'Search medicine...',
        initialSelection: widget.initialItem,
        enableFilter: true,
        requestFocusOnTap: true,
        menuHeight: 250,
        leadingIcon: const Icon(Icons.search),
        dropdownMenuEntries: widget.items
            .map(
              (m) => DropdownMenuEntry(
                value: m,
                label: m.name,
                trailingIcon: Text(
                  'Stock: ${m.currentStock}',
                  style: const TextStyle(fontSize: 11),
                ),
              ),
            )
            .toList(),
        onSelected: (Medicine? newValue) {
          setState(() => _selected = newValue);
          widget.onChanged?.call(newValue);
        },
      ),
    );
  }
}
