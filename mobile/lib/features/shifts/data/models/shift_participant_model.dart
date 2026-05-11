class ShiftParticipant {
  final int id;
  final int shiftId;
  final int? volunteerId;

  const ShiftParticipant({
    required this.id,
    required this.shiftId,
    this.volunteerId,
  });

  factory ShiftParticipant.fromJson(Map<String, dynamic> json) {
    return ShiftParticipant(
      id: json['id'] as int,
      shiftId: json['shift_id'] as int,
      volunteerId: json['volunteer_id'] as int?,
    );
  }
}
