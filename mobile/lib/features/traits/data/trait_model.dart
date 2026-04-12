class Trait {
  final int id;
  final String name;

  const Trait({required this.id, required this.name});

  factory Trait.fromJson(Map<String, dynamic> json) {
    return Trait(id: json['id'] as int, name: json['name'] as String);
  }

  static List<Trait> listFromJson(List<dynamic> list) =>
      list.map((e) => Trait.fromJson(e as Map<String, dynamic>)).toList();
}
