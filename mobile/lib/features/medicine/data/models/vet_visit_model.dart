enum VetVisitType {
  generalCheckup('GENERAL_CHECKUP', 'General Checkup'),
  vaccine('VACCINE', 'Vaccine'),
  surgery('SURGERY', 'Surgery'),
  dental('DENTAL', 'Dental'),
  emergency('EMERGENCY', 'Emergency'),
  other('OTHER', 'Other');

  final String value;
  final String label;

  const VetVisitType(this.value, this.label);

  factory VetVisitType.fromString(String val) {
    return VetVisitType.values.firstWhere(
      (e) => e.value == val,
      orElse: () => VetVisitType.other,
    );
  }
}

class VetVisit {
  final int id;
  final int animalId;
  final DateTime visitDate;
  final VetVisitType visitType;
  final String clinicName;
  final String? notes;

  VetVisit({
    required this.id,
    required this.animalId,
    required this.visitDate,
    required this.visitType,
    required this.clinicName,
    this.notes,
  });

  factory VetVisit.fromJson(Map<String, dynamic> json) {
    return VetVisit(
      id: json['id'] as int,
      animalId: json['animal_id'] as int,
      visitDate: DateTime.parse(json['visit_date'] as String),
      visitType: VetVisitType.fromString(json['visit_type'] as String),
      clinicName: json['clinic_name'] as String,
      notes: json['notes'] as String?,
    );
  }

  static List<VetVisit> listFromJson(List<dynamic> list) => list
      .map((vetVisit) => VetVisit.fromJson(vetVisit as Map<String, dynamic>))
      .toList();

  Map<String, dynamic> toJson() {
    return {
      'animal_id': animalId,
      'visit_date': visitDate.toIso8601String().split('T')[0],
      'visit_type': visitType.value,
      'clinic_name': clinicName,
      'notes': notes,
    };
  }

  VetVisit copyWith({
    int? id,
    int? animalId,
    DateTime? visitDate,
    VetVisitType? visitType,
    String? clinicName,
    String? notes,
  }) {
    return VetVisit(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      visitDate: visitDate ?? this.visitDate,
      visitType: visitType ?? this.visitType,
      clinicName: clinicName ?? this.clinicName,
      notes: notes ?? this.notes,
    );
  }
}
