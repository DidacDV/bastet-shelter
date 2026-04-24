import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/layout/app_bar.dart';
import 'package:flutter/material.dart';

class AdoptionProcessScreen extends StatelessWidget {
  final int adoptionProcessId;

  const AdoptionProcessScreen({super.key, required this.adoptionProcessId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const BastetAppBar(
        customTitle: 'Adoption Process',
        showBackButton: true,
        showConfig: false,
        showLogout: false,
      ),
      body: Center(
        child: Text(
          'Process ID: $adoptionProcessId',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      ),
    );
  }
}
