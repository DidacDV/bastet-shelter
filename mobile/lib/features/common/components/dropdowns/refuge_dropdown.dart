import 'package:flutter/material.dart';

class RefugeItem {
  final int id;
  final String name;
  const RefugeItem({required this.id, required this.name});
}

class RefugeDropdown extends StatefulWidget {
  final List<RefugeItem> items;
  final int? initialItem;
  final ValueChanged<int?> onChanged;

  const RefugeDropdown({
    super.key,
    required this.items,
    this.initialItem,
    required this.onChanged,
  });

  @override
  State<RefugeDropdown> createState() => _RefugeDropdownState();
}

class _RefugeDropdownState extends State<RefugeDropdown> {
  int? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialItem ?? widget.items.firstOrNull?.id;
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: _selected,
      decoration: const InputDecoration(labelText: 'Refuge'),
      items: widget.items
          .map((r) => DropdownMenuItem(value: r.id, child: Text(r.name)))
          .toList(),
      onChanged: (value) {
        setState(() => _selected = value);
        widget.onChanged(value);
      },
    );
  }
}
