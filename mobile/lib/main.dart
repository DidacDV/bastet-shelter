import 'package:bastetshelter/core/guard/manager_guard.dart' show ManagerGuard;
import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/core/localization/locale_provider.dart';
import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/core/theme.dart';
import 'package:bastetshelter/features/shelter/presentation/configuration_screen.dart';
import 'package:bastetshelter/features/shelter/presentation/external_integration_screen.dart';
import 'package:bastetshelter/features/shelter/presentation/create_shelter_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:bastetshelter/features/auth/presentation/login_screen.dart';
import 'package:bastetshelter/features/auth/presentation/register_screen.dart';
import 'package:bastetshelter/features/home/presentation/home_screen.dart';
import 'package:bastetshelter/features/first_steps/presentation/code_entry_screen.dart';
import 'package:bastetshelter/features/first_steps/presentation/manager_picker_screen.dart';
import 'package:bastetshelter/features/first_steps/presentation/role_picker_screen.dart';
import 'package:bastetshelter/core/network/api_client.dart';
import 'package:bastetshelter/core/navigation_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configureDependencies();
  await getIt<ApiClient>().loadTokenFromStorage();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      onGenerateTitle: (context) => context.l10n.t('app.title'),
      navigatorKey: NavigationService.instance.navigationKey,
      theme: AppTheme.light,
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      initialRoute: getIt<ApiClient>().hasValidToken ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/role/picker': (_) => const RolePickerScreen(),
        '/role/volunteer-code': (_) =>
            const CodeEntryScreen(mode: CodeScreenMode.volunteer),
        '/role/manager-code': (_) =>
            const CodeEntryScreen(mode: CodeScreenMode.manager),
        '/role/manager-picker': (_) => const ManagerPickerScreen(),
        '/role/create-shelter': (_) => const CreateShelterScreen(),
        '/shelter/config': (_) => const ManagerGuard(child: ConfigScreen()),
        '/shelter/integration': (_) =>
            const ManagerGuard(child: ExternalIntegrationScreen()),
      },
    );
  }
}
