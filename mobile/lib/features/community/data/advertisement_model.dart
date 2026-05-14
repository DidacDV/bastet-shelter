enum AdCategory {
  food,
  medicine,
  equipment,
  toys,
  other;

  String get value => name.toUpperCase();
}

AdCategory _categoryFromJson(String raw) => switch (raw) {
  'FOOD' => AdCategory.food,
  'MEDICINE' => AdCategory.medicine,
  'EQUIPMENT' => AdCategory.equipment,
  'TOYS' => AdCategory.toys,
  _ => AdCategory.other,
};

class AdvertisementSummary {
  final int id;
  final String title;
  final AdCategory category;
  final String provinceName;
  final String? imageUrl;

  const AdvertisementSummary({
    required this.id,
    required this.title,
    required this.category,
    required this.provinceName,
    this.imageUrl,
  });

  factory AdvertisementSummary.fromJson(Map<String, dynamic> json) {
    return AdvertisementSummary(
      id: json['id'] as int,
      title: json['title'] as String,
      category: _categoryFromJson(json['category'] as String),
      provinceName: json['province_name'] as String,
      imageUrl: json['image_url'] as String?,
    );
  }

  static List<AdvertisementSummary> listFromJson(List<dynamic> list) => list
      .map((e) => AdvertisementSummary.fromJson(e as Map<String, dynamic>))
      .toList();
}

class AdvertisementDetail extends AdvertisementSummary {
  final String description;
  final DateTime publishedOn;
  final bool isActive;
  final int shelterId;
  final String shelterName;
  final String shelterEmail;

  const AdvertisementDetail({
    required super.id,
    required super.title,
    required super.category,
    required super.provinceName,
    super.imageUrl,
    required this.description,
    required this.publishedOn,
    required this.isActive,
    required this.shelterId,
    required this.shelterName,
    required this.shelterEmail,
  });

  factory AdvertisementDetail.fromJson(Map<String, dynamic> json) {
    return AdvertisementDetail(
      id: json['id'] as int,
      title: json['title'] as String,
      category: _categoryFromJson(json['category'] as String),
      provinceName: json['province_name'] as String,
      imageUrl: json['image_url'] as String?,
      description: json['description'] as String,
      publishedOn: DateTime.parse(json['published_on'] as String),
      isActive: json['is_active'] as bool,
      shelterId: json['shelter_id'] as int,
      shelterName: json['shelter_name'] as String,
      shelterEmail: json['shelter_email'] as String,
    );
  }
}
