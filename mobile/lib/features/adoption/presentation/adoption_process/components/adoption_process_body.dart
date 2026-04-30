import 'package:bastetshelter/core/constants.dart';
import 'package:bastetshelter/features/adoption/data/adoption_enums.dart';
import 'package:bastetshelter/features/adoption/data/models/adoption_steps/adoption_step_details.dart';
import 'package:bastetshelter/features/adoption/presentation/adoption_process/components/steps/step_content.dart';
import 'package:bastetshelter/features/common/components/vertical_stepper.dart';
import 'package:flutter/material.dart' hide StepState;

class AdoptionProcessBody extends StatefulWidget {
  final List<AdoptionStepDetails> steps;
  final int processId;

  const AdoptionProcessBody({
    super.key,
    required this.steps,
    required this.processId,
  });

  @override
  State<AdoptionProcessBody> createState() => _AdoptionProcessBodyState();
}

class _AdoptionProcessBodyState extends State<AdoptionProcessBody> {
  @override
  void didUpdateWidget(covariant AdoptionProcessBody oldWidget) {
    super.didUpdateWidget(oldWidget);
    //change to the next (or whichever it is) step
    if (widget.steps != oldWidget.steps) {
      setState(() {
        _selectedIndex = _firstPendingIndex;
      });
    }
  }

  late int _selectedIndex;

  List<AdoptionStepDetails> get _sorted =>
      [...widget.steps]..sort((a, b) => a.order.compareTo(b.order));

  int get _firstPendingIndex {
    final i = _sorted.indexWhere((s) => s.status == StepStatus.pending);
    return i < 0 ? _sorted.length - 1 : i;
  }

  StepState _stateFor(AdoptionStepDetails step, int index) {
    if (step.status == StepStatus.completed ||
        step.status == StepStatus.rejected) {
      return StepState.completed;
    }
    if (index == _firstPendingIndex) return StepState.current;
    return StepState.pending;
  }

  @override
  void initState() {
    super.initState();
    _selectedIndex = _firstPendingIndex;
  }

  @override
  Widget build(BuildContext context) {
    final sorted = _sorted;

    final stepperItems = sorted.asMap().entries.map((entry) {
      return VerticalStepperItem(
        label: entry.value.type.label,
        icon: entry.value.type.icon,
        state: _stateFor(entry.value, entry.key),
      );
    }).toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
          child: VerticalStepper(
            steps: stepperItems,
            selectedIndex: _selectedIndex,
            activeColor: AppColors.secondary,
            inactiveColor: AppColors.divider,
            onStepTapped: (i) => setState(() => _selectedIndex = i),
          ),
        ),

        const VerticalDivider(width: 1),

        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: KeyedSubtree(
              key: ValueKey(_selectedIndex),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StepContent(
                      step: sorted[_selectedIndex],
                      processId: widget.processId,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
