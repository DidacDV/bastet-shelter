class Shift {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final DateTime day;
  final int refugeId;
  final int? maxParticipants;
  final int currentParticipants;

  const Shift({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.day,
    required this.refugeId,
    required this.currentParticipants,
    this.maxParticipants,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] as int,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      day: DateTime.parse(json['day'] as String),
      refugeId: json['refuge_id'] as int,
      maxParticipants: json['max_participants'] as int?,
      currentParticipants: json['current_participants'] as int,
    );
  }

  static List<Shift> listFromJson(List<dynamic> list) =>
      list.map((e) => Shift.fromJson(e as Map<String, dynamic>)).toList();
}
