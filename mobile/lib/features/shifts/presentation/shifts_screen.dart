import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/layout/app_bar.dart';
import 'package:bastetshelter/providers/picked_refuge/current_refuge_provider.dart';
import 'package:bastetshelter/providers/shelters/shelter_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShiftsScreen extends ConsumerWidget {
  const ShiftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelterAsync = ref.watch(shelterProvider);
    final selectedRefugeId = ref.watch(currentRefugeProvider);
    final theme = Theme.of(context);

    return shelterAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Error loading shelter: $e')),
      ),
      data: (shelter) {
        if (shelter.refuges.isEmpty) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            appBar: BastetAppBar(customTitle: 'Shifts', showLogout: false),
            body: Center(child: Text('No refuges available.')),
          );
        }

        final activeRefugeId = selectedRefugeId ?? shelter.refuges.first.id;

        final activeRefugeName = shelter.refuges
            .firstWhere(
              (r) => r.id == activeRefugeId,
              orElse: () => shelter.refuges.first,
            )
            .name;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: BastetAppBar(
            customTitle: 'Shifts - $activeRefugeName',
            showLogout: false,
            showBackButton: true,
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'Shifts content for ID: $activeRefugeId goes here!',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
