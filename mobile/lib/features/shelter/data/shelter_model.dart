import 'package:bastetshelter/features/shelter/data/refuge_model.dart';

class Shelter {
  final String name;
  final String location;
  final String? volunteerCode;
  final String? managerCode;
  final List<Refuge> refuges;

  Shelter({
    required this.name,
    required this.location,
    this.volunteerCode,
    this.managerCode,
    this.refuges = const [],
  });

  factory Shelter.fromJson(Map<String, dynamic> json) {
    return Shelter(
      name: json['name'],
      location: json['location'],
      volunteerCode: json['volunteer_code'],
      managerCode: json['manager_code'],
      refuges: (json['refuges'] as List<dynamic>?)?.map((refuge) => Refuge.fromJson(refuge)).toList() ??
          [],
    );
  }

  Shelter copyWith({
    String? volunteerCode,
    String? managerCode,
    List<Refuge>? refuges,
  }) {
    return Shelter(
      name: name,
      location: location,
      volunteerCode: volunteerCode ?? this.volunteerCode,
      managerCode: managerCode ?? this.managerCode,
      refuges: refuges ?? this.refuges,
    );
  }
}