import 'package:bastetshelter/core/service_locator.dart';
import 'package:bastetshelter/features/shelter/presentation/configuration_screen.dart';
import 'package:flutter/material.dart';

import 'package:bastetshelter/features/auth/presentation/login_screen.dart';
import 'package:bastetshelter/features/auth/presentation/register_screen.dart';
import 'package:bastetshelter/features/home/presentation/home_screen.dart';
import 'package:bastetshelter/features/shelter/presentation/code_entry_screen.dart';
import 'package:bastetshelter/features/shelter/presentation/manager_picker_screen.dart';
import 'package:bastetshelter/features/shelter/presentation/role_picker_screen.dart';
import 'package:bastetshelter/core/network/api_client.dart';
import 'package:bastetshelter/core/navigation_service.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  configureDependencies();
  await getIt<ApiClient>().loadTokenFromStorage();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bastet Shelter',
      navigatorKey: NavigationService.instance.navigationKey,
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.brown,
      ),
      initialRoute: getIt<ApiClient>().hasValidToken ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/role/picker':        (_) => const RolePickerScreen(),
        '/role/volunteer-code':  (_) => const CodeEntryScreen(mode: CodeScreenMode.volunteer),
        '/role/manager-code': (_) => const CodeEntryScreen(mode: CodeScreenMode.manager),
        '/role/manager-picker': (_) => const ManagerPickerScreen(),
        '/shelter/config': (_) => const ConfigScreen(),
      },
    );
  }
}
