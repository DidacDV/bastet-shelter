import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/layout/app_bar.dart';
import 'package:bastetshelter/providers/picked_refuge/current_refuge_provider.dart';
import 'package:bastetshelter/providers/shelters/shelter_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'components/shifts_header.dart';
import 'components/shifts_body.dart';

class ShiftsScreen extends ConsumerWidget {
  const ShiftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelterAsync = ref.watch(shelterProvider);
    final selectedRefugeId = ref.watch(currentRefugeProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BastetAppBar(customTitle: 'Shifts', showLogout: false),
      body: shelterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading shelter: $e')),
        data: (shelter) {
          if (shelter.refuges.isEmpty) {
            return const Center(child: Text('No refuges available.'));
          }

          final activeRefugeId = selectedRefugeId ?? shelter.refuges.first.id;
          final activeRefugeName = shelter.refuges
              .firstWhere(
                (r) => r.id == activeRefugeId,
                orElse: () => shelter.refuges.first,
              )
              .name;
          final hasMultipleRefuges = shelter.refuges.length > 1;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShiftsHeader(
                activeRefugeName: activeRefugeName,
                activeRefugeId: activeRefugeId,
                hasMultipleRefuges: hasMultipleRefuges,
                refuges: shelter.refuges,
              ),
              ShiftsBody(
                activeRefugeId: activeRefugeId,
                activeRefugeName: activeRefugeName,
              ),
            ],
          );
        },
      ),
    );
  }
}
