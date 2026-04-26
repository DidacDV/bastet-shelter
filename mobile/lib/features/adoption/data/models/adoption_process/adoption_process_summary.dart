import 'package:bastetshelter/features/adoption/data/adoption_enums.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/adoption_step_summary.dart';

class AdoptionProcessSummary {
  final int id;
  final int animalId;
  final String animalName;
  final String? animalImageUrl;
  final int adoptantId;
  final String adoptantName;
  final DateTime startDate;
  final DateTime? endDate;
  final AdoptionProcessStatus status;
  final List<AdoptionStepSummary> steps;

  AdoptionStepSummary? get currentStep =>
      steps.where((s) => s.status == StepStatus.pending).firstOrNull;

  const AdoptionProcessSummary({
    required this.id,
    required this.animalId,
    required this.animalName,
    this.animalImageUrl,
    required this.adoptantId,
    required this.adoptantName,
    required this.startDate,
    this.endDate,
    required this.status,
    required this.steps,
  });

  factory AdoptionProcessSummary.fromJson(Map<String, dynamic> json) {
    return AdoptionProcessSummary(
      id: json['id'] as int,
      animalId: json['animal_id'] as int,
      animalName: json['animal_name'] as String,
      animalImageUrl: json['animal_image_url'] as String?,
      adoptantId: json['adoptant_id'] as int,
      adoptantName: json['adoptant_name'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      status: AdoptionProcessStatus.fromString(json['status'] as String),
      steps:
          (json['steps'] as List<dynamic>?)
              ?.map(
                (step) =>
                    AdoptionStepSummary.fromJson(step as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  static List<AdoptionProcessSummary> listFromJson(List<dynamic> list) {
    return list
        .map((e) => AdoptionProcessSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
