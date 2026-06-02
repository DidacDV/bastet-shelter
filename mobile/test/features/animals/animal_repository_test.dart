import 'package:bastetshelter/features/animals/data/animal_repository.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_task_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fixtures.dart';
import '../../helpers/recording_api_client.dart';

void main() {
  group('AnimalRepository', () {
    late RecordingApiClient apiClient;
    late AnimalRepository repository;

    setUp(() {
      apiClient = RecordingApiClient();
      repository = AnimalRepository(apiClient);
    });

    test(
      'getAllAnimals calls short_info endpoint and parses animals',
      () async {
        apiClient.defaultGetResponse = {
          'animals': [
            {
              'id': 1,
              'name': 'Luna',
              'age': 3,
              'in_adoption': true,
              'pending_shift_tasks': 2,
              'refuge_name': 'Main refuge',
            },
          ],
        };

        final animals = await repository.getAllAnimals();

        expect(apiClient.getCalls.single, '/animals/short_info');
        expect(animals.single.name, 'Luna');
        expect(animals.single.pendingShiftTasks, 2);
      },
    );

    test('getAnimalDetails calls animal endpoint', () async {
      apiClient.defaultGetResponse = {
        'id': 4,
        'name': 'Rocky',
        'birth_date': '2024-01-01',
        'arrival_date': null,
        'description': 'Friendly',
        'breed': 'Mixed',
        'animal_type': 'DOG',
        'in_adoption': false,
        'refuge_id': 1,
        'refuge_name': 'Main refuge',
        'traits': [],
        'images': [],
        'adoption_processes': [],
      };

      final details = await repository.getAnimalDetails(4);

      expect(apiClient.getCalls.single, '/animals/4');
      expect(details.name, 'Rocky');
    });

    test(
      'getPendingTasks calls pending-tasks endpoint and sorts tasks',
      () async {
        apiClient.defaultGetResponse = pendingTasksResponse(
          tasks: [
            shiftTaskJson(id: 10, status: 'COMPLETED'),
            shiftTaskJson(id: 5, status: 'NOT_COMPLETED'),
          ],
        );

        final groups = await repository.getPendingTasks(7);

        expect(apiClient.getCalls.single, '/animals/7/pending-tasks');
        expect(groups.single.tasks.map((task) => task.id), [5, 10]);
        expect(groups.single.tasks.first.status, ShiftTaskStatus.notCompleted);
        expect(groups.single.tasks.last.status, ShiftTaskStatus.completed);
      },
    );

    test('toggleAnimalAdoption calls adoption patch endpoint', () async {
      await repository.toggleAnimalAdoption(9);

      expect(apiClient.patchCalls.single, '/animals/9/adoption');
    });

    test('deleteAnimal calls delete endpoint', () async {
      await repository.deleteAnimal(11);

      expect(apiClient.deleteCalls.single, '/animals/11');
    });
  });
}
