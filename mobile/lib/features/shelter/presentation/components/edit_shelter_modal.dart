import 'package:bastetshelter/features/common/components/fields/app_text_field.dart';
import 'package:bastetshelter/providers/geo/geo_provider.dart';
import 'package:bastetshelter/providers/shelters/shelter_notifier.dart';
import 'package:bastetshelter/core/utils/validators.dart';
import 'package:bastetshelter/features/common/components/dropdowns/location_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EditShelterModal extends ConsumerStatefulWidget {
  final String currentName;
  final String currentProvinceId;
  final String? currentEmail;

  const EditShelterModal({
    super.key,
    required this.currentName,
    required this.currentProvinceId,
    this.currentEmail,
  });

  @override
  ConsumerState<EditShelterModal> createState() => _EditShelterModalState();
}

class _EditShelterModalState extends ConsumerState<EditShelterModal> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late String _selectedProvinceId;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.currentName);
    _emailController = TextEditingController(text: widget.currentEmail);
    _selectedProvinceId = widget.currentProvinceId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _saveShelter() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    if (name.isEmpty) return;

    ref
        .read(shelterProvider.notifier)
        .updateShelter(
          name: name,
          provinceId: _selectedProvinceId,
          email: email.isNotEmpty ? email : null,
        );

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
            const Text(
              'Edit Shelter',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _nameController,
              label: 'Shelter name',
              keyboardType: TextInputType.text,
              validator: (value) =>
                  Validators.validateRequired(value, 'Shelter Name'),
            ),
            const SizedBox(height: 16),
            AppTextField(
              controller: _emailController,
              label: 'Shelter email',
              keyboardType: TextInputType.emailAddress,
              validator: (value) => Validators.validateEmailNoRequired(value),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Province',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            provincesAsync.when(
              data: (provinceList) => LocationDropdown(
                items: provinceList,
                initialItem: _selectedProvinceId,
                onChanged: (value) {
                  setState(() => _selectedProvinceId = value!);
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text(
                'Error loading provinces: $e',
                style: const TextStyle(color: Colors.red),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: FilledButton(
                onPressed: _saveShelter,
                child: const Text('Save Changes'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
