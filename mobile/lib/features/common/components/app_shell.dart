//this serves as a layout that is reused through the whole app, since it "shells" home screen

import 'package:bastetshelter/core/auth/auth_service.dart';
import 'package:bastetshelter/providers/shelters/shelter_notifier.dart';
import 'package:bastetshelter/features/shelter/presentation/configuration_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/features/auth/data/auth_repository.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  final bool showAppBar;

  const AppShell({super.key, required this.child, this.showAppBar = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelterAsync = ref.watch(shelterProvider);
    final authService = getIt<AuthService>();

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: shelterAsync.when(
                data: (shelter) => Text(shelter.name),
                loading: () => const Text('Loading...'),
                error: (_, _) => const Text('Bastet Shelter'),
              ),
              actions: [
                if (authService.isManager)
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ConfigScreen()),
                    ),
                  ),
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () {
                    getIt<AuthRepository>().logout();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                ),
              ],
            )
          : null,
      body: child,
    );
  }
}
