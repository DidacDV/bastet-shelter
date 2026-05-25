//intended to protect routes that require a manager, redirecting to home if not manager (checked with the provider)
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/providers/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManagerGuard extends ConsumerStatefulWidget {
  final Widget child;

  const ManagerGuard({super.key, required this.child});

  @override
  ConsumerState<ManagerGuard> createState() => _ManagerGuardState();
}

class _ManagerGuardState extends ConsumerState<ManagerGuard> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isManager = ref.read(isManagerProvider);
      if (!isManager) {
        //if not manager, redirect to home
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.t('common.managersOnly'))),
        );
        Navigator.of(context).pushReplacementNamed('/home');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isManager = ref.watch(isManagerProvider);
    if (!isManager) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    //if manager, redirect to correct screen
    return widget.child;
  }
}
