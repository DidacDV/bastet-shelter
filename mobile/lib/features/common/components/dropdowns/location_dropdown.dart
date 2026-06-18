import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';

import '../../../geo/data/province_model.dart';

class LocationDropdown extends StatefulWidget {
  final List<Province> items;
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
  void initState() {
    super.initState();
    selectedItem = widget.initialItem;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return DropdownMenu<String>(
          key: ValueKey(widget.initialItem),
          width: constraints.maxWidth,
          hintText: context.l10n.t('common.typeProvinceHere'),
          initialSelection: widget.initialItem,
          enableFilter: true,
          requestFocusOnTap: true,
          menuHeight: 300,
          showTrailingIcon: true,
          leadingIcon: const Icon(Icons.search),
          dropdownMenuEntries: widget.items
              .map((p) => DropdownMenuEntry(value: p.id, label: p.name))
              .toList(),
          onSelected: (String? newValue) {
            setState(() => selectedItem = newValue);
            widget.onChanged?.call(newValue);
          },
        );
      },
    );
  }
}
