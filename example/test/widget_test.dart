import 'package:android_island_bar_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Flux Island loads real device cockpit and tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const FluxIslandApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('FLUX ISLAND'), findsOneWidget);
    expect(find.text('Island Hub'), findsOneWidget);
    expect(find.text('Cutout Tuner'), findsOneWidget);
    expect(find.text('Themes'), findsOneWidget);
    expect(find.text('Real Hardware Telemetry'), findsOneWidget);
    expect(find.text('System Clipboard'), findsOneWidget);
  });
}
