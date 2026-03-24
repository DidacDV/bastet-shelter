class DashboardData {
  final int animalCount;
  final int volunteerCount;
  final int activeAdoptionCount;

  DashboardData({
    required this.animalCount,
    required this.volunteerCount,
    required this.activeAdoptionCount,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) => DashboardData(
    animalCount: json['animal_count'],
    volunteerCount: json['volunteer_count'],
    activeAdoptionCount: json['active_adoption_count'] ?? 0,
  );
}