enum AdoptionProcessStatus {
  pending('PENDING'),
  completed('COMPLETED'),
  cancelled('CANCELLED'),
  rejected('REJECTED');

  final String value;
  const AdoptionProcessStatus(this.value);

  factory AdoptionProcessStatus.fromString(String val) {
    return values.firstWhere(
      (e) => e.value == val,
      orElse: () => AdoptionProcessStatus.pending,
    );
  }
}

enum StepType {
  form('FORM'),
  interview('INTERVIEW'),
  shelterVisit('SHELTER_VISIT'),
  contract('CONTRACT'),
  animalPickup('ANIMAL_PICKUP');

  final String value;
  const StepType(this.value);

  factory StepType.fromString(String val) {
    return values.firstWhere(
      (e) => e.value == val,
      orElse: () => StepType.form,
    );
  }
}

enum StepStatus {
  pending('PENDING'),
  completed('COMPLETED'),
  rejected('REJECTED'),
  skipped('SKIPPED');

  final String value;
  const StepStatus(this.value);

  factory StepStatus.fromString(String val) {
    return values.firstWhere(
      (e) => e.value == val,
      orElse: () => StepStatus.pending,
    );
  }
}
