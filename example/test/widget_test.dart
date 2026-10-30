import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:android_island_bar_example/main.dart';

void main() {
  testWidgets('Verify IslandBarShowcaseApp loads and renders presets', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const IslandBarShowcaseApp());
    await tester.pumpAndSettle();

    expect(find.text('Android Island Bar'), findsOneWidget);
    expect(find.text('Live Media Player'), findsOneWidget);
    expect(find.text('Countdown Timer'), findsOneWidget);

    // Scroll to see the multi-task card
    final scrollable = find.byType(Scrollable);
    expect(scrollable, findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Multi-Task Split Mode'),
      200.0,
      scrollable: scrollable,
    );
    await tester.pumpAndSettle();

    expect(find.text('Multi-Task Split Mode'), findsOneWidget);
  });
}
