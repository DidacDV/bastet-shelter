import 'package:bastetshelter/features/animals/presentation/components/tasks_badge.dart';
import 'package:bastetshelter/features/common/components/manage_list_card.dart';
import 'package:bastetshelter/features/animals/data/models/animal_summary_model.dart';
import 'package:bastetshelter/features/shifts/data/models/shift_task_model.dart';
import 'package:bastetshelter/features/shifts/presentation/components/pending_shift_task_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/fixtures.dart';
import '../helpers/widget_harness.dart';

void main() {
  group('TasksBadge', () {
    testWidgets('shows task count', (tester) async {
      await pumpSimpleWidget(tester, const TasksBadge(count: 4));

      expect(find.text('4'), findsOneWidget);
      expect(find.byIcon(Icons.assignment_outlined), findsOneWidget);
    });
  });

  group('ManageListCard', () {
    testWidgets('renders title and handles tap', (tester) async {
      var tapped = false;

      await pumpLocalizedWidget(
        tester,
        ManageListCard(
          title: 'Clean kennels',
          leadingIcon: Icons.cleaning_services,
          onTap: () => tapped = true,
        ),
      );

      expect(find.text('Clean kennels'), findsOneWidget);
      await tester.tap(find.byType(InkWell));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('shows edit and delete actions when provided', (tester) async {
      await pumpLocalizedWidget(
        tester,
        ManageListCard(
          title: 'Task item',
          leadingIcon: Icons.task_alt,
          onEdit: () {},
          onDelete: () {},
        ),
      );

      expect(find.byIcon(Icons.edit_rounded), findsOneWidget);
      expect(find.byIcon(Icons.delete_rounded), findsOneWidget);
    });
  });

  group('PendingShiftTaskCard', () {
    testWidgets('renders pending task title and description', (tester) async {
      await pumpLocalizedWidget(
        tester,
        PendingShiftTaskCard(
          shiftTask: buildShiftTask(title: 'Feed cats'),
          isEven: true,
          onAssignToMe: () async {},
          onUnassign: () async {},
          onToggleCompletion: () async {},
        ),
      );

      expect(find.text('Feed cats'), findsOneWidget);
      expect(find.text('Walk the dog'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsOneWidget);
    });

    testWidgets('renders completed task with check icon', (tester) async {
      await pumpLocalizedWidget(
        tester,
        PendingShiftTaskCard(
          shiftTask: buildShiftTask(
            status: ShiftTaskStatus.completed,
            title: 'Done task',
          ),
          isEven: false,
          onAssignToMe: () async {},
          onUnassign: () async {},
          onToggleCompletion: () async {},
        ),
      );

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('shows animal name when enabled', (tester) async {
      await pumpLocalizedWidget(
        tester,
        PendingShiftTaskCard(
          shiftTask: buildShiftTask(
            animal: const AnimalSummary(
              id: 1,
              name: 'Luna',
              age: 2,
              inAdoption: true,
              pendingShiftTasks: 1,
              refugeName: 'Main',
            ),
          ),
          isEven: true,
          showAnimalName: true,
          onAssignToMe: () async {},
          onUnassign: () async {},
          onToggleCompletion: () async {},
        ),
      );

      expect(find.textContaining('Luna'), findsOneWidget);
    });
  });
}
