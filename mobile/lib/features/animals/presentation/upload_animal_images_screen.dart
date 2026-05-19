import 'dart:io';
import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/core/navigation_service.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:bastetshelter/features/home/presentation/home_screen.dart';
import 'package:bastetshelter/providers/animals/animal_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class UploadAnimalImagesScreen extends ConsumerStatefulWidget {
  final int animalId;

  const UploadAnimalImagesScreen({super.key, required this.animalId});

  @override
  ConsumerState<UploadAnimalImagesScreen> createState() =>
      _UploadAnimalImagesScreenState();
}

class _UploadAnimalImagesScreenState
    extends ConsumerState<UploadAnimalImagesScreen> {
  final ImagePicker _picker = ImagePicker();

  List<XFile> _selectedImages = [];
  bool _isLoading = false;

  final int _maxImages = 4;

  Future<void> _pickImages() async {
    if (_selectedImages.length >= _maxImages) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n
                .t('animals.maxImages')
                .replaceAll('{count}', '$_maxImages'),
          ),
        ),
      );
      return;
    }

    try {
      final List<XFile> pickedFiles = await _picker.pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(pickedFiles);
          if (_selectedImages.length > _maxImages) {
            _selectedImages = _selectedImages.sublist(0, _maxImages);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  context.l10n
                      .t('animals.limitedImages')
                      .replaceAll('{count}', '$_maxImages'),
                ),
              ),
            );
          }
        });
      }
    } catch (e) {
      NavigationService.instance.showSnackBar(
        context.l10n.t('animals.pickImagesError'),
        isError: true,
      );
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) return;

    setState(() => _isLoading = true);

    await ref
        .read(animalsProvider.notifier)
        .uploadAnimalImages(widget.animalId, _selectedImages);

    if (mounted) {
      NavigationService.instance.showSnackBar(
        context.l10n.t('animals.imagesUploaded'),
      );
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => const HomeScreen(initialIndex: 1),
        ),
        (route) => false,
      );
    }

    if (mounted) setState(() => _isLoading = false);
  }

  void _skipOrFinish() {
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) =>
            const HomeScreen(initialIndex: AppConstants.animalsTab),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _skipOrFinish();
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(context.l10n.t('animals.photosTitle')),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: _skipOrFinish,
          ),
          actions: [
            TextButton(
              onPressed: _skipOrFinish,
              child: Text(
                context.l10n.t('common.skip'),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.t('animals.uploadPhotosTitle'),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n
                          .t('animals.uploadPhotosSubtitle')
                          .replaceAll('{count}', '$_maxImages'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.0,
                          ),
                      itemCount: _selectedImages.length < _maxImages
                          ? _selectedImages.length + 1
                          : _maxImages,
                      itemBuilder: (context, index) {
                        if (index == _selectedImages.length) {
                          return _buildAddImageButton();
                        }

                        return _buildImagePreview(index);
                      },
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24.0),
              child: PrimaryButton(
                label: context.l10n.t('animals.uploadImages'),
                isLoading: _isLoading,
                onPressed: _selectedImages.isEmpty ? null : _uploadImages,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddImageButton() {
    return InkWell(
      onTap: _pickImages,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryTint,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.3),
            style: BorderStyle.solid,
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_a_photo_rounded, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              context.l10n.t('common.add'),
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePreview(int index) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(_selectedImages[index].path),
            fit: BoxFit.cover,
          ),
        ),

        Positioned(
          top: -4,
          right: -4,
          child: IconButton(
            icon: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 16,
                color: AppColors.error,
              ),
            ),
            onPressed: () => _removeImage(index),
          ),
        ),
      ],
    );
  }
}
