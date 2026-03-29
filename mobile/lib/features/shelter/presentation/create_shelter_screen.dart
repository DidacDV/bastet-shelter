import 'package:bastetshelter/core/utils/generic_api_call.dart';
import 'package:bastetshelter/features/shelter/data/shelter_repository.dart';
import 'package:flutter/material.dart';
import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/core/utils/validators.dart';
import 'package:bastetshelter/features/common/components/app_text_field.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants.dart';
import '../../../core/providers/geo_provider.dart';
import '../../common/components/location_dropdown.dart';

class CreateShelterScreen extends ConsumerStatefulWidget {
  const CreateShelterScreen({super.key});

  @override
  ConsumerState<CreateShelterScreen> createState() => _CreateShelterScreenState();
}

class _CreateShelterScreenState extends ConsumerState<CreateShelterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _refugeNameController = TextEditingController();
  final _shelterRepository = getIt<ShelterRepository>();
  bool _isLoading = false;

  String? _selectedLocationId;

  @override
  void dispose() {
    _nameController.dispose();
    _refugeNameController.dispose();
    super.dispose();
  }

  Future<void> _createShelter() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocationId == null) return;

    setState(() => _isLoading = true);

    await genericApiCall(() async {
      await _shelterRepository.createShelter(
        _nameController.text,
        _selectedLocationId!,
        _refugeNameController.text,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    });

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final provincesAsync = ref.watch(geoProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Bastet Shelter')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Center(
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AppTextField(
                    controller: _nameController,
                    label: 'Shelter Name',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => Validators.validateRequired(value, "shelter's name"),
                  ),
                  const SizedBox(height: 16),
                  provincesAsync.when(
                    data: (provinces) => LocationDropdown(
                      items: provinces,
                      initialItem: AppConstants.defaultProvince,
                      onChanged: (value) {
                        setState(() {
                          _selectedLocationId = value;
                        });
                      },
                    ),
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text(
                        'Failed to load locations: $e',
                        style: const TextStyle(color: Colors.red)
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _refugeNameController,
                    label: 'Name of your first refuge',
                    validator: (value) => Validators.validateRequired(value, "refuge name"),
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    label: 'Create shelter',
                    isLoading: _isLoading,
                    onPressed: _createShelter,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}