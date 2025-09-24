// This is a basic Flutter integration test.
//
// Since integration tests run in a full Flutter application, they can interact
// with the host side of a plugin implementation, unlike Dart unit tests.
//
// For more information about Flutter integration tests, please see
// https://flutter.dev/to/integration-testing

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:dot_matrix_widget/dot_matrix_widget.dart';
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders dot matrix widget', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: DotMatrixWidget(
              dotSize: 6,
              spacing: 2,
              child: Text('integration test'),
            ),
          ),
        ),
      ),
    );

    // Allow capture pipeline to run at least once.
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(find.text('integration test'), findsOneWidget);
  });
}
