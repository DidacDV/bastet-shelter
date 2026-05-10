import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/common/components/fields/date_chip.dart';
import 'package:bastetshelter/features/common/components/layout/app_bar.dart';
import 'package:bastetshelter/features/common/components/layout/app_tab_bar.dart';
import 'package:bastetshelter/providers/picked_refuge/current_refuge_provider.dart';
import 'package:bastetshelter/providers/shelters/shelter_notifier.dart';
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
  final int _initialTabIndex = DateTime.now().weekday - 1;

  @override
  void initState() {
    super.initState();
    _weekStart = _mondayOf(DateTime.now());
  }

  Future<void> _pickWeek(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _weekStart,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      helpText: 'Select any day in the week',
    );
    if (picked != null) {
      setState(() => _weekStart = _mondayOf(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
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
          return _DayShiftsTab(refugeId: activeRefugeId, day: day);
        });

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: BastetAppBar(
            customTitle: 'Shifts – $activeRefugeName',
            showLogout: false,
            showBackButton: true,
          ),
          body: AppTabLayout(
            initialIndex: _initialTabIndex,
            header: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Center(
                child: DateChip(
                  label: 'Week of',
                  date: _weekStart,
                  backgroundColor: AppColors.surface,
                  canEdit: true,
                  onEdit: () => _pickWeek(context),
                ),
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

class _DayShiftsTab extends StatelessWidget {
  const _DayShiftsTab({required this.refugeId, required this.day});

  final int refugeId;
  final DateTime day;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Text(
        'Shifts for ${day.day}/${day.month}/${day.year}\nRefuge $refugeId',
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}
