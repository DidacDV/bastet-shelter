class AdoptionFormSubmit {
  final String? housingType;
  final bool? hasGarden;
  final bool? hasOtherPets;
  final String? otherPetsDescription;
  final bool? hasChildren;
  final String? childrenAges;
  final bool? previousPetExperience;
  final int? hoursAlonePerDay;
  final String? reasonForAdoption;

  const AdoptionFormSubmit({
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

  Map<String, dynamic> toJson() {
    return {
      if (housingType != null) 'housing_type': housingType,
      if (hasGarden != null) 'has_garden': hasGarden,
      if (hasOtherPets != null) 'has_other_pets': hasOtherPets,
      if (otherPetsDescription != null)
        'other_pets_description': otherPetsDescription,
      if (hasChildren != null) 'has_children': hasChildren,
      if (childrenAges != null) 'children_ages': childrenAges,
      if (previousPetExperience != null)
        'previous_pet_experience': previousPetExperience,
      if (hoursAlonePerDay != null) 'hours_alone_per_day': hoursAlonePerDay,
      if (reasonForAdoption != null) 'reason_for_adoption': reasonForAdoption,
    };
  }
}

class ScheduledDateUpdate {
  final DateTime scheduledAt;

  const ScheduledDateUpdate({required this.scheduledAt});

  Map<String, dynamic> toJson() {
    return {
      'scheduled_at': scheduledAt
          .toUtc()
          .toIso8601String(), //needed for FASTAPI to accept it
    };
  }
}

class NotesUpdate {
  final String notes;

  const NotesUpdate({required this.notes});

  Map<String, dynamic> toJson() {
    return {'notes': notes};
  }
}

class AdvanceStepRequest {
  final String? notes;

  const AdvanceStepRequest({this.notes});

  Map<String, dynamic> toJson() {
    return {if (notes != null) 'notes': notes};
  }
}

class RejectionRequest {
  final String reason;

  const RejectionRequest({required this.reason});

  Map<String, dynamic> toJson() {
    return {'reason': reason};
  }
}
