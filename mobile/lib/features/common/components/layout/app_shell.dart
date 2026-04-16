//this serves as a layout that is reused through the whole app, since it "shells" home screen
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  final bool showAppBar;

  const AppShell({super.key, required this.child, this.showAppBar = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(body: child);
  }
}
