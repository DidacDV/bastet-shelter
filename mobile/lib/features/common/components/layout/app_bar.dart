import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/features/auth/data/auth_repository.dart';
import 'package:bastetshelter/features/shelter/presentation/configuration_screen.dart';
import 'package:bastetshelter/providers/animals/animal_provider.dart';
import 'package:bastetshelter/providers/auth/auth_provider.dart';
import 'package:bastetshelter/providers/shelters/shelter_notifier.dart';
import 'package:bastetshelter/providers/traits/trait_provider.dart';
import 'package:bastetshelter/providers/vet_visits/vet_visit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BastetAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String? customTitle;
  final bool showBackButton;
  final bool showConfig;
  final bool showLogout;

  const BastetAppBar({
    super.key,
    this.customTitle,
    this.showBackButton = false,
    this.showConfig = true,
    this.showLogout = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shelterAsync = ref.watch(shelterProvider);
    final isManager = ref.watch(isManagerProvider);

    return AppBar(
      title: customTitle != null
          ? Text(customTitle!)
          : shelterAsync.when(
              data: (shelter) => Text(shelter.name),
              loading: () => const Text('Loading...'),
              error: (_, _) => const Text('Bastet Shelter'),
            ),
      backgroundColor: AppColors.background,
      elevation: 0,
      automaticallyImplyLeading: showBackButton,
      actions: [
        if (isManager && showConfig)
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Navigator.of(
              context,
              rootNavigator: true,
            ).push(MaterialPageRoute(builder: (_) => const ConfigScreen())),
          ),

        if (showLogout)
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              ref.invalidate(shelterProvider);
              ref.invalidate(animalsProvider);
              ref.invalidate(traitsProvider);
              ref.invalidate(vetVisitsProvider);
              await getIt<AuthRepository>().logout();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
