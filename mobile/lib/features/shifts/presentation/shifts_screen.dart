import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/fields/week_picker_chip.dart';
import 'package:bastetshelter/features/common/components/layout/app_bar.dart';
import 'package:bastetshelter/features/common/components/layout/app_tab_bar.dart';
import 'package:bastetshelter/features/shifts/presentation/components/copy_week_bottomsheet.dart';
import 'package:bastetshelter/features/shifts/presentation/components/create_shift_bottomsheet.dart';
import 'package:bastetshelter/features/shifts/presentation/components/shift_card.dart';
import 'package:bastetshelter/features/shifts/presentation/shift_details_screen.dart';
import 'package:bastetshelter/providers/auth/auth_provider.dart';
import 'package:bastetshelter/providers/picked_refuge/current_refuge_provider.dart';
import 'package:bastetshelter/providers/shelters/shelter_notifier.dart';
import 'package:bastetshelter/providers/shifts/shift_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

DateTime _mondayOf(DateTime d) => d.subtract(Duration(days: d.weekday - 1));

const _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

class ShiftsScreen extends ConsumerStatefulWidget {
  const ShiftsScreen({super.key});

  @override
  ConsumerState<ShiftsScreen> createState() => _ShiftsScreenState();
}

class _ShiftsScreenState extends ConsumerState<ShiftsScreen> {
  late DateTime _weekStart;
  int _currentTabIndex = DateTime.now().weekday - 1; //mon=0 … Sun=6
  late final isManager = ref.watch(isManagerProvider);

  @override
  void initState() {
    super.initState();
    _weekStart = _mondayOf(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final isManager = ref.watch(isManagerProvider);
    final shelterAsync = ref.watch(shelterProvider);
    final selectedRefugeId = ref.watch(currentRefugeProvider);

    return shelterAsync.when(
      loading: () => const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: Text('Error loading shelter: $e')),
      ),
      data: (shelter) {
        if (shelter.refuges.isEmpty) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            appBar: BastetAppBar(customTitle: 'Shifts', showLogout: false),
            body: Center(child: Text('No refuges available.')),
          );
        }

        final activeRefugeId = selectedRefugeId ?? shelter.refuges.first.id;
        final activeRefugeName = shelter.refuges
            .firstWhere(
              (r) => r.id == activeRefugeId,
              orElse: () => shelter.refuges.first,
            )
            .name;

        final dayViews = List.generate(7, (i) {
          final day = _weekStart.add(Duration(days: i));
          return _DayShiftsTab(
            refugeId: activeRefugeId,
            day: day,
            weekStart: _weekStart,
            isManager: isManager,
          );
        });

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: BastetAppBar(
            customTitle: 'Shifts – $activeRefugeName',
            showLogout: false,
            showBackButton: true,
          ),

          floatingActionButton: isManager
              ? FloatingActionButton(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surface,
                  onPressed: () {
                    final activeDay = _weekStart.add(
                      Duration(days: _currentTabIndex),
                    );

                    showCreateShiftBottomSheet(
                      context: context,
                      refugeId: activeRefugeId,
                      weekStart: _weekStart,
                      initialDate: activeDay,
                    );
                  },
                  child: const Icon(Icons.add_rounded),
                )
              : null,

          body: AppTabLayout(
            initialIndex: _currentTabIndex,
            onTabChanged: (index) {
              setState(() {
                _currentTabIndex = index;
              });
            },
            header: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  WeekPickerChip(
                    date: _weekStart,
                    showArrows: true,
                    onWeekSelected: (newDate) {
                      setState(() => _weekStart = newDate);
                    },
                  ),
                  const SizedBox(width: 8),

                  if (isManager)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.outline),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.copy_all_rounded,
                          color: AppColors.reddish,
                        ),
                        tooltip: 'Copy shifts from past week',
                        onPressed: () {
                          showCopyWeekBottomSheet(
                            context: context,
                            refugeId: activeRefugeId,
                            targetWeekStart: _weekStart,
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            tabs: List.generate(7, (i) => Tab(text: _dayLabels[i])),
            tabViews: dayViews,
          ),
        );
      },
    );
  }
}

class _DayShiftsTab extends ConsumerWidget {
  const _DayShiftsTab({
    required this.refugeId,
    required this.weekStart,
    required this.day,
    required this.isManager,
  });

  final int refugeId;
  final DateTime weekStart;
  final DateTime day;
  final bool isManager;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shiftsAsync = ref.watch(shiftsProvider(refugeId, weekStart));

    return shiftsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error loading shifts: $e')),
      data: (allShifts) {
        //this tab days only
        final dayShifts = allShifts
            .where(
              (s) =>
                  s.day.year == day.year &&
                  s.day.month == day.month &&
                  s.day.day == day.day,
            )
            .toList();

        if (dayShifts.isEmpty) {
          return Center(
            child: Text(
              'No shifts for this day.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: dayShifts.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (_, i) => ShiftCard(
            shift: dayShifts[i],
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ShiftDetailScreen(
                  shiftId: dayShifts[i].id,
                  refugeName: 'Shelter Name',
                  isManager: isManager,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
