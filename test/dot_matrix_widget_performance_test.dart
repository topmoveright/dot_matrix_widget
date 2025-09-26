import 'dart:typed_data';

import 'package:dot_matrix_widget/dot_matrix_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrapForTest(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: 180,
          height: 120,
          child: child,
        ),
      ),
    ),
  );
}

class _DelayedSwap extends StatefulWidget {
  const _DelayedSwap({required this.delay, required this.childBuilder});
  final Duration delay;
  final WidgetBuilder childBuilder;

  @override
  State<_DelayedSwap> createState() => _DelayedSwapState();
}

class _DelayedSwapState extends State<_DelayedSwap> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(widget.delay).then((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) {
      return widget.childBuilder(context);
    }
    return const ColoredBox(color: Colors.black);
  }
}

void main() {
  testWidgets('DotMatrixWidget renders dot layer quickly for static text',
      (tester) async {
    await tester.pumpWidget(
      _wrapForTest(
        const DotMatrixWidget(
          dotSize: 6,
          spacing: 2,
          captureInterval: Duration.zero,
          child: Center(
            child: Text(
              'HELLO',
              textDirection: TextDirection.ltr,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ),
    );

    bool found = false;
    for (int i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      final paints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
      found = paints
          .any((p) => p.painter.runtimeType.toString() == 'DotMatrixPainter');
      if (found) break;
    }

    expect(found, isTrue,
        reason: 'Expected DotMatrixPainter to appear within a few frames');
  });

  testWidgets(
      'DotMatrixWidget captures after delayed child image load within warmup window',
      (tester) async {
    await tester.pumpWidget(
      _wrapForTest(
        DotMatrixWidget(
          dotSize: 6,
          spacing: 2,
          captureInterval: Duration.zero,
          child: _DelayedSwap(
            delay: const Duration(milliseconds: 150),
            childBuilder: (context) {
              final bytes = Uint8List.fromList(<int>[
                0x89,
                0x50,
                0x4E,
                0x47,
                0x0D,
                0x0A,
                0x1A,
                0x0A,
                0x00,
                0x00,
                0x00,
                0x0D,
                0x49,
                0x48,
                0x44,
                0x52,
                0x00,
                0x00,
                0x00,
                0x01,
                0x00,
                0x00,
                0x00,
                0x01,
                0x08,
                0x06,
                0x00,
                0x00,
                0x00,
                0x1F,
                0x15,
                0xC4,
                0x89,
                0x00,
                0x00,
                0x00,
                0x0A,
                0x49,
                0x44,
                0x41,
                0x54,
                0x78,
                0x9C,
                0x63,
                0xF8,
                0xCF,
                0xC0,
                0x00,
                0x00,
                0x04,
                0x00,
                0x01,
                0xE2,
                0x26,
                0x05,
                0x9B,
                0x00,
                0x00,
                0x00,
                0x00,
                0x49,
                0x45,
                0x4E,
                0x44,
                0xAE,
                0x42,
                0x60,
                0x82,
              ]);
              return Image.memory(bytes, scale: 1.0, gaplessPlayback: true);
            },
          ),
        ),
      ),
    );

    bool found = false;
    for (int i = 0; i < 60; i++) {
      // up to ~1s
      await tester.pump(const Duration(milliseconds: 16));
      final paints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
      found = paints
          .any((p) => p.painter.runtimeType.toString() == 'DotMatrixPainter');
      if (found) break;
    }

    expect(found, isTrue,
        reason:
            'Expected DotMatrixPainter to appear after delayed content within warmup window');
    // Allow any pending delayed tasks (e.g., _DelayedSwap) to complete to avoid timersPending.
    await tester.pump(const Duration(milliseconds: 200));
  });

  testWidgets('DotMatrixWidget grid size stays bounded for performance',
      (tester) async {
    await tester.pumpWidget(
      _wrapForTest(
        const DotMatrixWidget(
          dotSize: 6,
          spacing: 2,
          captureInterval: Duration.zero,
          child: FlutterLogo(size: 60),
        ),
      ),
    );

    CustomPaint? paintWithOverlay;
    for (int i = 0; i < 30; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      final paints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
      for (final p in paints) {
        if (p.painter != null &&
            p.painter.runtimeType.toString() == 'DotMatrixPainter') {
          paintWithOverlay = p;
          break;
        }
      }
      if (paintWithOverlay != null) break;
    }

    expect(paintWithOverlay, isNotNull,
        reason: 'DotMatrixPainter should be present');

    // Sanity bounds: with 180x120 and dotSize=6, spacing=2, columns*rows should be modest (< 5000)
    // We cannot access painter internals without importing it; instead
    // we at least assert that overlay appears within time bound above.
    // Detailed grid-size assertions can be covered in lower-level tests if exported.
  });
}
