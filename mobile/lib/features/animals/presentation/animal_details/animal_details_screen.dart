import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/adoption/adoption_tab.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/basic_info/basic_info_tab.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/components/animal_details_header.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/medical_treatments/medical_info_tab.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/tasks/animal_tasks_tab.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/vet_visits/vet_info_tab.dart';
import 'package:bastetshelter/features/common/components/layout/app_bar.dart';
import 'package:bastetshelter/features/common/components/layout/app_tab_bar.dart';
import 'package:bastetshelter/providers/animals/animal_details_provider.dart';
import 'package:bastetshelter/providers/animals/animal_provider.dart';
import 'package:bastetshelter/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimalDetailsScreen extends ConsumerWidget {
  final int animalId;

  const AnimalDetailsScreen({super.key, required this.animalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(animalDetailProvider(animalId));
    final isManager = ref.watch(isManagerProvider);

    return detailAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        body: Center(child: Text(context.l10n.t('animals.detailLoadError'))),
      ),
      data: (animalDetails) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: BastetAppBar(
          customTitle: context.l10n.t('animals.detailsTitle'),
          showBackButton: true,
          showLogout: false,
        ),
        body: AppTabLayout(
          showOnlySelectedLabel: true,
          header: SizedBox(
            height: MediaQuery.of(context).size.height * 0.30,
            child: AnimalDetailsHeader(
              animal: animalDetails,
              canEdit: isManager,
              onArrivalDateSave: (newDate) async {
                await ref
                    .read(animalsProvider.notifier)
                    .updateAnimal(animalId: animalId, arrivalDate: newDate);
              },
              onBirthdaySave: (newDate) async {
                await ref
                    .read(animalsProvider.notifier)
                    .updateAnimal(animalId: animalId, birthDate: newDate);
              },
              onNameSave: (newName) async {
                await ref
                    .read(animalsProvider.notifier)
                    .updateAnimal(animalId: animalId, name: newName);
              },
              imageUrls: animalDetails.images.map((img) => img.url).toList(),
            ),
          ),
          tabs: [
            Tab(
              icon: const Icon(Icons.info_outline),
              text: context.l10n.t('animals.tabBasic'),
            ),
            Tab(
              icon: const Icon(Icons.pets_rounded),
              text: context.l10n.t('animals.tabVet'),
            ),
            Tab(
              icon: const Icon(Icons.medical_information),
              text: context.l10n.t('animals.tabMedical'),
            ),
            Tab(
              icon: const Icon(Icons.task_alt),
              text: context.l10n.t('navigation.tasks'),
            ),
            Tab(
              icon: const Icon(Icons.home_outlined),
              text: context.l10n.t('animals.tabAdopt'),
            ),
          ],
          tabViews: [
            BasicInfoTab(animalId: animalId, isManager: isManager),
            VetInfoTab(animalId: animalId, isManager: isManager),
            MedicalTreatmentsTab(animalId: animalId, isManager: isManager),
            AnimalTasksTab(animalId: animalId),
            AdoptionTab(animalId: animalId, isManager: isManager),
          ],
        ),
      ),
    );
  }
}
