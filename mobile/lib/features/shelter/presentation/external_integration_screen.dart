import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/features/shelter/presentation/components/external_integration_card.dart';
import 'package:flutter/material.dart';

class ExternalIntegrationScreen extends StatelessWidget {
  const ExternalIntegrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.t('shelter.externalIntegration')),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: ExternalIntegrationCard(showHeader: false),
      ),
    );
  }
}
