import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_process/adoption_process_screen.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/adoption/components/adoption_toggle.dart';
import 'package:bastetshelter/features/common/components/confirmation_dialog.dart';
import 'package:bastetshelter/providers/animals/animal_details_provider.dart';
import 'package:bastetshelter/providers/animals/animal_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdoptionTab extends ConsumerWidget {
  final int animalId;

  const AdoptionTab({super.key, required this.animalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(animalDetailProvider(animalId));
    final tt = Theme.of(context).textTheme;

    Future<void> onToggleAdoptionStatus(bool isInAdoption) async {
      if (isInAdoption) {
        final confirm = await ConfirmationDialog.show(
          context: context,
          title:
              "Are you sure you want to take out this animal from the adoption pool?",
          message:
              "If the animal has any active adoption process, it will be cancelled and the adoptant will be notified.",
          isDestructive: true,
        );
        if (!confirm) return;
        ref.read(animalsProvider.notifier).toggleAnimalAdoption(animalId);
      } else {
        final confirm = await ConfirmationDialog.show(
          context: context,
          title:
              "Are you sure you want to put this animal in the adoption pool?",
          message:
              "The animal will be seen by adoptants on the portal and they will be able to submit an adoption request.",
          isDestructive: false,
        );
        if (!confirm) return;
        ref.read(animalsProvider.notifier).toggleAnimalAdoption(animalId);
      }
    }

    return detailAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text(
          'Could not load adoption info.',
          style: tt.bodyMedium?.copyWith(color: AppColors.error),
        ),
      ),
      data: (animal) {
        final hasProcess = animal.adoptionProcessesIds?.isNotEmpty == true;
        final activeProcessId = hasProcess
            ? animal.adoptionProcessesIds!.first
            : null;

        return Padding(
          padding: AppConstants.tabsPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.home_outlined,
                        size: 24,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Text('Adoption', style: tt.titleLarge),
                    ],
                  ),
                  AdoptionToggle(
                    inAdoption: animal.inAdoption,
                    onToggle: () => onToggleAdoptionStatus(animal.inAdoption),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                animal.inAdoption
                    ? 'This animal is available for adoption.'
                    : 'This animal is not available for adoption.',
                style: tt.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const Divider(height: 40),

              if (hasProcess) ...[
                Text('Active process', style: tt.titleMedium),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AdoptionProcessScreen(
                        adoptionProcessId: activeProcessId!,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                  label: const Text('Go to the active adoption process'),
                ),
              ] else if (animal.inAdoption) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      size: 18,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You will be notified when an adoptant wants to adopt this animal.',
                        style: tt.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
