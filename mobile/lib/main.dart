import 'package:flutter/material.dart';

import 'features/exampleFeature/presentation/example_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bastet Shelter',
      theme: ThemeData(useMaterial3: true),
      home: const ExampleScreen(),
    );
  }
}