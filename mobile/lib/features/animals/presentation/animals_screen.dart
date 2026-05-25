import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/animals/presentation/components/animal_filter_bar.dart';
import 'package:bastetshelter/features/animals/presentation/register_animal_screen.dart';
import 'package:bastetshelter/features/common/components/bastet_search_bar.dart';
import 'package:bastetshelter/providers/animals/animal_filter_provider.dart';
import 'package:bastetshelter/providers/animals/animal_provider.dart';
import 'package:bastetshelter/features/animals/presentation/components/animal_card.dart';
import 'package:bastetshelter/features/common/components/layout/app_bar.dart';
import 'package:bastetshelter/providers/auth/auth_provider.dart';
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
    final isManager = ref.watch(isManagerProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BastetAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                ),
                child: BastetSearchBar(
                  onChanged: animalsFilterNotifier.updateQuery,
                ),
              ),
              const SizedBox(height: 16),
              const AnimalFilterBar(),
              const SizedBox(height: 8),
              Expanded(
                child: animalsAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
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
                        Text(
                          context.l10n.t('animals.loadError'),
                          style: tt.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton(
                          onPressed: () =>
                              ref.read(animalsProvider.notifier).refresh(),
                          child: Text(context.l10n.t('common.retry')),
                        ),
                      ],
                    ),
                  ),
                  data: (animals) => RefreshIndicator(
                    onRefresh: () =>
                        ref.read(animalsProvider.notifier).refresh(),
                    color: AppColors.primary,
                    child: animals.isEmpty
                        ? Center(child: Text(context.l10n.t('animals.empty')))
                        : GridView.builder(
                            padding: const EdgeInsets.only(
                              left: AppConstants.defaultPadding,
                              right: AppConstants.defaultPadding,
                              bottom: AppConstants.defaultPadding + 80,
                              top: 8,
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
          ),

          if (isManager)
            Positioned(
              bottom: 16,
              right: 16,
              child: FloatingActionButton.extended(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => const AnimalRegisterScreen(),
                    ),
                  );
                },
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 4,
                icon: const Icon(Icons.add),
                label: Text(context.l10n.t('animals.addAnimal')),
              ),
            ),
        ],
      ),
    );
  }
}
