import 'package:flutter_test/flutter_test.dart';
import 'package:sennamobile/main.dart';

void main() {
  testWidgets('SennaApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SennaApp());
    expect(find.text('SENNINHA '), findsWidgets);
    expect(find.text('Controle'), findsOneWidget);
    expect(find.text('Telemetria'), findsOneWidget);
  });
}
