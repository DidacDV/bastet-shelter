import 'package:bastetshelter/core/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bastetshelter/core/providers/geo_provider.dart';
import 'package:bastetshelter/features/common/components/location_dropdown.dart';

import '../../../../core/providers/shelter_notifier.dart';

class AddRefugeModal extends ConsumerStatefulWidget {
  const AddRefugeModal({super.key});

  @override
  ConsumerState<AddRefugeModal> createState() => _AddRefugeModalState();
}

class _AddRefugeModalState extends ConsumerState<AddRefugeModal> {
  final _nameController = TextEditingController();
  String? _selectedProvinceId;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveRefuge() {
    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedProvinceId == null) return;

    ref.read(shelterProvider.notifier).addRefuge(name, _selectedProvinceId!);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provincesAsync = ref.watch(geoProvider);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Add New Refuge', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Refuge Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Select Province', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),

          provincesAsync.when(
            data: (provinceList) => LocationDropdown(
              items: provinceList,
              initialItem: AppConstants.defaultProvince,
              onChanged: (value) {
                setState(() {
                  _selectedProvinceId = value;
                });
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Text('Error loading provinces: $e', style: const TextStyle(color: Colors.red)),
          ),

          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: _saveRefuge,
              child: const Text('Save Refuge'),
            ),
          ),
        ],
      ),
    );
  }
}