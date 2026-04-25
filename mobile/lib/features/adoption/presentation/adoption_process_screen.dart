import 'package:bastetshelter/features/adoption/presentation/components/adoption_process_body.dart';
import 'package:bastetshelter/features/adoption/presentation/components/adoption_process_header.dart';
import 'package:bastetshelter/features/common/components/layout/app_bar.dart';
import 'package:bastetshelter/providers/adoption/adoption_screen_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdoptionProcessScreen extends ConsumerWidget {
  final int adoptionProcessId;

  const AdoptionProcessScreen({super.key, required this.adoptionProcessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenDataAsync = ref.watch(
      adoptionScreenDataProvider(adoptionProcessId),
    );

    return Scaffold(
      appBar: const BastetAppBar(
        customTitle: 'Adoption Process',
        showBackButton: true,
      ),
      body: screenDataAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading data')),
        data: (data) => Column(
          children: [
            AdoptionProcessHeader(
              process: data.process,
              animalName: data.animal.name,
              adoptantName: data.adoptant.name,
              animalImageUrl: data.animal.primaryImageUrl,
            ),
            Expanded(child: AdoptionProcessBody(steps: data.process.steps)),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text("footer here"),
            ),
          ],
        ),
      ),
    );
  }
}
