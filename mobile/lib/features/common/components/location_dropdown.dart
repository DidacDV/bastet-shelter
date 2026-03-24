import 'package:flutter/material.dart';

class LocationDropdown extends StatefulWidget {
  final List<String> items;
  final String? initialItem;
  final ValueChanged<String?>? onChanged;

  const LocationDropdown({
    super.key,
    required this.items,
    this.initialItem,
    this.onChanged,
  });

  @override
  State<LocationDropdown> createState() => _LocationDropdownState();
}

class _LocationDropdownState extends State<LocationDropdown> {
  String? selectedItem;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: DropdownMenu<String>(
        hintText: 'Select a fruit',
        initialSelection: widget.initialItem,
        enableFilter: true,
        requestFocusOnTap: true,
        leadingIcon: const Icon(Icons.search),
        dropdownMenuEntries: widget.items.map((e) => DropdownMenuEntry(value: e, label: e)).toList(),
        onSelected: (String? newValue) {
          setState(() {
            selectedItem = newValue;
          });
          widget.onChanged?.call(selectedItem);
        },
      ),
    );
  }
}