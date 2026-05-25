class Task {
  final int id;
  final String title;
  final String description;
  final int numPeople;

  const Task({
    required this.id,
    required this.title,
    required this.description,
    required this.numPeople,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      numPeople: json['num_people'] as int,
    );
  }

  static List<Task> listFromJson(List<dynamic> list) =>
      list.map((e) => Task.fromJson(e as Map<String, dynamic>)).toList();
}
