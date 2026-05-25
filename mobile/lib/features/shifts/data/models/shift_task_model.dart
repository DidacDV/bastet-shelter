import 'package:bastetshelter/features/animals/data/models/animal_summary_model.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_participant_model.dart';
import 'package:bastetshelter/features/tasks/data/task_model.dart';

enum ShiftTaskStatus { notCompleted, completed }

ShiftTaskStatus _statusFromJson(String raw) => switch (raw) {
  'COMPLETED' => ShiftTaskStatus.completed,
  _ => ShiftTaskStatus.notCompleted,
};

class ShiftTask {
  final int id;
  final ShiftTaskStatus status;
  final DateTime assignedDate;
  final int shiftId;
  final int taskId;
  final Task task;
  final ShiftParticipant? participant;
  final AnimalSummary? animal;

  const ShiftTask({
    required this.id,
    required this.status,
    required this.assignedDate,
    required this.shiftId,
    required this.taskId,
    required this.task,
    this.participant,
    this.animal,
  });

  factory ShiftTask.fromJson(Map<String, dynamic> json) {
    return ShiftTask(
      id: json['id'] as int,
      status: _statusFromJson(json['status'] as String),
      assignedDate: DateTime.parse(json['assigned_date'] as String),
      shiftId: json['shift_id'] as int,
      taskId: json['task_id'] as int,
      task: Task.fromJson(json['task'] as Map<String, dynamic>),
      participant: json['participant'] != null
          ? ShiftParticipant.fromJson(json['participant'])
          : null,
      animal: json['animal'] != null
          ? AnimalSummary.fromJson(json['animal'])
          : null,
    );
  }

  static List<ShiftTask> listFromJson(List<dynamic> list) =>
      list.map((e) => ShiftTask.fromJson(e as Map<String, dynamic>)).toList();
}
