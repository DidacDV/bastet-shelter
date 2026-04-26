class AdoptantResponse {
  final int id;
  final String name;
  final String email;

  const AdoptantResponse({
    required this.id,
    required this.name,
    required this.email,
  });

  factory AdoptantResponse.fromJson(Map<String, dynamic> json) {
    return AdoptantResponse(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
    );
  }
}
