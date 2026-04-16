import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/navigation_service.dart';
import 'package:bastetshelter/features/animals/data/models/animal_image_model.dart';
import 'package:bastetshelter/features/common/components/confirmation_dialog.dart';
import 'package:bastetshelter/providers/animals/animal_details_provider.dart';
import 'package:bastetshelter/providers/animals/animal_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class ManageAnimalImagesScreen extends ConsumerStatefulWidget {
  final int animalId;
  final List<AnimalImage> existingImages;

  const ManageAnimalImagesScreen({
    super.key,
    required this.animalId,
    required this.existingImages,
  });

  @override
  ConsumerState<ManageAnimalImagesScreen> createState() =>
      _ManageAnimalImagesScreenState();
}

class _ManageAnimalImagesScreenState
    extends ConsumerState<ManageAnimalImagesScreen> {
  final ImagePicker _picker = ImagePicker();
  final int _maxImages = 4;

  bool _isLoading = false;

  Future<void> _addNewImage() async {
    if (widget.existingImages.length >= _maxImages) return;

    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile != null) {
        setState(() => _isLoading = true);

        await ref.read(animalsProvider.notifier).uploadAnimalImages(
          widget.animalId,
          [pickedFile],
        );

        NavigationService.instance.showSnackBar('Image added successfully!');
      }
    } catch (e) {
      NavigationService.instance.showSnackBar(
        'Error picking image',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteImage(AnimalImage image) async {
    final confirm = await ConfirmationDialog.show(
      context: context,
      title: 'Delete Photo',
      message:
          'Are you sure you want to delete this photo? This cannot be undone.',
      isDestructive: true,
      confirmText: 'Delete',
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(animalsProvider.notifier)
          .deleteAnimalImage(widget.animalId, image.id);

      NavigationService.instance.showSnackBar('Image deleted');
    } catch (e) {
      NavigationService.instance.showSnackBar(
        'Failed to delete image',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final animalDetailsAsync = ref.watch(animalDetailProvider(widget.animalId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : animalDetailsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) =>
                  const Center(child: Text('Could not load images.')),
              data: (animal) {
                final currentImages = animal.images;

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Photos',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add up to $_maxImages photos. Delete existing ones to make room.',
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
                        itemCount: currentImages.length < _maxImages
                            ? currentImages.length + 1
                            : _maxImages,
                        itemBuilder: (context, index) {
                          if (index == currentImages.length) {
                            return _buildAddImageButton();
                          }
                          return _buildExistingImagePreview(
                            currentImages[index],
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _buildAddImageButton() {
    return InkWell(
      onTap: _addNewImage,
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
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_a_photo_rounded, color: AppColors.primary),
            SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(
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

  Widget _buildExistingImagePreview(AnimalImage image) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(image.url, fit: BoxFit.cover),
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
                Icons.delete_forever_rounded,
                size: 16,
                color: AppColors.error,
              ),
            ),
            onPressed: () => _deleteImage(image),
          ),
        ),
      ],
    );
  }
}
