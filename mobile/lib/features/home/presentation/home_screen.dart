import 'package:bastetshelter/core/constants.dart'; // Ensure AppColors is imported
import 'package:bastetshelter/features/community/presentation/community_screen.dart';
import 'package:bastetshelter/features/shifts/presentation/shifts_screen.dart';
import 'package:bastetshelter/features/tasks/presentation/tasks_screen.dart';
import 'package:bastetshelter/providers/geo/geo_provider.dart';
import 'package:bastetshelter/features/animals/presentation/animals_screen.dart';
import 'package:bastetshelter/features/common/components/layout/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bastetshelter/features/home/presentation/home_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final int initialIndex;
  const HomeScreen({super.key, this.initialIndex = 0});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
    Future.microtask(() => ref.read(geoProvider));
  }

  final List<GlobalKey<NavigatorState>> _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  final List<Widget> _tabs = const [
    HomeTab(),
    AnimalsScreen(),
    ShiftsScreen(),
    TasksScreen(),
    CommunityScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        final nav = _navigatorKeys[_selectedIndex].currentState;
        if (nav != null && nav.canPop()) {
          nav.pop();
        }
      },
      child: AppShell(
        showAppBar: true,
        child: Scaffold(
          backgroundColor: AppColors.background,
          body: Stack(
            children: List.generate(_tabs.length, (i) {
              return Offstage(
                offstage: _selectedIndex != i,
                child: Navigator(
                  key: _navigatorKeys[i],
                  onGenerateRoute: (_) =>
                      MaterialPageRoute(builder: (_) => _tabs[i]),
                ),
              );
            }),
          ),
          bottomNavigationBar: NavigationBarTheme(
            data: NavigationBarThemeData(
              backgroundColor: AppColors.background,
              surfaceTintColor: Colors.transparent,
              indicatorColor: AppColors.primary.withValues(alpha: 0.15),

              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  );
                }
                return const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                );
              }),

              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: AppColors.primary);
                }
                return const IconThemeData(color: AppColors.textSecondary);
              }),
            ),
            child: NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (i) => setState(() => _selectedIndex = i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Icon(Icons.pets_outlined),
                  selectedIcon: Icon(Icons.pets),
                  label: 'Animals',
                ),
                NavigationDestination(
                  icon: Icon(Icons.schedule_outlined),
                  selectedIcon: Icon(Icons.schedule),
                  label: 'Shifts',
                ),
                NavigationDestination(
                  icon: Icon(Icons.task_outlined),
                  selectedIcon: Icon(Icons.task),
                  label: 'Tasks',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outlined),
                  selectedIcon: Icon(Icons.people),
                  label: 'Community',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
