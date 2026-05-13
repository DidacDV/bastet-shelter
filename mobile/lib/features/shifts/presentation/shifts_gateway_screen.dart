import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/layout/app_bar.dart';
import 'package:bastetshelter/features/shifts/presentation/shifts_screen.dart';
import 'package:bastetshelter/providers/auth/auth_provider.dart';
import 'package:bastetshelter/providers/picked_refuge/current_refuge_provider.dart';
import 'package:bastetshelter/providers/shelters/shelter_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShiftsGatewayScreen extends ConsumerWidget {
  const ShiftsGatewayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelterAsync = ref.watch(shelterProvider);
    final theme = Theme.of(context);
    final isManager = ref.watch(isManagerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: shelterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading shelter: $e')),
        data: (shelter) {
          if (shelter.refuges.isEmpty) {
            return const Scaffold(
              appBar: BastetAppBar(customTitle: 'Shifts', showLogout: false),
              body: Center(child: Text('No refuges available.')),
            );
          }

          //1 REFUGE CASE: we go directly to the shifts screen
          if (shelter.refuges.length == 1) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref
                  .read(currentRefugeProvider.notifier)
                  .setRefuge(shelter.refuges.first.id);
            });
            return const ShiftsScreen();
          }

          //>1 REFUGE CASE: we let the user decide which refuge to view shifts for
          return Scaffold(
            appBar: const BastetAppBar(
              customTitle: 'Select Refuge',
              showLogout: false,
            ),
            body: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (isManager)
                    Text(
                      'Where are you managing shifts today?',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    )
                  else
                    Text(
                      'Where are you today?',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    'Select a refuge to continue to the shift planner.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),

                  Expanded(
                    child: ListView.builder(
                      itemCount: shelter.refuges.length,
                      itemBuilder: (context, index) {
                        final refuge = shelter.refuges[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(color: AppColors.divider),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryTint,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.storefront_rounded,
                                color: AppColors.primary,
                              ),
                            ),
                            title: Text(
                              refuge.name,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: AppColors.textHint,
                            ),
                            onTap: () {
                              ref
                                  .read(currentRefugeProvider.notifier)
                                  .setRefuge(refuge.id);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ShiftsScreen(),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
