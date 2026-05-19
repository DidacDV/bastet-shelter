import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
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

  String _bool(BuildContext context, bool? v) {
    if (v == null) return '—';
    return v ? context.l10n.t('common.yes') : context.l10n.t('common.no');
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return FormBottomSheet(
      title: context.l10n.t('adoption.formTitle'),
      actions: [],
      children: [
        _Section(label: context.l10n.t('adoption.livingSituation'), tt: tt),
        LabelValue(
          label: context.l10n.t('adoption.housingType'),
          value: content.housingType ?? '—',
        ),
        const SizedBox(height: 10),
        LabelValue(
          label: context.l10n.t('adoption.hasGarden'),
          value: _bool(context, content.hasGarden),
        ),
        const SizedBox(height: 10),
        LabelValue(
          label: context.l10n.t('adoption.hasChildren'),
          value: _bool(context, content.hasChildren),
        ),
        if (content.hasChildren == true && content.childrenAges != null) ...[
          const SizedBox(height: 10),
          LabelValue(
            label: context.l10n.t('adoption.childrenAges'),
            value: content.childrenAges!,
          ),
        ],

        const SizedBox(height: 20),

        _Section(label: context.l10n.t('adoption.otherPets'), tt: tt),
        LabelValue(
          label: context.l10n.t('adoption.hasOtherPets'),
          value: _bool(context, content.hasOtherPets),
        ),
        if (content.hasOtherPets == true &&
            content.otherPetsDescription != null) ...[
          const SizedBox(height: 10),
          LabelValue(
            label: context.l10n.t('common.description'),
            value: content.otherPetsDescription!,
          ),
        ],

        const SizedBox(height: 20),

        _Section(
          label: context.l10n.t('adoption.experienceAvailability'),
          tt: tt,
        ),
        LabelValue(
          label: context.l10n.t('adoption.previousExperience'),
          value: _bool(context, content.previousPetExperience),
          spacing: 8,
        ),
        const SizedBox(height: 10),
        LabelValue(
          label: context.l10n.t('adoption.hoursAlonePerDay'),
          value: content.hoursAlonePerDay?.toString() ?? '—',
          spacing: 8,
        ),

        const SizedBox(height: 20),

        _Section(label: context.l10n.t('adoption.reasonForAdoption'), tt: tt),
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
