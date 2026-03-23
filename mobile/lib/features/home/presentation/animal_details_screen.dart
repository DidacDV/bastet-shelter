import 'package:flutter/material.dart';

class AnimalDetailsScreen extends StatelessWidget {
  const AnimalDetailsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animal Details'),
      ),
      body: Column(
        children: [Text("details here")],
      ),
    );
  }
}