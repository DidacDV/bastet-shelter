import 'package:bastetshelter/core/network/api_client.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_model.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_participant_model.dart';

class ShiftRepository {
  final ApiClient _apiClient;

  ShiftRepository(this._apiClient);

  Future<List<Shift>> getShifts({
    required int refugeId,
    DateTime? day,
    DateTime? weekStart,
  }) async {
    final queryParams = <String, String>{'refuge_id': refugeId.toString()};
    if (day != null) queryParams['day'] = day.toIso8601String().split('T')[0];
    if (weekStart != null) {
      queryParams['week_start'] = weekStart.toIso8601String().split('T')[0];
    }

    final queryString = Uri(queryParameters: queryParams).query;
    final response = await _apiClient.get('/shifts/?$queryString');

    final shiftsList = (response['shifts'] ?? []) as List<dynamic>;
    return Shift.listFromJson(shiftsList);
  }

  Future<ShiftDetail> getShiftDetail(int shiftId) async {
    final response = await _apiClient.get('/shifts/$shiftId');
    return ShiftDetail.fromJson(response);
  }

  Future<Shift> createShift({
    required int refugeId,
    required DateTime startTime,
    required DateTime endTime,
    required DateTime day,
    int? maxParticipants,
    List<int> taskIds = const [],
  }) async {
    final response = await _apiClient.post(
      '/shifts/?refuge_id=$refugeId',
      body: {
        'start_time': startTime.toIso8601String(),
        'end_time': endTime.toIso8601String(),
        'day': day.toIso8601String().split('T')[0],
        'max_participants': maxParticipants,
        'task_ids': taskIds,
      },
    );
    return Shift.fromJson(response);
  }

  Future<ShiftParticipant> joinShift(int shiftId) async {
    final response = await _apiClient.post('/shifts/$shiftId/join');
    return ShiftParticipant.fromJson(response);
  }

  Future<void> leaveShift(int shiftId) async {
    await _apiClient.delete('/shifts/$shiftId/leave');
  }

  Future<void> deleteShift(int shiftId) async {
    await _apiClient.delete('/shifts/$shiftId');
  }

  Future<List<Shift>> copyWeek({
    required int refugeId,
    required DateTime sourceWeekStart,
    required DateTime targetWeekStart,
  }) async {
    final queryParams = <String, String>{
      'refuge_id': refugeId.toString(),
      'source_week_start': sourceWeekStart.toIso8601String().split('T')[0],
      'target_week_start': targetWeekStart.toIso8601String().split('T')[0],
    };
    final queryString = Uri(queryParameters: queryParams).query;
    final response = await _apiClient.post('/shifts/copy-week?$queryString');

    return Shift.listFromJson(response as List<dynamic>);
  }

  Future<void> clearDay({required int refugeId, required DateTime day}) async {
    final queryParams = <String, String>{
      'refuge_id': refugeId.toString(),
      'day': day.toIso8601String().split('T')[0],
    };
    final queryString = Uri(queryParameters: queryParams).query;
    await _apiClient.delete('/shifts/clear-day?$queryString');
  }

  Future<void> clearWeek({
    required int refugeId,
    required DateTime weekStart,
  }) async {
    final queryParams = <String, String>{
      'refuge_id': refugeId.toString(),
      'week_start': weekStart.toIso8601String().split('T')[0],
    };
    final queryString = Uri(queryParameters: queryParams).query;
    await _apiClient.delete('/shifts/clear-week?$queryString');
  }
}
