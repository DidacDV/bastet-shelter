import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/%20components/animal_details_header.dart';
import 'package:bastetshelter/features/animals/presentation/animal_details/basic_info_tab.dart';
import 'package:bastetshelter/features/common/components/app_editable_field.dart';
import 'package:bastetshelter/features/common/components/app_tab_bar.dart';
import 'package:bastetshelter/features/common/components/edit_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnimalDetailsScreen extends ConsumerWidget {
  final int animalId;

  const AnimalDetailsScreen({super.key, required this.animalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AppTabLayout(
        header: SizedBox(
          height: MediaQuery.of(context).size.height * 0.35,
          child: AnimalDetailsHeader(
            name: "Mochi",
            arrivalDate: DateTime(2024, 3, 15),
            birthday: DateTime(2022, 7, 4),
          ),
        ),
        tabs: const [
          Tab(icon: Icon(Icons.info_outline), text: "Basic"),
          Tab(icon: Icon(Icons.medical_information_outlined), text: "Medical"),
          Tab(icon: Icon(Icons.task_alt), text: "Tasks"),
          Tab(icon: Icon(Icons.home_outlined), text: "Adoption"),
        ],
        tabViews: [
          BasicInfoTab(animalId: animalId),

          const Icon(Icons.directions_transit),
          const Icon(Icons.directions_bike),
          const Icon(Icons.directions_bike),
        ],
      ),
    );
  }
}
