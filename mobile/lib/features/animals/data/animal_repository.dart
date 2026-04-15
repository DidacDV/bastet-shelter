import 'dart:io';

import 'package:bastetshelter/core/network/api_client.dart';
import 'package:bastetshelter/features/animals/data/models/animal_details_model.dart';
import 'package:bastetshelter/features/animals/data/models/animal_image_model.dart';
import 'package:bastetshelter/features/animals/data/models/animal_summary_model.dart';
import 'package:image_picker/image_picker.dart';
import 'animal_type_enum.dart';

class AnimalRepository {
  final ApiClient _apiClient;
  AnimalRepository(this._apiClient);

  Future<List<AnimalSummary>> getAllAnimals() async {
    final data = await _apiClient.get('/animals/short_info');
    return AnimalSummary.listFromJson(data['animals'] as List<dynamic>);
  }

  Future<AnimalDetails> registerAnimal({
    required String name,
    required DateTime birthDate,
    DateTime? arrivalDate,
    required String description,
    required String breed,
    required AnimalTypeEnum animalType,
    required int refugeId,
    bool inAdoption = false,
    List<int> traitIds = const [],
  }) async {
    final response = await _apiClient.post(
      '/animals/',
      body: {
        'name': name,
        'birth_date': birthDate.toIso8601String().split('T').first,
        if (arrivalDate != null)
          'arrival_date': arrivalDate.toIso8601String().split('T').first,
        'description': description,
        'breed': breed,
        'animal_type': animalType.value,
        'refuge_id': refugeId,
        'in_adoption': inAdoption,
        'trait_ids': traitIds,
      },
    );
    return AnimalDetails.fromJson(response);
  }

  Future<AnimalDetails> getAnimalDetails(int animalId) async {
    final data = await _apiClient.get('/animals/$animalId');
    return AnimalDetails.fromJson(data);
  }

  Future<void> updateAnimal(int animalId, Map<String, dynamic> updates) async {
    await _apiClient.patch('/animals/$animalId', body: updates);
  }

  Future<AnimalImage> uploadAnimalImage(int animalId, XFile image) async {
    final data = await _apiClient.postMultipart(
      '/animals/$animalId/images',
      File(image.path),
    );
    return AnimalImage.fromJson(data);
  }

  Future<List<AnimalImage>> uploadAnimalImages(
    int animalId,
    List<XFile> images,
  ) async {
    final results = <AnimalImage>[];
    for (final img in images) {
      final result = await uploadAnimalImage(animalId, img);
      results.add(result);
    }
    return results;
  }

  Future<void> deleteAnimal(int animalId) {
    return _apiClient.delete('/animals/$animalId');
  }
}
