class UserProfile {
  final int id;
  final String name;
  final String lastName1;
  final String? lastName2;
  final String email;

  const UserProfile({
    required this.id,
    required this.name,
    required this.lastName1,
    this.lastName2,
    required this.email,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      name: json['name'] as String,
      lastName1: json['last_name_1'] as String,
      lastName2: json['last_name_2'] as String?,
      email: json['email'] as String,
    );
  }

  String get fullName => [name, lastName1, ?lastName2].join(' ');
}
