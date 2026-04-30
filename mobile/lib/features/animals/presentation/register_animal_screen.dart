import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/navigation_service.dart';
import 'package:bastetshelter/core/utils/validators.dart';
import 'package:bastetshelter/features/animals/data/animal_type_enum.dart';
import 'package:bastetshelter/features/animals/presentation/components/register_animal_form_utilities.dart';
import 'package:bastetshelter/features/animals/presentation/upload_animal_images_screen.dart';
import 'package:bastetshelter/features/common/components/dropdowns/refuge_dropdown.dart';
import 'package:bastetshelter/features/common/components/fields/app_text_field.dart';
import 'package:bastetshelter/features/common/components/fields/date_field.dart';
import 'package:bastetshelter/features/common/components/illustrated_header.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:bastetshelter/features/shelter/data/shelter_model.dart';
import 'package:bastetshelter/providers/animals/animal_provider.dart';
import 'package:bastetshelter/providers/shelters/shelter_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'components/traits_chip_selector.dart';

class AnimalRegisterScreen extends ConsumerStatefulWidget {
  const AnimalRegisterScreen({super.key});

  @override
  ConsumerState<AnimalRegisterScreen> createState() =>
      _AnimalRegisterScreenState();
}

class _AnimalRegisterScreenState extends ConsumerState<AnimalRegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _breedController = TextEditingController();
  final _descriptionController = TextEditingController();

  AnimalTypeEnum _animalType = AnimalTypeEnum.dog;
  DateTime? _birthDate;
  DateTime? _arrivalDate;
  int? _refugeId;
  bool _inAdoption = false;
  final Set<int> _selectedTraitIds = {};
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _breedController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_birthDate == null) {
      NavigationService.instance.showSnackBar(
        'Please select a birth date',
        isError: true,
      );
      return;
    }

    if (_arrivalDate != null &&
        DateUtils.dateOnly(
          _birthDate!,
        ).isAfter(DateUtils.dateOnly(_arrivalDate!))) {
      NavigationService.instance.showSnackBar(
        'Arrival date cannot be before birth date',
        isError: true,
      );
      return;
    }

    int? finalRefugeId = _refugeId;

    if (finalRefugeId == null) {
      final shelterState = ref.read(shelterProvider);
      finalRefugeId = shelterState.whenOrNull(
        data: (shelter) =>
            shelter.refuges.isNotEmpty ? shelter.refuges.first.id : null,
      );
    }

    if (finalRefugeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please wait for shelter data to load')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final int? newAnimalId = await ref
        .read(animalsProvider.notifier)
        .registerAnimal(
          name: _nameController.text.trim(),
          birthDate: _birthDate!,
          arrivalDate: _arrivalDate,
          description: _descriptionController.text.trim(),
          breed: _breedController.text.trim(),
          animalType: _animalType,
          refugeId: finalRefugeId,
          inAdoption: _inAdoption,
          traitIds: _selectedTraitIds.toList(),
        );

    if (mounted) setState(() => _isLoading = false);

    if (newAnimalId != null && mounted) {
      Navigator.of(context, rootNavigator: true).push(
        MaterialPageRoute(
          builder: (context) => UploadAnimalImagesScreen(animalId: newAnimalId),
        ),
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final shelterAsync = ref.watch(shelterProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IllustratedHeader(
                        badgeLabel: 'NEW ANIMAL',
                        title: 'Register\nan animal',
                        subtitle:
                            'Fill in the details to add a new animal to the shelter.',
                        imageWidget: SvgPicture.asset(
                          'assets/images/Illustration-22.svg',
                          height: 160,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const SectionHeader(label: 'Basic info'),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _nameController,
                        label: 'Name',
                        validator: (value) =>
                            Validators.validateRequired(value?.trim(), "name"),
                      ),
                      const SizedBox(height: 16),
                      const FormLabel(label: 'Type'),
                      const SizedBox(height: 8),
                      AnimalTypeSelector(
                        selected: _animalType,
                        onChanged: (t) => setState(() => _animalType = t),
                      ),
                      const SizedBox(height: 16),
                      AppTextField(
                        controller: _breedController,
                        label: 'Breed',
                        validator: (value) =>
                            Validators.validateRequired(value?.trim(), "breed"),
                      ),
                      const SizedBox(height: 16),
                      DateField(
                        label: 'Birth date',
                        value: _birthDate,
                        lastDate: DateTime.now(),
                        onChanged: (d) => setState(() => _birthDate = d),
                      ),
                      const SizedBox(height: 28),
                      const SectionHeader(label: 'Shelter info'),
                      const SizedBox(height: 12),
                      _buildRefugeSelector(shelterAsync),
                      const SizedBox(height: 16),
                      DateField(
                        label: 'Arrival date',
                        value: _arrivalDate,
                        lastDate: DateTime.now(),
                        required: false,
                        onChanged: (d) => setState(() => _arrivalDate = d),
                      ),
                      const SizedBox(height: 16),
                      InAdoptionToggle(
                        value: _inAdoption,
                        onChanged: (v) => setState(() => _inAdoption = v),
                      ),
                      const SizedBox(height: 28),
                      const SectionHeader(label: 'About'),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _descriptionController,
                        label: 'Description',
                        validator: (value) => Validators.validateRequired(
                          value?.trim(),
                          "description",
                        ),
                      ),
                      const SizedBox(height: 16),
                      const FormLabel(label: 'Traits'),
                      const SizedBox(height: 8),
                      TraitsChipSelector(
                        selectedTraitIds: _selectedTraitIds,
                        onToggle: (id, isSelected) => setState(() {
                          isSelected
                              ? _selectedTraitIds.add(id)
                              : _selectedTraitIds.remove(id);
                        }),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(28, 8, 28, 20),
              child: PrimaryButton(
                label: 'Register Animal And Continue',
                isLoading: _isLoading,
                onPressed: _submit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefugeSelector(AsyncValue<Shelter> shelterAsync) {
    return shelterAsync.when(
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (_, _) => const Text(
        'Could not load refuges.',
        style: TextStyle(color: AppColors.error),
      ),
      data: (shelter) {
        if (shelter.refuges.isEmpty) {
          return const Text('No refuges available.');
        }
        return RefugeDropdown(
          items: shelter.refuges
              .map((r) => RefugeItem(id: r.id, name: r.name))
              .toList(),
          initialItem: _refugeId ?? shelter.refuges.first.id,
          onChanged: (v) => setState(() => _refugeId = v),
        );
      },
    );
  }
}
