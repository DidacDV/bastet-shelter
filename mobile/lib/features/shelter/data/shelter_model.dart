class Shelter {
  final String name;
  final String location;
  final String? volunteerCode;
  final String? managerCode;

  Shelter({
    required this.name,
    required this.location,
    this.volunteerCode,
    this.managerCode,
  });

  factory Shelter.fromJson(Map<String, dynamic> json) {
    return Shelter(
      name: json['name'],
      location: json['location'],
      volunteerCode: json['volunteer_code'],
      managerCode: json['manager_code'],
    );
  }

  Shelter copyWith({
    String? volunteerCode,
    String? managerCode,
  }) {
    return Shelter(
      name: name,
      location: location,
      volunteerCode: volunteerCode ?? this.volunteerCode,
      managerCode: managerCode ?? this.managerCode,
    );
  }
}