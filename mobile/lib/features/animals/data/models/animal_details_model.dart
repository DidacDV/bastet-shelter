import 'package:bastetshelter/features/animals/data/animal_type_enum.dart';
import 'package:bastetshelter/features/traits/data/trait_model.dart';

import 'animal_image_model.dart';

class AnimalDetails {
  final int id;
  final String name;
  final DateTime birthDate;
  final DateTime? arrivalDate;
  final String description;
  final String breed;
  final AnimalTypeEnum animalType;
  final bool inAdoption;
  final int refugeId;
  final String refugeName;
  final List<AnimalImage> images;
  final List<Trait> traits;

  const AnimalDetails({
    required this.id,
    required this.name,
    required this.birthDate,
    this.arrivalDate,
    required this.description,
    required this.breed,
    required this.animalType,
    required this.inAdoption,
    required this.refugeId,
    required this.refugeName,
    required this.images,
    required this.traits,
  });

  factory AnimalDetails.fromJson(Map<String, dynamic> json) {
    return AnimalDetails(
      id: json['id'] as int,
      name: json['name'] as String,
      birthDate: DateTime.parse(json['birth_date'] as String),
      arrivalDate: json['arrival_date'] != null
          ? DateTime.parse(json['arrival_date'] as String)
          : null,
      description: json['description'] as String,
      breed: json['breed'] as String,
      animalType: AnimalTypeEnum.values.firstWhere(
        (e) => e.value == json['animal_type'],
      ),
      inAdoption: json['in_adoption'] as bool,
      refugeId: json['refuge_id'] as int,
      refugeName: json['refuge_name'] as String,
      images: (json['images'] as List<dynamic>)
          .map((image) => AnimalImage.fromJson(image as Map<String, dynamic>))
          .toList(),
      traits: (json['traits'] as List<dynamic>)
          .map((t) => Trait.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
  String? get primaryImageUrl => images.isEmpty
      ? null
      : (images..sort((a, b) => a.order.compareTo(b.order))).first.url;
}
