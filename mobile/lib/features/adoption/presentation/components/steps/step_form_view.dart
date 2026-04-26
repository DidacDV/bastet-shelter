import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/form_step_details.dart';
import 'package:bastetshelter/features/adoption/presentation/components/steps/step_common_info.dart';
import 'package:flutter/material.dart';

class FormStepView extends StatelessWidget {
  const FormStepView({super.key, required this.step, required this.processId});
  final FormStepDetails step;
  final int processId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        StepCommonInfo(step: step, processId: processId),
        const Divider(),
        // TODO: form specific info
      ],
    );
  }
}
