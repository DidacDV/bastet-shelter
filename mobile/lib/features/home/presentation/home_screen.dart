import 'package:bastetshelter/features/auth/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:bastetshelter/core/service_locator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = getIt<AuthRepository>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bastet Shelter Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authRepository.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 100, color: Colors.brown),
            SizedBox(height: 24),
            Text(
              'Welcome to Bastet Shelter!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('bla bla bla'),
          ],
        ),
      ),
    );
  }
}
