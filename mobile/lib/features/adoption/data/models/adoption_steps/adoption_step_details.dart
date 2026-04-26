import 'package:bastetshelter/features/adoption/data/adoption_enums.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/animal_pickup_step_details.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/contract_step_details.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/form_step_details.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/interview_step_details.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/steps/shelter_visit_step_details.dart';

class AdoptionStepDetails {
  final int id;
  final StepType type;
  final StepStatus status;
  final int order;
  final DateTime? finishDate;
  final String? notes;
  final String? rejectionReason;
  final bool isCurrent;

  const AdoptionStepDetails({
    required this.id,
    required this.type,
    required this.status,
    required this.order,
    this.finishDate,
    this.notes,
    this.rejectionReason,
    this.isCurrent = false,
  });

  factory AdoptionStepDetails.fromJson(Map<String, dynamic> json) {
    final type = StepType.fromString(json['type'] as String);

    switch (type) {
      case StepType.form:
        return FormStepDetails.fromJson(json);
      case StepType.interview:
        return InterviewStepDetails.fromJson(json);
      case StepType.shelterVisit:
        return ShelterVisitStepDetails.fromJson(json);
      case StepType.contract:
        return ContractStepDetails.fromJson(json);
      case StepType.animalPickup:
        return AnimalPickupStepDetails.fromJson(json);
    }
  }

  String getStepName() {
    switch (type) {
      case StepType.form:
        return 'Form';
      case StepType.interview:
        return 'Interview';
      case StepType.shelterVisit:
        return 'Shelter Visit';
      case StepType.contract:
        return 'Contract';
      case StepType.animalPickup:
        return "Animal pick up";
    }
  }
}
