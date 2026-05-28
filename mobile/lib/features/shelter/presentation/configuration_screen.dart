import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/shelter/presentation/components/external_integration_card.dart';
import 'package:bastetshelter/features/shelter/presentation/components/management_card.dart';
import 'package:bastetshelter/features/shelter/presentation/components/refuges_card.dart';
import 'package:bastetshelter/features/shelter/presentation/components/shelter_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bastetshelter/providers/shelters/shelter_notifier.dart';

class ConfigScreen extends ConsumerWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelterAsync = ref.watch(shelterProvider);

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.t('shelter.configuration'))),
      body: shelterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(e.toString(), style: const TextStyle(color: Colors.red)),
        ),
        data: (shelter) => SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ShelterInfoCard(shelter: shelter),
              const SizedBox(height: 24),
              RefugesCard(shelter: shelter),
              const SizedBox(height: 24),
              const ExternalIntegrationCard(),
              const SizedBox(height: 24),
              ManagementCard(),
            ],
          ),
        ),
      ),
    );
  }
}
