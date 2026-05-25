import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/form_step_details.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_process/components/show_form_details_bottomsheet.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_process/components/steps/step_common_info.dart';
import 'package:bastetshelter/features/common/components/primary_button.dart';
import 'package:bastetshelter/providers/adoption/form_step_content_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FormStepView extends ConsumerWidget {
  const FormStepView({super.key, required this.step, required this.processId});
  final FormStepDetails step;
  final int processId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StepCommonInfo(step: step, processId: processId),
        const SizedBox(height: 26),
        const Divider(),
        const SizedBox(height: 26),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: PrimaryButton(
            onPressed: () async {
              final content = await ref.read(
                formStepContentProvider(processId).future,
              );
              if (context.mounted) {
                showFormDetailsBottomSheet(context: context, content: content);
              }
            },
            label: context.l10n.t('adoption.viewFormDetails'),
            isLoading: false,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
