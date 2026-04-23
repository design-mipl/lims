import 'package:flutter_test/flutter_test.dart';

import 'package:limsv1/main.dart';

void main() {
  testWidgets('App shell shows placeholder page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump();
    expect(find.text('Page content (placeholder)'), findsOneWidget);
  });
}
