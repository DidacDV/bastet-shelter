import 'package:bastetshelter/features/common/components/app_editable_field.dart';
import 'package:bastetshelter/features/common/components/edit_bottom_sheet.dart';
import 'package:flutter/material.dart';

class BasicInfoTab extends StatelessWidget {
  final int animalId;
  final bool isManager;

  const BasicInfoTab({
    super.key,
    required this.animalId,
    this.isManager = true,
  });

  @override
  Widget build(BuildContext context) {
    const mockBreed = "Mixed Beagle";
    const mockDescription =
        "Mochi is a very sweet and energetic puppy. She loves to play fetch and is already house-trained. Needs a family with a big yard.";
    final mockTraitIds = [1, 3];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EditableField(
            label: "Breed",
            value: mockBreed,
            canEdit: isManager,
            onEdit: () => showEditBottomSheet(
              context: context,
              label: "Breed",
              initialValue: mockBreed,
              onSave: (newValue) async {},
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),

          EditableField(
            label: "Description",
            value: mockDescription,
            canEdit: isManager,
            onEdit: () => showEditBottomSheet(
              context: context,
              label: "Description",
              initialValue: mockDescription,
              keyboardType: TextInputType.multiline,
              onSave: (newValue) async {},
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Divider(height: 1),
          ),
        ],
      ),
    );
  }
}
