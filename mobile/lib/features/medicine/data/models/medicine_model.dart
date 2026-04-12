class Medicine {
  final int id;
  final String name;
  final int currentStock;

  Medicine({required this.id, required this.name, required this.currentStock});

  factory Medicine.fromJson(Map<String, dynamic> json) {
    return Medicine(
      id: json['id'] as int,
      name: json['name'] as String,
      currentStock: json['current_stock'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'current_stock': currentStock};
  }

  static List<Medicine> listFromJson(List<dynamic> list) => list
      .map((medicine) => Medicine.fromJson(medicine as Map<String, dynamic>))
      .toList();
}
