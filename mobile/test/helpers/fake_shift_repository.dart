import 'package:bastetshelter/core/network/api_client.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_model.dart';
import 'package:bastetshelter/features/shifts/data/shift_repository.dart';
import 'package:bastetshelter/features/tasks/data/my_shift_tasks_group.dart';

class FakeShiftRepository extends ShiftRepository {
  FakeShiftRepository() : super(ApiClient());

  List<MyShiftTasksGroup> myTasks = [];
  final List<int> unassignedTaskIds = [];
  final List<int> completedTaskIds = [];
  final List<int> uncompletedTaskIds = [];
  final List<(int taskId, int participantId)> assignedTasks = [];

  @override
  Future<List<MyShiftTasksGroup>> getMyTasks() async => myTasks;

  @override
  Future<void> assignTask(int shiftTaskId, int participantId) async {
    assignedTasks.add((shiftTaskId, participantId));
  }

  @override
  Future<void> unassignTask(int shiftTaskId) async {
    unassignedTaskIds.add(shiftTaskId);
  }

  @override
  Future<void> completeTask(int shiftTaskId) async {
    completedTaskIds.add(shiftTaskId);
  }

  @override
  Future<void> uncompleteTask(int shiftTaskId) async {
    uncompletedTaskIds.add(shiftTaskId);
  }

  @override
  Future<ShiftDetail> getShiftDetail(int shiftId) async {
    return ShiftDetail.fromJson({...sampleShiftDetailJson, 'id': shiftId});
  }
}

const sampleShiftDetailJson = {
  'id': 1,
  'start_time': '2026-05-25T09:00:00',
  'end_time': '2026-05-25T13:00:00',
  'day': '2026-05-25',
  'refuge_id': 10,
  'max_participants': 5,
  'current_participants': 2,
  'shift_tasks': [],
  'is_joined': true,
  'my_participant_id': 99,
};
