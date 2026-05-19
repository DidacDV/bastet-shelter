import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/common/components/illustrated_header.dart';
import 'package:bastetshelter/providers/geo/geo_provider.dart';
import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/core/utils/generic_api_call.dart';
import 'package:bastetshelter/core/utils/validators.dart';
import 'package:bastetshelter/features/common/components/dropdowns/location_dropdown.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:bastetshelter/features/shelter/data/shelter_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bastetshelter/features/common/components/fields/app_text_field.dart';

class CreateShelterScreen extends ConsumerStatefulWidget {
  const CreateShelterScreen({super.key});

  @override
  ConsumerState<CreateShelterScreen> createState() =>
      _CreateShelterScreenState();
}

class _CreateShelterScreenState extends ConsumerState<CreateShelterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _refugeNameController = TextEditingController();
  final _shelterRepository = getIt<ShelterRepository>();

  bool _isLoading = false;
  String? _selectedLocationId = AppConstants.defaultProvince;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
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
        _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
      );
      if (mounted) Navigator.pushReplacementNamed(context, '/home');
    });

    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final provincesAsync = ref.watch(geoProvider);

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
                      const SizedBox(height: 8),

                      IllustratedHeader(
                        imageWidget: SvgPicture.asset(
                          'assets/images/Illustration-8.svg',
                          height: 180,
                        ),
                        badgeLabel: context.l10n.t('shelter.newShelterBadge'),
                        title: context.l10n.t('shelter.setupTitle'),
                        subtitle: context.l10n.t('shelter.setupSubtitle'),
                      ),
                      const SizedBox(height: 32),

                      _FormLabel(label: context.l10n.t('shelter.name'), tt: tt),
                      const SizedBox(height: 6),
                      AppTextField(
                        controller: _nameController,
                        label: context.l10n.t('shelter.nameExample'),
                        keyboardType: TextInputType.name,
                        validator: (v) =>
                            Validators.validateRequired(v, "shelter's name"),
                      ),

                      const SizedBox(height: 20),

                      _FormLabel(
                        label: context.l10n.t('shelter.emailOptional'),
                        tt: tt,
                      ),
                      const SizedBox(height: 6),
                      AppTextField(
                        controller: _emailController,
                        label: 'contact@myshelter.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => Validators.validateEmailNoRequired(v),
                      ),

                      const SizedBox(height: 20),

                      _FormLabel(
                        label: context.l10n.t('shelter.province'),
                        tt: tt,
                      ),
                      const SizedBox(height: 6),
                      provincesAsync.when(
                        data: (provinces) => LocationDropdown(
                          items: provinces,
                          initialItem: AppConstants.defaultProvince,
                          onChanged: (value) =>
                              setState(() => _selectedLocationId = value),
                        ),
                        loading: () => const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        error: (e, _) => Text(
                          context.l10n.t('shelter.locationsLoadError'),
                          style: tt.bodySmall?.copyWith(color: AppColors.error),
                        ),
                      ),

                      const SizedBox(height: 20),

                      _FormLabel(
                        label: context.l10n.t('shelter.firstRefugeName'),
                        tt: tt,
                      ),
                      const SizedBox(height: 6),
                      AppTextField(
                        controller: _refugeNameController,
                        label: context.l10n.t('shelter.refugeNameExample'),
                        validator: (v) =>
                            Validators.validateRequired(v, "refuge name"),
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
                label: context.l10n.t('shelter.createShelter'),
                isLoading: _isLoading,
                onPressed: _createShelter,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String label;
  final TextTheme tt;
  const _FormLabel({required this.label, required this.tt});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: tt.labelMedium?.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
