import 'package:bastetshelter/features/adoption/data/adoption_enums.dart';

class AdoptionStepSummary {
  final int id;
  final StepType type;
  final StepStatus status;
  final int order;
  final DateTime? finishDate;
  final String? notes;
  final String? rejectionReason;

  const AdoptionStepSummary({
    required this.id,
    required this.type,
    required this.status,
    required this.order,
    this.finishDate,
    this.notes,
    this.rejectionReason,
  });

  factory AdoptionStepSummary.fromJson(Map<String, dynamic> json) {
    return AdoptionStepSummary(
      id: json['id'] as int,
      type: StepType.fromString(json['type'] as String),
      status: StepStatus.fromString(json['status'] as String),
      order: json['order'] as int,
      finishDate: json['finish_date'] != null
          ? DateTime.parse(json['finish_date'] as String)
          : null,
      notes: json['notes'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
    );
  }
}
