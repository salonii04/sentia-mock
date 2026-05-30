// Basic smoke test for SentiaApp
import 'package:flutter_test/flutter_test.dart';
import 'package:sentia_ai/main.dart';

void main() {
  testWidgets('SentiaApp launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const SentiaApp());
    expect(find.byType(SentiaApp), findsOneWidget);
  });
}

