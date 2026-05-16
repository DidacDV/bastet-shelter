// Source - https://stackoverflow.com/a/63325745
// Posted by S.R Keshav
// Retrieved 2026-03-16, License - CC BY-SA 4.0

import 'package:flutter/material.dart';

class NavigationService {
  final GlobalKey<NavigatorState> navigationKey = GlobalKey<NavigatorState>();

  static final NavigationService instance = NavigationService();

  Future<dynamic> navigateToReplacement(String routeName) {
    return navigationKey.currentState!.pushReplacementNamed(routeName);
  }

  Future<dynamic> navigateTo(String routeName) {
    return navigationKey.currentState!.pushNamed(routeName);
  }

  Future<dynamic> navigateToRoute(MaterialPageRoute route) {
    return navigationKey.currentState!.push(route);
  }

  void goBack() {
    return navigationKey.currentState!.pop();
  }

  void redirectToLogin() {
    navigationKey.currentState!.pushNamedAndRemoveUntil('/login', (_) => false);
  }

  void showSnackBar(String message, {bool isError = false}) {
    final context = navigationKey.currentContext;
    if (context == null) return;

    final theme = Theme.of(context);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            spacing: 12,
            children: [
              Icon(
                isError ? Icons.error_outline : Icons.check_circle_outline,
                color: isError
                    ? theme.colorScheme.onError
                    : theme.colorScheme.onPrimary,
              ),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isError
                        ? theme.colorScheme.onError
                        : theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: isError
              ? theme.colorScheme.secondary
              : theme.colorScheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
  }
}
