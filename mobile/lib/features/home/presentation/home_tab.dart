import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/home/data/dashboard_repository.dart';
import 'package:bastetshelter/features/home/data/dashboard_model.dart';
import 'package:bastetshelter/features/home/presentation/components/home_card.dart';
import 'package:flutter/material.dart';
import 'package:bastetshelter/core/service_locator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    final theme = Theme.of(context);

    return FutureBuilder<DashboardData>(
      future: _dashboardFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }

        final dashboard = snapshot.data!;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Text('Welcome', style: theme.textTheme.displayLarge),
                Text(
                  'Keep on track with your shelter.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 16,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: 0.85,
                            child: StatCard(
                              count: dashboard.animalCount,
                              label: 'Registered animals',
                              icon: Icons.pets_rounded,
                              bgColor: AppColors.primaryTint,
                              fgColor: AppColors.primary,
                              onTap: () {},
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FractionallySizedBox(
                            widthFactor: 0.85,
                            child: StatCard(
                              count: dashboard.activeAdoptionCount,
                              label: 'Adoption processes',
                              icon: Icons.home_rounded,
                              bgColor: AppColors.secondaryTint,
                              fgColor: AppColors.secondary,
                              onTap: () {},
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: 0.85,
                            child: StatCard(
                              count: dashboard.volunteerCount,
                              label: 'Active volunteers',
                              icon: Icons.people_rounded,
                              bgColor: AppColors.accentTint,
                              fgColor: AppColors.accent,
                              onTap: () {},
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
