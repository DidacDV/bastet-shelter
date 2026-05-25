import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_list/adoption_list_screen.dart';
import 'package:bastetshelter/features/common/components/layout/app_bar.dart';
import 'package:bastetshelter/features/home/presentation/components/home_card.dart';
import 'package:bastetshelter/providers/dashboard/dashboard_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeTab extends ConsumerWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: const BastetAppBar(showProfile: true),

      body: dashboardAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text(error.toString())),
        data: (dashboard) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                Text(
                  context.l10n.t('home.welcome'),
                  style: theme.textTheme.displayLarge,
                ),
                Text(
                  context.l10n.t('home.subtitle'),
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
                              label: context.l10n.t('home.registeredAnimals'),
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
                              label: context.l10n.t('home.adoptionProcesses'),
                              icon: Icons.home_rounded,
                              bgColor: AppColors.secondaryTint,
                              fgColor: AppColors.secondary,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => AdoptionList(),
                                ),
                              ),
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
                              label: context.l10n.t('home.activeVolunteers'),
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
        ),
      ),
    );
  }
}
