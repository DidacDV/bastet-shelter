import 'package:bastetshelter/core/constants.dart';
import 'package:flutter/material.dart';

class AnimalAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final IconData fallbackIcon;

  const AnimalAvatar({
    super.key,
    this.imageUrl,
    this.radius = 20.0,
    this.fallbackIcon = Icons.pets,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primaryTint,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null
          ? Icon(fallbackIcon, color: AppColors.primary, size: radius * 0.6)
          : null,
    );
  }
}
