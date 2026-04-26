import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_list/components/adoption_card.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_process/adoption_process_screen.dart';
import 'package:bastetshelter/providers/adoption/adoption_list_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdoptionList extends ConsumerWidget {
  const AdoptionList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(adoptionListProvider);
    final theme = Theme.of(context);
    final tt = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Adoption processes'),
        centerTitle: false,
      ),
      body: listAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  color: AppColors.error,
                  size: 56,
                ),
                const SizedBox(height: 16),
                Text(
                  'Could not load adoptions',
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                  ),
                  onPressed: () => ref.invalidate(adoptionListProvider),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        data: (processes) {
          if (processes.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.pets_rounded,
                        size: 48,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No active adoptions',
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'New adoption requests and active processes will appear here.',
                      textAlign: TextAlign.center,
                      style: tt.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColors.primary,
            backgroundColor: theme.scaffoldBackgroundColor,
            onRefresh: () => ref.read(adoptionListProvider.notifier).refresh(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              itemCount: processes.length,
              itemBuilder: (context, i) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: AdoptionCard(
                  process: processes[i],
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AdoptionProcessScreen(
                        adoptionProcessId: processes[i].id,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
