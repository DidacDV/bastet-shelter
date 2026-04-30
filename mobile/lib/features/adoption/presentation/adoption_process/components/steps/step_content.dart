import 'package:bastetshelter/features/adoption/data/adoption_enums.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/adoption_step_details.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/animal_pickup_step_details.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/contract_step_details.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/form_step_details.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/interview_step_details.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/shelter_visit_step_details.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_process/components/steps/step_contract_view.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_process/components/steps/step_form_view.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_process/components/steps/step_interview_view.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_process/components/steps/step_pickup_view.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_process/components/steps/step_shelter_visit_view.dart';
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
      StepType.interview => InterviewStepView(
        step: step as InterviewStepDetails,
        processId: processId,
      ),
      StepType.shelterVisit => ShelterVisitStepView(
        step: step as ShelterVisitStepDetails,
        processId: processId,
      ),
      StepType.contract => ContractStepView(
        step: step as ContractStepDetails,
        processId: processId,
      ),
      StepType.animalPickup => AnimalPickupStepView(
        step: step as AnimalPickupStepDetails,
        processId: processId,
      ),
    };
  }
}
