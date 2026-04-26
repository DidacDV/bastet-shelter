import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/form_step_details.dart';
import 'package:bastetshelter/features/common/components/bottom_sheet/form_bottom_sheet.dart';
import 'package:bastetshelter/features/common/components/fields/label_value.dart';
import 'package:flutter/material.dart';

Future<void> showFormDetailsBottomSheet({
  required BuildContext context,
  required AdoptionFormContent content,
}) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _FormDetailsBottomSheet(content: content),
  );
}

class _FormDetailsBottomSheet extends StatelessWidget {
  final AdoptionFormContent content;
  const _FormDetailsBottomSheet({required this.content});

  String _bool(bool? v) => v == null ? '—' : (v ? 'Yes' : 'No');

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return FormBottomSheet(
      title: 'Adoption Form',
      actions: [],
      children: [
        _Section(label: 'Living situation', tt: tt),
        LabelValue(label: 'Housing type', value: content.housingType ?? '—'),
        const SizedBox(height: 10),
        LabelValue(label: 'Has garden', value: _bool(content.hasGarden)),
        const SizedBox(height: 10),
        LabelValue(label: 'Has children', value: _bool(content.hasChildren)),
        if (content.hasChildren == true && content.childrenAges != null) ...[
          const SizedBox(height: 10),
          LabelValue(label: 'Children ages', value: content.childrenAges!),
        ],

        const SizedBox(height: 20),

        _Section(label: 'Other pets', tt: tt),
        LabelValue(label: 'Has other pets', value: _bool(content.hasOtherPets)),
        if (content.hasOtherPets == true &&
            content.otherPetsDescription != null) ...[
          const SizedBox(height: 10),
          LabelValue(
            label: 'Description',
            value: content.otherPetsDescription!,
          ),
        ],

        const SizedBox(height: 20),

        _Section(label: 'Experience & availability', tt: tt),
        LabelValue(
          label: 'Previous experience',
          value: _bool(content.previousPetExperience),
          spacing: 8,
        ),
        const SizedBox(height: 10),
        LabelValue(
          label: 'Hours alone / day',
          value: content.hoursAlonePerDay?.toString() ?? '—',
          spacing: 8,
        ),

        const SizedBox(height: 20),

        _Section(label: 'Reason for adoption', tt: tt),
        Text(
          content.reasonForAdoption ?? '—',
          style: tt.bodyMedium?.copyWith(
            color: AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  final String label;
  final TextTheme tt;
  const _Section({required this.label, required this.tt});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        label.toUpperCase(),
        style: tt.labelSmall?.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 1.1,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
