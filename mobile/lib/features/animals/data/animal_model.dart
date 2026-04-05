class AnimalSummary {
  final int id;
  final String name;
  final int age; //years
  final bool inAdoption;
  final int pendingShiftTasks;
  final String refugeName;

  final String? imageUrl;

  const AnimalSummary({
    required this.id,
    required this.name,
    required this.age,
    required this.inAdoption,
    required this.pendingShiftTasks,
    required this.refugeName,
    this.imageUrl,
  });

  factory AnimalSummary.fromJson(Map<String, dynamic> json) {
    return AnimalSummary(
      id: json['id'] as int,
      name: json['name'] as String,
      age: json['age'] as int,
      inAdoption: json['in_adoption'] as bool,
      pendingShiftTasks: json['pending_shift_tasks'] as int,
      refugeName: json['refuge_name'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }

  static List<AnimalSummary> listFromJson(List<dynamic> list) => list
      .map((e) => AnimalSummary.fromJson(e as Map<String, dynamic>))
      .toList();
}
