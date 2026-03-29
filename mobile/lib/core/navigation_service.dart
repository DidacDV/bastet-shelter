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

  // TODO create custom snackbar that follows app theme
  void showSnackBar(String message, {bool isError = false}) {
    final context = navigationKey.currentContext;
    if (context == null) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.blue : null,
      ),
    );
  }

}