import 'package:bastetshelter/features/shelter/data/refuge_model.dart';
import '../../geo/data/province_model.dart';

class Shelter {
  final String name;
  final String? email;
  final Province province;
  final String? volunteerCode;
  final String? managerCode;
  final List<Refuge> refuges;

  Shelter({
    required this.name,
    this.email,
    required this.province,
    this.volunteerCode,
    this.managerCode,
    this.refuges = const [],
  });

  factory Shelter.fromJson(Map<String, dynamic> json) {
    return Shelter(
      name: json['name'],
      email: json['shelter_email'],
      province: Province.fromJson(json['province']),
      volunteerCode: json['volunteer_code'],
      managerCode: json['manager_code'],
      refuges:
          (json['refuges'] as List<dynamic>?)
              ?.map((refuge) => Refuge.fromJson(refuge))
              .toList() ??
          [],
    );
  }

  Shelter copyWith({
    String? name,
    String? email,
    Province? province,
    String? volunteerCode,
    String? managerCode,
    List<Refuge>? refuges,
  }) {
    return Shelter(
      name: name ?? this.name,
      email: email ?? this.email,
      province: province ?? this.province,
      volunteerCode: volunteerCode ?? this.volunteerCode,
      managerCode: managerCode ?? this.managerCode,
      refuges: refuges ?? this.refuges,
    );
  }
}
