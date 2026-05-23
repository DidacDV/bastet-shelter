import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:flutter/material.dart';

class ApiErrorWidget extends StatelessWidget {
  final Object error;
  final VoidCallback onRetry;
  final String? message;

  const ApiErrorWidget({
    super.key,
    required this.error,
    required this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off,
              size: 28,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              message ?? error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(context.l10n.t('common.tryAgain')),
            ),
          ],
        ),
      ),
    );
  }
}
