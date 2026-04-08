import 'package:bastetshelter/features/medical/presentation/manage_medicines_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class VetInfoTab extends ConsumerWidget {
  final bool isManager;
  final int animalId;

  const VetInfoTab({super.key, this.isManager = true, required this.animalId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Row(
            children: [
              IconButton.filledTonal(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => const ManageMedicinesScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.medical_services_rounded),
                tooltip: 'Manage Shelter Medicines',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
