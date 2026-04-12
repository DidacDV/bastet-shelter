import '../../geo/data/province_model.dart';

class Refuge {
  final int id;
  final String name;
  final Province province;
  final int shelterId;

  Refuge({
    required this.id,
    required this.name,
    required this.province,
    required this.shelterId,
  });

  factory Refuge.fromJson(Map<String, dynamic> json) {
    return Refuge(
      id: json['id'],
      name: json['name'],
      province: Province.fromJson(json['province']),
      shelterId: json['shelter_id'],
    );
  }
}
