import 'package:bastetshelter/core/auth/auth_service.dart';
import 'package:bastetshelter/features/auth/data/auth_repository.dart';
import 'package:flutter/material.dart';
import 'package:bastetshelter/core/service_locator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bastetshelter/features/shelter/providers/shelter_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authRepository = getIt<AuthRepository>();

    final authService = getIt<AuthService>();
    final shelterAsync = ref.watch(shelterProvider);

    return Scaffold(
      appBar: AppBar(
        title: shelterAsync.when(
          data: (shelter) => Text(shelter.name),
          loading: () => const Text('Loading...'),
          error: (_, _) => const Text('Bastet Shelter'),
        ),
        actions: [
          if (authService.isManager)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => Navigator.pushNamed(context, '/shelter/config'),
            ),
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
