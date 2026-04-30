import 'package:bastetshelter/features/adoption/data/adoption_enums.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/adoption_step_details.dart';

class ContractStepDetails extends AdoptionStepDetails {
  final bool? signedByAdoptant;
  final bool? signedByShelter;
  final String? contractUrl;

  const ContractStepDetails({
    required super.id,
    required super.type,
    required super.status,
    required super.order,
    super.finishDate,
    super.notes,
    super.rejectionReason,
    super.isCurrent,
    this.signedByAdoptant,
    this.signedByShelter,
    this.contractUrl,
  });

  factory ContractStepDetails.fromJson(Map<String, dynamic> json) {
    return ContractStepDetails(
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
      signedByAdoptant: json['signed_by_adoptant'] as bool?,
      signedByShelter: json['signed_by_shelter'] as bool?,
      contractUrl: json['contract_url'] as String?,
    );
  }
}
