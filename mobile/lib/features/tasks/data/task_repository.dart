import 'package:bastetshelter/core/network/api_client.dart';
import 'task_model.dart';

class TaskRepository {
  final ApiClient _apiClient;

  TaskRepository(this._apiClient);

  Future<List<Task>> getTasks() async {
    final response = await _apiClient.get('/tasks/');

    final tasksList = (response['tasks'] ?? []) as List<dynamic>;
    return Task.listFromJson(tasksList);
  }

  Future<Task> createTask({
    required String title,
    required String description,
    required int numPeople,
  }) async {
    final response = await _apiClient.post(
      '/tasks/',
      body: {
        'title': title,
        'description': description,
        'num_people': numPeople,
      },
    );
    return Task.fromJson(response);
  }

  Future<Task> updateTask({
    required int id,
    String? title,
    String? description,
    int? numPeople,
  }) async {
    final body = <String, dynamic>{};

    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (numPeople != null) body['num_people'] = numPeople;

    final response = await _apiClient.put('/tasks/$id', body: body);
    return Task.fromJson(response as Map<String, dynamic>);
  }

  Future<void> deleteTask(int id) async {
    await _apiClient.delete('/tasks/$id');
  }
}
