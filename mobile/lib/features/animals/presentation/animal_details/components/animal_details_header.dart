import 'dart:ui';

import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/animals/data/models/animal_details_model.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/components/animal_image_slider.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/components/manage_animal_images.dart';
import 'package:bastetshelter/features/common/components/app_editable_field.dart';
import 'package:bastetshelter/features/common/components/edit_bottom_sheet.dart';
import 'package:bastetshelter/features/common/components/fields/date_chip.dart';
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
    final Color pillBackgroundColor = Colors.white.withValues(alpha: 0.6);

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
                onTap: () => Navigator.of(context, rootNavigator: true).push(
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
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: EditableField(
                      label: context.l10n.t('common.name'),
                      value: animal.name,
                      isTitle: true,
                      canEdit: canEdit,
                      alignment: CrossAxisAlignment.center,
                      onEdit: () => showEditBottomSheet(
                        context: context,
                        label: context.l10n.t('common.name'),
                        initialValue: animal.name,
                        onSave: (newVal) async {
                          await onNameSave?.call(newVal);
                        },
                      ),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: DateChip(
                          label: context.l10n.t('animals.arrival'),
                          date: animal.arrivalDate ?? animal.birthDate,
                          canEdit: canEdit,
                          backgroundColor: Colors.white.withValues(alpha: 0.5),
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
                                  if (picked != null &&
                                      onArrivalDateSave != null) {
                                    await onArrivalDateSave!(picked);
                                  }
                                },
                        ),
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: DateChip(
                          label: context.l10n.t('animals.birthday'),
                          date: animal.birthDate,
                          canEdit: canEdit,
                          backgroundColor: Colors.white.withValues(alpha: 0.5),
                          onEdit: !canEdit
                              ? null
                              : () async {
                                  final picked = await showDatePicker(
                                    context: context,
                                    initialDate: animal.birthDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime.now(),
                                  );
                                  if (picked != null &&
                                      onBirthdaySave != null) {
                                    await onBirthdaySave!(picked);
                                  }
                                },
                        ),
                      ),
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
