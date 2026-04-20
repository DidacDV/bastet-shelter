import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class AnimalImageSlider extends StatefulWidget {
  final List<String> imageUrls;

  const AnimalImageSlider({super.key, required this.imageUrls});

  @override
  State<StatefulWidget> createState() => _AnimalImageSliderState();
}

class _AnimalImageSliderState extends State<AnimalImageSlider> {
  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Container(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Center(
          child: Icon(Icons.pets, size: 50, color: Colors.grey),
        ),
      );
    }

    return CarouselSlider(
      items: widget.imageUrls
          .map(
            (item) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 2.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  item,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
          )
          .toList(),
      options: CarouselOptions(
        height: double.infinity,
        viewportFraction: 0.85,
        enlargeCenterPage: true,
        enableInfiniteScroll: widget.imageUrls.length > 1,
      ),
    );
  }
}
