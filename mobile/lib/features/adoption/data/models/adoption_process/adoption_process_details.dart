import 'package:bastetshelter/features/adoption/data/adoption_enums.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/adoption_step_details.dart';

class AdoptionProcessDetails {
  final int id;
  final int animalId;
  final int adoptantId;
  final DateTime startDate;
  final DateTime? endDate;
  final AdoptionProcessStatus status;
  final List<AdoptionStepDetails> steps;

  const AdoptionProcessDetails({
    required this.id,
    required this.animalId,
    required this.adoptantId,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.steps,
  });

  factory AdoptionProcessDetails.fromJson(Map<String, dynamic> json) {
    return AdoptionProcessDetails(
      id: json['id'] as int,
      animalId: json['animal_id'] as int,
      adoptantId: json['adoptant_id'] as int,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      status: AdoptionProcessStatus.fromString(json['status'] as String),
      steps:
          (json['steps'] as List<dynamic>?)
              ?.map(
                (step) =>
                    AdoptionStepDetails.fromJson(step as Map<String, dynamic>),
              ) //should automatically cast to AdoptionStepDetails
              .toList() ??
          [],
    );
  }
}
