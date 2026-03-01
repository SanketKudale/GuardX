// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:guardx_example/main.dart';

void main() {
  testWidgets('renders GuardX buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Throw Flutter Error'), findsOneWidget);
    expect(find.text('Throw Async Error'), findsOneWidget);
    expect(find.text('Add Breadcrumb'), findsOneWidget);
    expect(find.text('View Recent Events'), findsOneWidget);
  });
}
