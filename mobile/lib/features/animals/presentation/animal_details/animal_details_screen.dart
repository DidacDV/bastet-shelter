import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/basic_info/basic_info_tab.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/components/animal_details_header.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/medical_treatments/medical_info_tab.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/vet_visits/vet_info_tab.dart';
import 'package:bastetshelter/features/common/components/layout/app_tab_bar.dart';
import 'package:bastetshelter/providers/animals/animal_details_provider.dart';
import 'package:bastetshelter/providers/animals/animal_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimalDetailsScreen extends ConsumerWidget {
  final int animalId;

  const AnimalDetailsScreen({super.key, required this.animalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(animalDetailProvider(animalId));

    return Scaffold(
      backgroundColor: AppColors.background,
      body: detailAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Could not load animal.')),
        data: (animal) => AppTabLayout(
          header: SizedBox(
            height: MediaQuery.of(context).size.height * 0.30,
            child: AnimalDetailsHeader(
              name: animal.name,
              arrivalDate: animal.arrivalDate ?? animal.birthDate,
              birthday: animal.birthDate,
              canEdit: true,
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
              imageUrls: animal.images.map((img) => img.url).toList(),
            ),
          ),
          tabs: const [
            Tab(icon: Icon(Icons.info_outline), text: "Basic"),
            Tab(icon: Icon(Icons.pets_rounded), text: "Vet"),
            Tab(icon: Icon(Icons.medical_information), text: "Medical"),
            Tab(icon: Icon(Icons.task_alt), text: "Tasks"),
            Tab(icon: Icon(Icons.home_outlined), text: "Adopt"),
          ],
          tabViews: [
            BasicInfoTab(animalId: animalId),
            VetInfoTab(animalId: animalId),
            MedicalTreatmentsTab(animalId: animalId),
            const Icon(Icons.directions_bike),
            const Icon(Icons.directions_bike),
          ],
        ),
      ),
    );
  }
}
