import 'package:bastetshelter/core/utils/generic_api_call.dart';
import 'package:bastetshelter/features/shelter/data/shelter_repository.dart';
import 'package:flutter/material.dart';
import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/core/utils/validators.dart';
import 'package:bastetshelter/features/common/components/app_text_field.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';

class CreateShelterScreen extends StatefulWidget {
  const CreateShelterScreen({super.key});

  @override
  State<CreateShelterScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<CreateShelterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _refugeNameController = TextEditingController();
  final _shelterRepository = getIt<ShelterRepository>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _refugeNameController.dispose();
    super.dispose();
  }

  Future<void> _createShelter() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await genericApiCall(() async {
      await _shelterRepository.createShelter(
        _nameController.text,
        _locationController.text,
        _refugeNameController.text,
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    });

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
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
                  AppTextField(
                    controller: _locationController,
                    label: 'Shelter Location',
                    validator: (value) => Validators.validateRequired(value, "shelter's location"),
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