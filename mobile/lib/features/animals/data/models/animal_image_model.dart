class AnimalImage {
  final int id;
  final String url;
  final String cloudinaryPublicId;
  final int order;

  const AnimalImage({
    required this.id,
    required this.url,
    required this.cloudinaryPublicId,
    required this.order,
  });

  factory AnimalImage.fromJson(Map<String, dynamic> json) {
    return AnimalImage(
      id: json['id'] as int,
      url: json['url'] as String,
      cloudinaryPublicId: json['cloudinary_public_id'] as String,
      order: json['order'] as int,
    );
  }
}
