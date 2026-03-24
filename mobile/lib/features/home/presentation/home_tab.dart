import 'package:bastetshelter/core/auth/auth_service.dart';
import 'package:bastetshelter/features/auth/data/auth_repository.dart';
import 'package:bastetshelter/features/home/data/dashboard_repository.dart';
import 'package:bastetshelter/features/home/data/dashboard_model.dart';
import 'package:bastetshelter/features/shelter/presentation/configuration_screen.dart';
import 'package:flutter/material.dart';
import 'package:bastetshelter/core/service_locator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bastetshelter/core/providers/shelter_notifier.dart';

class HomeTab extends ConsumerStatefulWidget {
  const HomeTab({super.key});

  @override
  ConsumerState<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends ConsumerState<HomeTab> {
  late final Future<DashboardData> _dashboardFuture;

  @override
  void initState() {
    super.initState();
    _dashboardFuture = getIt<DashboardRepository>().getDashboard();
  }

  @override
  Widget build(BuildContext context) {
    final authRepository = getIt<AuthRepository>();
    final authService = getIt<AuthService>();
    final shelterAsync = ref.watch(shelterProvider);

    return Scaffold(
      appBar: AppBar(
        title: shelterAsync.when(
          data: (shelter) => Text(shelter.name),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Bastet Shelter'),
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
              authRepository.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: FutureBuilder<DashboardData>(
        future: _dashboardFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          final dashboard = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Benvingut',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                _StatTile(
                  count: dashboard.animalCount,
                  label: 'animals registrats',
                  onTap: () {},
                ),
                const SizedBox(height: 24),
                _StatTile(
                  count: dashboard.activeAdoptionCount,
                  label: "processos d'adopció actius",
                  onTap: () {},
                ),
                const SizedBox(height: 24),
                _StatTile(
                  count: dashboard.volunteerCount,
                  label: 'voluntaris',
                  onTap: () {},
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final int count;
  final String label;
  final VoidCallback onTap;

  const _StatTile({
    required this.count,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Text(
            '$count',
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}