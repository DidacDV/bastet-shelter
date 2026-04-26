import 'package:bastetshelter/features/adoption/data/adoption_enums.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/adoption_step_details.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/form_step_details.dart';
import 'package:bastetshelter/features/adoption/presentation/components/steps/step_form_view.dart';
import 'package:flutter/material.dart';

class StepContent extends StatelessWidget {
  const StepContent({super.key, required this.step, required this.processId});
  final AdoptionStepDetails step;
  final int processId;

  @override
  Widget build(BuildContext context) {
    return switch (step.type) {
      StepType.form => FormStepView(
        step: step as FormStepDetails,
        processId: processId,
      ),
      // TODO: Handle this case.
      StepType.interview => throw UnimplementedError(),
      // TODO: Handle this case.
      StepType.shelterVisit => throw UnimplementedError(),
      // TODO: Handle this case.
      StepType.contract => throw UnimplementedError(),
      // TODO: Handle this case.
      StepType.animalPickup => throw UnimplementedError(),
    };
  }
}
