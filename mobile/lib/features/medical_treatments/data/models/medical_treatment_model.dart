enum MedicineFrequency {
  daily('DAILY', 'Daily'),
  weekly('WEEKLY', 'Weekly'),
  monthly('MONTHLY', 'Monthly'),
  asNeeded('AS_NEEDED', 'As needed');

  final String value;
  final String label;

  const MedicineFrequency(this.value, this.label);

  factory MedicineFrequency.fromString(String val) {
    return MedicineFrequency.values.firstWhere(
      (e) => e.value == val,
      orElse: () => MedicineFrequency.asNeeded,
    );
  }
}

enum MedicineStatus {
  given('GIVEN', 'Given'),
  pending('PENDING', 'Pending');

  final String value;
  final String label;

  const MedicineStatus(this.value, this.label);

  factory MedicineStatus.fromString(String val) {
    return MedicineStatus.values.firstWhere(
      (e) => e.value == val,
      orElse: () => MedicineStatus.pending,
    );
  }
}

enum DosageUnit {
  mg('MG', 'mg'),
  ml('ML', 'ml'),
  drops('DROPS', 'drops'),
  units('UNITS', 'units');

  final String value;
  final String label;

  const DosageUnit(this.value, this.label);

  factory DosageUnit.fromString(String val) {
    return DosageUnit.values.firstWhere(
      (e) => e.value == val,
      orElse: () => DosageUnit.units,
    );
  }
}

class MedicalTreatment {
  final int id;
  final int animalId;
  final int medicineId;
  final String medicineName;
  final MedicineFrequency frequency;
  final MedicineStatus status;
  final DateTime statusUpdatedAt;
  final String? statusLastUpdatedByName;
  final DateTime startDate;
  final DateTime? endDate;
  final double dosage;
  final DosageUnit dosageUnit;

  MedicalTreatment({
    required this.id,
    required this.animalId,
    required this.medicineId,
    required this.medicineName,
    required this.frequency,
    required this.status,
    required this.statusUpdatedAt,
    this.statusLastUpdatedByName,
    required this.startDate,
    this.endDate,
    required this.dosage,
    required this.dosageUnit,
  });

  factory MedicalTreatment.fromJson(Map<String, dynamic> json) {
    return MedicalTreatment(
      id: json['id'] as int,
      animalId: json['animal_id'] as int,
      medicineId: json['medicine_id'] as int,
      medicineName: json['medicine_name'] as String,
      frequency: MedicineFrequency.fromString(json['frequency'] as String),
      status: MedicineStatus.fromString(json['status'] as String),
      statusUpdatedAt: DateTime.parse(json['status_updated_at'] as String),
      statusLastUpdatedByName: json['status_last_updated_by_name'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      dosage: (json['dosage'] as num).toDouble(),
      dosageUnit: DosageUnit.fromString(json['dosage_unit'] as String),
    );
  }

  static List<MedicalTreatment> listFromJson(List<dynamic> list) => list
      .map((t) => MedicalTreatment.fromJson(t as Map<String, dynamic>))
      .toList();

  Map<String, dynamic> toJson() {
    return {
      'animal_id': animalId,
      'medicine_id': medicineId,
      'frequency': frequency.value,
      'status': status.value,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate?.toIso8601String().split('T')[0],
      'dosage': dosage,
      'dosage_unit': dosageUnit.value,
    };
  }

  MedicalTreatment copyWith({
    int? id,
    int? animalId,
    int? medicineId,
    String? medicineName,
    MedicineFrequency? frequency,
    MedicineStatus? status,
    DateTime? statusUpdatedAt,
    String? statusLastUpdatedByName,
    DateTime? startDate,
    DateTime? endDate,
    double? dosage,
    DosageUnit? dosageUnit,
  }) {
    return MedicalTreatment(
      id: id ?? this.id,
      animalId: animalId ?? this.animalId,
      medicineId: medicineId ?? this.medicineId,
      medicineName: medicineName ?? this.medicineName,
      frequency: frequency ?? this.frequency,
      status: status ?? this.status,
      statusUpdatedAt: statusUpdatedAt ?? this.statusUpdatedAt,
      statusLastUpdatedByName:
          statusLastUpdatedByName ?? this.statusLastUpdatedByName,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      dosage: dosage ?? this.dosage,
      dosageUnit: dosageUnit ?? this.dosageUnit,
    );
  }
}
