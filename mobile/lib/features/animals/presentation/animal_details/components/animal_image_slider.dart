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
    return CarouselSlider(
      items: widget.imageUrls
          .map(
            (item) => Container(
              margin: EdgeInsets.all(5),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: NetworkImage(item),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          )
          .toList(),
      options: CarouselOptions(
        height: 100,
        enlargeCenterPage: true,
        aspectRatio: 16 / 9,
      ),
    );
  }
}
