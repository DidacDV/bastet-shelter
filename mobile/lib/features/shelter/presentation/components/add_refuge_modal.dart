import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/layout/api_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bastetshelter/providers/geo/geo_provider.dart';
import 'package:bastetshelter/features/common/components/dropdowns/location_dropdown.dart';
import 'package:bastetshelter/features/common/components/fields/app_text_field.dart';

import '../../../../providers/shelters/shelter_notifier.dart';
import '../../../../core/utils/validators.dart' show Validators;

class RefugeModal extends ConsumerStatefulWidget {
  final int? refugeId;
  final String? initialName;
  final String? initialProvinceId;

  const RefugeModal({
    super.key,
    this.refugeId,
    this.initialName,
    this.initialProvinceId,
  });

  @override
  ConsumerState<RefugeModal> createState() => _RefugeModalState();
}

class _RefugeModalState extends ConsumerState<RefugeModal> {
  final _nameController = TextEditingController();
  String? _selectedProvinceId;
  final _formKey = GlobalKey<FormState>();

  bool get isEditing => widget.refugeId != null;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.initialName ?? '';
    _selectedProvinceId = widget.initialProvinceId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _saveRefuge() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    if (name.isEmpty || _selectedProvinceId == null) return;

    if (isEditing) {
      ref
          .read(shelterProvider.notifier)
          .updateRefuge(widget.refugeId!, name, _selectedProvinceId!);
    } else {
      ref.read(shelterProvider.notifier).addRefuge(name, _selectedProvinceId!);
    }

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
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit Refuge' : 'Add New Refuge',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _nameController,
              label: 'Refuge name',
              keyboardType: TextInputType.text,
              validator: (value) =>
                  Validators.validateRequired(value, 'Refuge Name'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Province',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            provincesAsync.when(
              data: (provinceList) {
                _selectedProvinceId ??= AppConstants.defaultProvince;
                return LocationDropdown(
                  items: provinceList,
                  initialItem: _selectedProvinceId,
                  onChanged: (value) {
                    setState(() {
                      _selectedProvinceId = value;
                    });
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, stack) => ApiErrorWidget(
                error: e,
                onRetry: () => ref.invalidate(geoProvider),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _saveRefuge,
                child: Text(isEditing ? 'Update Refuge' : 'Save Refuge'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
