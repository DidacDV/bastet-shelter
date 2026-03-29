import 'package:flutter/material.dart';

import '../../common/components/primary_button.dart';
import 'animal_details_screen.dart';

class AnimalsScreen extends StatelessWidget {
  const AnimalsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animals')),
      body: Center(
        child: Column(
          children: [
            PrimaryButton(
              label: "Test local nav",
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => AnimalDetailsScreen()),
              ),
              isLoading: false,
            ),
          ],
        ),
      ),
    );
  }
}
