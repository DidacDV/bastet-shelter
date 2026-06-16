import 'package:bastetshelter/features/animals/presentation/components/tasks_badge.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/widget_harness.dart';

void main() {
  testWidgets('TasksBadge renders in localized app shell', (tester) async {
    await pumpSimpleWidget(tester, const TasksBadge(count: 2));

    expect(find.text('2'), findsOneWidget);
  });
}
