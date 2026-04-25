import 'package:bastetshelter/features/common/components/layout/app_bar.dart';
import 'package:bastetshelter/providers/adoption/adoption_screen_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AdoptionProcessScreen extends ConsumerWidget {
  final int adoptionProcessId;

  const AdoptionProcessScreen({super.key, required this.adoptionProcessId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the composite provider!
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
        data: (data) {
          return Column(
            children: [
              Text('Process Status: ${data.process.status.name}'),
              Text('Animal Name: ${data.animal.name}'),
              Text('Adoptant Email: ${data.adoptant.email}'),
            ],
          );
        },
      ),
    );
  }
}
