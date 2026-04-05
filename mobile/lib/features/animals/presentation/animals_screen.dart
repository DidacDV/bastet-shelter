import 'package:bastetshelter/features/common/components/bastet_search_bar.dart';
import 'package:bastetshelter/providers/animals/animal_filter_provider.dart';
import 'package:bastetshelter/providers/animals/animal_provider.dart'
    show animalsProvider;
import 'package:bastetshelter/features/animals/presentation/components/animal_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bastetshelter/core/constants.dart';

class AnimalsScreen extends ConsumerWidget {
  const AnimalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalsAsync = ref.watch(filteredAnimalsProvider);
    final animalsFilterNotifier = ref.read(animalFilterProvider.notifier);
    final tt = Theme.of(context).textTheme;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: BastetSearchBar(onChanged: animalsFilterNotifier.updateQuery),
        ),
        Expanded(
          child: animalsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 48,
                  ),
                  const SizedBox(height: 12),
                  Text('Could not load animals', style: tt.titleMedium),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () =>
                        ref.read(animalsProvider.notifier).refresh(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (animals) => RefreshIndicator(
              onRefresh: () => ref.read(animalsProvider.notifier).refresh(),
              color: AppColors.primary,
              child: animals.isEmpty
                  ? const Center(child: Text('No animals found'))
                  : GridView.builder(
                      padding: const EdgeInsets.all(
                        AppConstants.defaultPadding,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                      itemCount: animals.length,
                      itemBuilder: (context, i) =>
                          AnimalCard(animal: animals[i]),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
