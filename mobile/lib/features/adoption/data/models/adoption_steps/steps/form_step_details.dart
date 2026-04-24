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
