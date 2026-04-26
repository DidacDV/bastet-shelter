import 'package:bastetshelter/features/adoption/data/adoption_enums.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/adoption_step_details.dart';

class FormStepDetails extends AdoptionStepDetails {
  final bool? accepted;

  const FormStepDetails({
    required super.id,
    required super.type,
    required super.status,
    required super.order,
    super.finishDate,
    super.notes,
    super.rejectionReason,
    super.isCurrent,
    this.accepted,
  });

  factory FormStepDetails.fromJson(Map<String, dynamic> json) {
    return FormStepDetails(
      id: json['id'] as int,
      type: StepType.fromString(json['type'] as String),
      status: StepStatus.fromString(json['status'] as String),
      order: json['order'] as int,
      finishDate: json['finish_date'] != null
          ? DateTime.parse(json['finish_date'] as String)
          : null,
      notes: json['notes'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
      isCurrent: (json['is_current'] as bool?) ?? false,
      accepted: json['accepted'] as bool?,
    );
  }
}

class AdoptionFormContent {
  final int id;
  final bool accepted;
  final String? housingType;
  final bool? hasGarden;
  final bool? hasOtherPets;
  final String? otherPetsDescription;
  final bool? hasChildren;
  final String? childrenAges;
  final bool? previousPetExperience;
  final int? hoursAlonePerDay;
  final String? reasonForAdoption;

  const AdoptionFormContent({
    required this.id,
    required this.accepted,
    this.housingType,
    this.hasGarden,
    this.hasOtherPets,
    this.otherPetsDescription,
    this.hasChildren,
    this.childrenAges,
    this.previousPetExperience,
    this.hoursAlonePerDay,
    this.reasonForAdoption,
  });

  factory AdoptionFormContent.fromJson(Map<String, dynamic> json) {
    return AdoptionFormContent(
      id: json['id'] as int,
      accepted: json['accepted'] as bool? ?? false,
      housingType: json['housing_type'] as String?,
      hasGarden: json['has_garden'] as bool?,
      hasOtherPets: json['has_other_pets'] as bool?,
      otherPetsDescription: json['other_pets_description'] as String?,
      hasChildren: json['has_children'] as bool?,
      childrenAges: json['children_ages'] as String?,
      previousPetExperience: json['previous_pet_experience'] as bool?,
      hoursAlonePerDay: json['hours_alone_per_day'] as int?,
      reasonForAdoption: json['reason_for_adoption'] as String?,
    );
  }
}
