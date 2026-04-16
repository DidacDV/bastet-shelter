import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/animals/data/models/animal_details_model.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/components/animal_image_slider.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/components/manage_animal_images.dart';
import 'package:bastetshelter/features/common/components/app_editable_field.dart';
import 'package:bastetshelter/features/common/components/edit_bottom_sheet.dart';
import 'package:flutter/material.dart';

class AnimalDetailsHeader extends StatelessWidget {
  final bool canEdit;
  final AnimalDetails animal;
  final Future<void> Function(DateTime)? onArrivalDateSave;
  final Future<void> Function(DateTime)? onBirthdaySave;
  final Future<void> Function(String)? onNameSave;
  final List<String> imageUrls;

  const AnimalDetailsHeader({
    super.key,
    required this.imageUrls,
    required this.animal,
    this.canEdit = false,
    this.onArrivalDateSave,
    this.onBirthdaySave,
    this.onNameSave,
  });

  @override
  Widget build(BuildContext context) {
    final Color pillBackgroundColor = Theme.of(
      context,
    ).colorScheme.surface.withValues(alpha: 0.95);

    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(child: AnimalImageSlider(imageUrls: imageUrls)),

        if (canEdit)
          Positioned(
            top: statusBarHeight + 8,
            right: 16,
            child: Material(
              color: pillBackgroundColor,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ManageAnimalImagesScreen(
                      animalId: animal.id,
                      existingImages: animal.images,
                    ),
                  ),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.add_a_photo_outlined,
                    color: AppColors.primary,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),

        Positioned(
          bottom: 2,
          left: 2,
          right: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                decoration: BoxDecoration(
                  color: pillBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: EditableField(
                  label: 'Name',
                  value: animal.name,
                  isTitle: true,
                  canEdit: canEdit,
                  onEdit: () => showEditBottomSheet(
                    context: context,
                    label: "Name",
                    initialValue: animal.name,
                    onSave: (newVal) async {
                      await onNameSave?.call(newVal);
                    },
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _DateChip(
                      label: "Arrival",
                      date: animal.arrivalDate ?? animal.birthDate,
                      canEdit: canEdit,
                      backgroundColor: pillBackgroundColor,
                      onEdit: !canEdit
                          ? null
                          : () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate:
                                    animal.arrivalDate ?? animal.birthDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null && onArrivalDateSave != null) {
                                await onArrivalDateSave!(picked);
                              }
                            },
                    ),
                    _DateChip(
                      label: "Birthday",
                      date: animal.birthDate,
                      canEdit: canEdit,
                      backgroundColor: pillBackgroundColor,
                      onEdit: !canEdit
                          ? null
                          : () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: animal.birthDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (picked != null && onBirthdaySave != null) {
                                await onBirthdaySave!(picked);
                              }
                            },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DateChip extends StatelessWidget {
  final String label;
  final DateTime date;
  final bool canEdit;
  final Color backgroundColor;
  final VoidCallback? onEdit;

  const _DateChip({
    required this.label,
    required this.date,
    required this.backgroundColor,
    this.canEdit = false,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: tt.labelSmall?.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (canEdit) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.edit_outlined,
                      size: 13,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 4),
              Text(
                MaterialLocalizations.of(context).formatMediumDate(date),
                style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
