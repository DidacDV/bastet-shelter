class Refuge {
  final int id;
  final String name;
  final String location;
  final int shelterId;

  Refuge({
    required this.id,
    required this.name,
    required this.location,
    required this.shelterId,
  });

  factory Refuge.fromJson(Map<String, dynamic> json) {
    return Refuge(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      shelterId: json['shelter_id'],
    );
  }
}
