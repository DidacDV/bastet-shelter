import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/bottom_sheet/form_bottom_sheet.dart';
import 'package:bastetshelter/features/common/components/fields/app_text_field.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:bastetshelter/features/community/data/advertisement_model.dart';
import 'package:bastetshelter/providers/community/advertisement_provider.dart';
import 'package:bastetshelter/providers/community/my_advertisements_provider.dart';
import 'package:bastetshelter/providers/geo/geo_provider.dart';
import 'package:bastetshelter/features/common/components/dropdowns/location_dropdown.dart';
import 'package:bastetshelter/features/common/components/layout/api_error_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/core/localization/localized_mappers.dart';

void showCreateAdvertisementSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const CreateAdvertisementBottomSheet(),
  );
}

class CreateAdvertisementBottomSheet extends ConsumerStatefulWidget {
  const CreateAdvertisementBottomSheet({super.key});

  @override
  ConsumerState<CreateAdvertisementBottomSheet> createState() =>
      _CreateAdvertisementBottomSheetState();
}

class _CreateAdvertisementBottomSheetState
    extends ConsumerState<CreateAdvertisementBottomSheet> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  AdCategory _selectedCategory = AdCategory.other;
  String? _selectedProvinceId = AppConstants.defaultProvince;
  XFile? _selectedImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProvinceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.t('community.selectLocation'))),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final provinces = ref.read(geoProvider).value ?? [];
      final provinceName = provinces
          .firstWhere(
            (p) => p.id == _selectedProvinceId,
            orElse: () => provinces.first,
          )
          .name;

      final notifier = ref.read(advertisementsProvider.notifier);

      final adId = await notifier.createAdvertisement(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        provinceName: provinceName,
      );

      if (adId != null && _selectedImage != null) {
        await notifier.uploadImage(adId, _selectedImage!);
      }

      //since we addded an image & advertisement
      ref.invalidate(myAdvertisementsProvider);

      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provincesAsync = ref.watch(geoProvider);
    final theme = Theme.of(context);

    return FormBottomSheet(
      title: context.l10n.t('community.createAdvertisement'),
      actions: [
        PrimaryButton(
          label: context.l10n.t('community.publishAdvertisement'),
          isLoading: _isLoading,
          onPressed: _submit,
        ),
      ],
      children: [
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ImagePickerBox(
                selectedImage: _selectedImage,
                onImagePicked: (file) => setState(() => _selectedImage = file),
                onImageRemoved: () => setState(() => _selectedImage = null),
              ),
              const SizedBox(height: 24),

              AppTextField(
                controller: _titleController,
                label: context.l10n.t('community.title'),
                hintText: context.l10n.t('community.titleHint'),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return context.l10n.t('community.titleRequired');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 2,
                    child: _CategoryDropdown(
                      value: _selectedCategory,
                      onChanged: (val) {
                        if (val != null) {
                          setState(() => _selectedCategory = val);
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.t('common.location'),
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        provincesAsync.when(
                          data: (provinceList) {
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
                          loading: () => const SizedBox(
                            height: 50,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                          error: (e, stack) => ApiErrorWidget(
                            error: e,
                            onRetry: () => ref.invalidate(geoProvider),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              AppTextField(
                controller: _descriptionController,
                label: context.l10n.t('common.description'),
                hintText: context.l10n.t('community.descriptionHint'),
                maxLines: 4,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return context.l10n.t('community.descriptionRequired');
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final AdCategory value;
  final ValueChanged<AdCategory?> onChanged;

  const _CategoryDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.t('community.category'),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<AdCategory>(
          initialValue: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.surface,
          ),
          items: AdCategory.values.map((cat) {
            return DropdownMenuItem(
              value: cat,
              child: Text(
                context.localizedAdCategory(cat),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _ImagePickerBox extends StatelessWidget {
  final XFile? selectedImage;
  final ValueChanged<XFile?> onImagePicked;
  final VoidCallback onImageRemoved;

  const _ImagePickerBox({
    required this.selectedImage,
    required this.onImagePicked,
    required this.onImageRemoved,
  });

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final file = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (file != null) onImagePicked(file);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (selectedImage != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(selectedImage!.path),
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: IconButton.filled(
              onPressed: onImageRemoved,
              icon: const Icon(Icons.close_rounded, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    }

    return InkWell(
      onTap: _pickImage,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.primaryTint,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_photo_alternate_outlined,
              size: 36,
              color: AppColors.primary,
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.t('community.addCoverPhoto'),
              style: theme.textTheme.titleSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.t('community.optionalRecommended'),
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
