import 'package:bastetshelter/core/localization/app_localizations.dart';
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
  final bool showLabel;
  final bool canEdit;

  const RefugeDropdown({
    super.key,
    required this.items,
    this.initialItem,
    required this.onChanged,
    this.showLabel = true,
    this.canEdit = true,
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
    if (!widget.canEdit) {
      final name = widget.items
          .firstWhere(
            (r) => r.id == _selected,
            orElse: () => RefugeItem(id: -1, name: '—'),
          )
          .name;
      return Text(name, style: Theme.of(context).textTheme.bodyMedium);
    }

    return SizedBox(
      width: double.infinity,
      child: DropdownMenu<int>(
        initialSelection: _selected,
        label: widget.showLabel ? Text(context.l10n.t('common.refuge')) : null,
        expandedInsets: EdgeInsets.zero,
        menuHeight: 300,
        dropdownMenuEntries: widget.items
            .map((r) => DropdownMenuEntry(value: r.id, label: r.name))
            .toList(),
        onSelected: (value) {
          setState(() => _selected = value);
          widget.onChanged(value);
        },
      ),
    );
  }
}
