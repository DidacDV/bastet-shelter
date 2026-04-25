import 'package:flutter/material.dart';

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

extension StepTypeDisplay on StepType {
  String get label => switch (this) {
    StepType.form => 'Form',
    StepType.interview => 'Interview',
    StepType.shelterVisit => 'Visit',
    StepType.contract => 'Contract',
    StepType.animalPickup => 'Pickup',
  };

  IconData get icon => switch (this) {
    StepType.form => Icons.description_outlined,
    StepType.interview => Icons.chat_outlined,
    StepType.shelterVisit => Icons.home_outlined,
    StepType.contract => Icons.handshake_outlined,
    StepType.animalPickup => Icons.pets_outlined,
  };
}
