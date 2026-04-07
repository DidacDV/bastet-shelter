import 'package:bastetshelter/features/medical/presentation/manage_medicines_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicalInfoTab extends ConsumerWidget {
  final bool isManager;

  const MedicalInfoTab({super.key, this.isManager = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              Navigator.of(context, rootNavigator: true).push(
                MaterialPageRoute(
                  builder: (context) => const ManageMedicinesScreen(),
                ),
              );
            },
            icon: const Icon(Icons.medical_services),
          ),
        ],
      ),
    );
  }
}
