import 'package:bastetshelter/features/animals/data/models/animal_summary_model.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_model.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_task_model.dart';
import 'package:bastetshelter/features/tasks/data/my_shift_tasks_group.dart';
import 'package:bastetshelter/features/tasks/data/task_model.dart';

const sampleShiftJson = {
  'id': 1,
  'start_time': '2026-05-25T09:00:00',
  'end_time': '2026-05-25T13:00:00',
  'day': '2026-05-25',
  'refuge_id': 10,
  'max_participants': 5,
  'current_participants': 2,
};

Map<String, dynamic> shiftTaskJson({
  int id = 1,
  String status = 'NOT_COMPLETED',
  int shiftId = 1,
  int taskId = 3,
  String title = 'Morning walk',
  String description = 'Walk the dog',
  Map<String, dynamic>? participant,
  Map<String, dynamic>? animal,
}) {
  return {
    'id': id,
    'status': status,
    'assigned_date': '2026-05-25',
    'shift_id': shiftId,
    'task_id': taskId,
    'task': {
      'id': taskId,
      'title': title,
      'description': description,
      'num_people': 1,
    },
    'participant': participant,
    'animal': animal,
  };
}

ShiftTask buildShiftTask({
  int id = 1,
  ShiftTaskStatus status = ShiftTaskStatus.notCompleted,
  int shiftId = 1,
  String title = 'Morning walk',
  AnimalSummary? animal,
}) {
  return ShiftTask(
    id: id,
    status: status,
    assignedDate: DateTime.parse('2026-05-25'),
    shiftId: shiftId,
    taskId: 3,
    task: Task(id: 3, title: title, description: 'Walk the dog', numPeople: 1),
    animal: animal,
  );
}

MyShiftTasksGroup buildShiftTasksGroup({
  required List<ShiftTask> tasks,
  Shift? shift,
}) {
  return MyShiftTasksGroup(
    shift: shift ?? Shift.fromJson(sampleShiftJson),
    tasks: tasks,
  );
}

const sampleAnimals = [
  AnimalSummary(
    id: 1,
    name: 'Luna',
    age: 3,
    inAdoption: true,
    pendingShiftTasks: 2,
    refugeName: 'Main refuge',
  ),
  AnimalSummary(
    id: 2,
    name: 'Max',
    age: 5,
    inAdoption: false,
    pendingShiftTasks: 0,
    refugeName: 'North wing',
  ),
  AnimalSummary(
    id: 3,
    name: 'Bella',
    age: 2,
    inAdoption: true,
    pendingShiftTasks: 1,
    refugeName: 'Main refuge',
  ),
];

Map<String, dynamic> pendingTasksResponse({
  required List<Map<String, dynamic>> tasks,
}) {
  return {
    'pending_tasks': [
      {'shift': sampleShiftJson, 'tasks': tasks},
    ],
  };
}
