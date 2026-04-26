import 'package:flutter/material.dart';

enum StepState { completed, current, pending }

class VerticalStepperItem {
  final String label;
  final IconData? icon;
  final StepState state;

  const VerticalStepperItem({
    required this.label,
    required this.state,
    this.icon,
  });
}

class VerticalStepper extends StatelessWidget {
  final List<VerticalStepperItem> steps;
  final int selectedIndex;
  final ValueChanged<int> onStepTapped;
  final Color activeColor;
  final Color inactiveColor;

  const VerticalStepper({
    super.key,
    required this.steps,
    required this.selectedIndex,
    required this.onStepTapped,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        final isLast = i == steps.length - 1;
        final isReachable = step.state != StepState.pending;

        return Column(
          children: [
            GestureDetector(
              onTap: isReachable ? () => onStepTapped(i) : null,
              child: _Bubble(
                step: step,
                isSelected: selectedIndex == i,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
            ),
            if (!isLast)
              _Connector(
                filled: step.state == StepState.completed,
                activeColor: activeColor,
                inactiveColor: inactiveColor,
              ),
          ],
        );
      }).toList(),
    );
  }
}

class _Bubble extends StatelessWidget {
  final VerticalStepperItem step;
  final bool isSelected;
  final Color activeColor;
  final Color inactiveColor;

  const _Bubble({
    required this.step,
    required this.isSelected,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    final Color bg;
    final Color border;
    final Color contentColor;

    if (isSelected) {
      bg = activeColor;
      border = activeColor;
      contentColor = Colors.white;
    } else {
      switch (step.state) {
        case StepState.completed:
          //FINISHED STEPS
          bg = activeColor.withValues(alpha: 0.1);
          border = Colors.transparent;
          contentColor = activeColor;
          break;
        case StepState.current:
          //CURRENT STEP IS more resaltado
          bg = Colors.transparent;
          border = activeColor;
          contentColor = activeColor;
          break;
        case StepState.pending:
          //FUTURE STEPS are greyed out
          bg = Colors.transparent;
          border = inactiveColor.withValues(alpha: 0.8);
          contentColor = inactiveColor;
          break;
      }
    }

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: Border.all(
              color: border,
              width: step.state == StepState.pending && !isSelected ? 1.5 : 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: activeColor.withValues(alpha: 0.3),
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: step.state == StepState.completed
                ? Icon(Icons.check_rounded, size: 20, color: contentColor)
                : step.icon != null
                ? Icon(step.icon, size: 18, color: contentColor)
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          step.label,
          textAlign: TextAlign.center,
          style: tt.labelSmall?.copyWith(
            color: step.state == StepState.pending && !isSelected
                ? activeColor.withValues(alpha: 0.8)
                : tt.bodyMedium?.color,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _Connector extends StatelessWidget {
  final bool filled;
  final Color activeColor;
  final Color inactiveColor;

  const _Connector({
    required this.filled,
    required this.activeColor,
    required this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 2,
      height: 32,
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: filled
            ? activeColor.withValues(alpha: 0.5)
            : inactiveColor.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }
}
