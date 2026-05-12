class ShiftParticipant {
  final int id;
  final int shiftId;
  final int? volunteerId;
  final String? name;
  final String? lastName1;

  const ShiftParticipant({
    required this.id,
    required this.shiftId,
    this.volunteerId,
    this.name,
    this.lastName1,
  });

  String get displayName => [
    name,
    lastName1,
  ].where((s) => s != null && s.isNotEmpty).join(' ').trim();

  factory ShiftParticipant.fromJson(Map<String, dynamic> json) {
    return ShiftParticipant(
      id: json['id'] as int,
      shiftId: json['shift_id'] as int,
      volunteerId: json['volunteer_id'] as int?,
      name: json['name'] as String?,
      lastName1: json['last_name_1'] as String?,
    );
  }
}
