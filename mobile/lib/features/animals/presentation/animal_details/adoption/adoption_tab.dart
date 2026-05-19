import 'package:bastetshelter/core/localization/app_localizations.dart';
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
  final bool isManager;

  const AdoptionTab({
    super.key,
    required this.animalId,
    this.isManager = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(animalDetailProvider(animalId));
    final tt = Theme.of(context).textTheme;

    Future<void> onToggleAdoptionStatus(bool isInAdoption) async {
      if (isInAdoption) {
        final confirm = await ConfirmationDialog.show(
          context: context,
          title: context.l10n.t('animals.removeFromAdoptionTitle'),
          message: context.l10n.t('animals.removeFromAdoptionMessage'),
          isDestructive: true,
        );
        if (!confirm) return;
        ref.read(animalsProvider.notifier).toggleAnimalAdoption(animalId);
      } else {
        final confirm = await ConfirmationDialog.show(
          context: context,
          title: context.l10n.t('animals.addToAdoptionTitle'),
          message: context.l10n.t('animals.addToAdoptionMessage'),
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
          context.l10n.t('animals.adoptionInfoLoadError'),
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
                      Text(
                        context.l10n.t('animals.adoption'),
                        style: tt.titleLarge,
                      ),
                    ],
                  ),
                  if (isManager)
                    AdoptionToggle(
                      inAdoption: animal.inAdoption,
                      onToggle: () => onToggleAdoptionStatus(animal.inAdoption),
                    ),
                ],
              ),

              const SizedBox(height: 8),

              Text(
                animal.inAdoption
                    ? context.l10n.t('animals.availableForAdoption')
                    : context.l10n.t('animals.notAvailableForAdoption'),
                style: tt.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const Divider(height: 40),

              if (hasProcess) ...[
                Text(
                  context.l10n.t('animals.activeProcess'),
                  style: tt.titleMedium,
                ),
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
                  label: Text(context.l10n.t('animals.goToActiveAdoption')),
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
                        context.l10n.t('animals.adoptionNotificationHint'),
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
