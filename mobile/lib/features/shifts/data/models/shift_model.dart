import 'package:bastetshelter/features/shifts/data/models/shift_task_model.dart';

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

class ShiftDetail extends Shift {
  final List<ShiftTask> shiftTasks;
  final bool isJoined;

  const ShiftDetail({
    required super.id,
    required super.startTime,
    required super.endTime,
    required super.day,
    required super.refugeId,
    required super.currentParticipants,
    super.maxParticipants,
    this.shiftTasks = const [],
    this.isJoined = false,
  });

  factory ShiftDetail.fromJson(Map<String, dynamic> json) {
    return ShiftDetail(
      id: json['id'] as int,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: DateTime.parse(json['end_time'] as String),
      day: DateTime.parse(json['day'] as String),
      refugeId: json['refuge_id'] as int,
      maxParticipants: json['max_participants'] as int?,
      currentParticipants: json['current_participants'] as int,
      shiftTasks: json['shift_tasks'] != null
          ? ShiftTask.listFromJson(json['shift_tasks'] as List<dynamic>)
          : [],
      isJoined: json['is_joined'] as bool? ?? false,
    );
  }
}
