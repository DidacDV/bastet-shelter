import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/bottom_sheet/form_bottom_sheet.dart';
import 'package:bastetshelter/features/common/components/dropdowns/refuge_dropdown.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:bastetshelter/providers/picked_refuge/current_refuge_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PickRefugeBottomSheet extends ConsumerStatefulWidget {
  final List<dynamic> refuges;
  final int currentId;

  const PickRefugeBottomSheet({
    super.key,
    required this.refuges,
    required this.currentId,
  });

  @override
  ConsumerState<PickRefugeBottomSheet> createState() =>
      _PickRefugeBottomSheetState();
}

class _PickRefugeBottomSheetState extends ConsumerState<PickRefugeBottomSheet> {
  late int _selectedId;

  @override
  void initState() {
    super.initState();
    _selectedId = widget.currentId;
  }

  void _save() {
    ref.read(currentRefugeProvider.notifier).setRefuge(_selectedId);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return FormBottomSheet(
      title: 'Switch Refuge',
      actions: [
        PrimaryButton(label: 'Apply', onPressed: _save, isLoading: false),
      ],
      children: [
        Text(
          'Select which refuge you want to view shifts for.',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        RefugeDropdown(
          showLabel: false,
          items: widget.refuges
              .map((r) => RefugeItem(id: r.id, name: r.name))
              .toList(),
          initialItem: _selectedId,
          onChanged: (newId) {
            if (newId != null) {
              setState(() => _selectedId = newId);
            }
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

void showPickRefugeBottomSheet({
  required BuildContext context,
  required List<dynamic> refuges,
  required int currentId,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) =>
        PickRefugeBottomSheet(refuges: refuges, currentId: currentId),
  );
}
