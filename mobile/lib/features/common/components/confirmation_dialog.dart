import 'package:flutter/material.dart';

class ConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;

  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.isDestructive = false,
  });

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmationDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        isDestructive: isDestructive,
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      titleTextStyle: Theme.of(context).textTheme.titleLarge,
      titlePadding: const EdgeInsets.fromLTRB(28, 32, 28, 12),
      contentPadding: const EdgeInsets.fromLTRB(28, 0, 28, 32),
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      title: Text(title),
      content: Text(message),
      actions: [
        Row(
          children: [
            Expanded(
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelText),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style:
                    (isDestructive
                            ? FilledButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                              )
                            : FilledButton.styleFrom())
                        .copyWith(
                          padding: const WidgetStatePropertyAll(
                            EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmText),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
