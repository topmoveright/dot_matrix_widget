// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:dot_matrix_widget/dot_matrix_widget.dart';
import 'package:dot_matrix_widget_example/main.dart';

void main() {
  testWidgets('renders dot matrix demo app', (WidgetTester tester) async {
    await tester.pumpWidget(const DotMatrixExampleApp());

    // Allow layout to stabilize and dot matrix capture to run.
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(find.text('Dot Matrix Widget Demo'), findsOneWidget);
    expect(find.byType(DotMatrixWidget), findsWidgets);
  });
}
