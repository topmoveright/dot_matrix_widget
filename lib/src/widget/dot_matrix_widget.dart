import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../color/dot_color_mode.dart';
import '../core/dot_matrix_frame.dart';
import '../painter/dot_matrix_painter.dart';
import '../renderer/dot_matrix_renderer.dart';
import '../shape/dot_shape.dart';
import '../style/dot_matrix_style.dart';

/// Renders any widget as a dot-matrix display.
class DotMatrixWidget extends StatefulWidget {
  const DotMatrixWidget({
    super.key,
    required this.child,
    this.dotSize = 4,
    this.spacing = 2,
    this.alignment = Alignment.center,
    this.shape = DotShapeType.circle,
    this.colorMode = DotColorMode.original,
    this.singleColor,
    this.stylePreset,
    this.blankColor = const Color(0x11000000),
    this.alphaThreshold = 16,
    this.pixelRatio,
    this.captureInterval = const Duration(milliseconds: 33),
    this.overlayVisible = true,
  }) : assert(dotSize > 0),
       assert(spacing >= 0),
       assert(alphaThreshold >= 0 && alphaThreshold <= 255);

  /// The widget to render in dot-matrix style.
  final Widget child;

  /// The diameter/edge-size of each dot.
  final double dotSize;

  /// Spacing between dots.
  final double spacing;

  /// Alignment of the rendered frame inside the available space.
  final Alignment alignment;

  /// Geometric shape of individual dots.
  final DotShapeType shape;

  /// Color transformation mode.
  final DotColorMode colorMode;

  /// Color used when [colorMode] is [DotColorMode.singleColor].
  final Color? singleColor;

  /// Style preset used when [colorMode] is [DotColorMode.preset].
  final DotMatrixStylePreset? stylePreset;

  /// Background color for "off" dots.
  final Color blankColor;

  /// Alpha channel threshold (0-255) to decide if a dot is lit.
  final int alphaThreshold;

  /// Optional pixel ratio override for capture.
  final double? pixelRatio;

  /// Minimum interval between successive frame captures. Set to [Duration.zero]
  /// to disable throttling.
  final Duration? captureInterval;

  /// Whether the dot-matrix overlay should be displayed above the child.
  final bool overlayVisible;

  @override
  State<DotMatrixWidget> createState() => _DotMatrixWidgetState();
}

class _DotMatrixWidgetState extends State<DotMatrixWidget> {
  final GlobalKey _repaintKey = GlobalKey();
  final DotMatrixRenderer _renderer = const DotMatrixRenderer();
  final DotColorStrategyFactory _colorFactory = const DotColorStrategyFactory();

  DotMatrixFrameData? _frame;
  BoxConstraints? _lastConstraints;

  bool _captureScheduled = false;
  bool _isCapturing = false;
  bool _pendingCapture = false;
  DateTime? _lastCaptureTime;
  Timer? _throttleTimer;

  @override
  void initState() {
    super.initState();
    _scheduleCapture();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scheduleCapture();
  }

  @override
  void didUpdateWidget(covariant DotMatrixWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool requiresCapture =
        widget.child != oldWidget.child ||
        widget.dotSize != oldWidget.dotSize ||
        widget.spacing != oldWidget.spacing ||
        widget.pixelRatio != oldWidget.pixelRatio;

    if (requiresCapture) {
      _scheduleCapture();
    }

    final bool visualChange =
        widget.colorMode != oldWidget.colorMode ||
        widget.stylePreset != oldWidget.stylePreset ||
        widget.blankColor != oldWidget.blankColor ||
        widget.shape != oldWidget.shape ||
        widget.alphaThreshold != oldWidget.alphaThreshold ||
        widget.alignment != oldWidget.alignment ||
        widget.overlayVisible != oldWidget.overlayVisible ||
        widget.captureInterval != oldWidget.captureInterval;

    if (visualChange) {
      setState(() {});
    }

  }

  @override
  void dispose() {
    _throttleTimer?.cancel();
    super.dispose();
  }

  void _scheduleCapture() {
    if (!mounted) return;
    if (_captureScheduled) return;

    final Duration? interval = widget.captureInterval;
    if (interval != null && interval > Duration.zero && _lastCaptureTime != null) {
      final Duration elapsed = DateTime.now().difference(_lastCaptureTime!);
      if (elapsed < interval) {
        final Duration remaining = interval - elapsed;
        _captureScheduled = true;
        _throttleTimer?.cancel();
        _throttleTimer = Timer(remaining, () {
          _throttleTimer = null;
          if (!mounted) {
            _captureScheduled = false;
            return;
          }
          _captureScheduled = false;
          _scheduleCapture();
        });
        return;
      }
    }

    _captureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _captureScheduled = false;
      await _captureFrame();
    });
  }

  void _handleConstraints(BoxConstraints constraints) {
    if (_lastConstraints == constraints) {
      return;
    }
    _lastConstraints = constraints;
    _scheduleCapture();
  }

  Future<void> _captureFrame() async {
    if (!mounted) {
      return;
    }
    if (_isCapturing) {
      _pendingCapture = true;
      return;
    }

    final BuildContext? context = _repaintKey.currentContext;
    if (context == null) {
      _pendingCapture = true;
      return;
    }

    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is! RenderRepaintBoundary) {
      _pendingCapture = true;
      return;
    }

    final RenderRepaintBoundary boundary = renderObject;

    if (boundary.size.isEmpty) {
      _pendingCapture = true;
      return;
    }

    if (boundary.debugNeedsPaint) {
      _pendingCapture = true;
      SchedulerBinding.instance.addPostFrameCallback((_) async {
        await _captureFrame();
      });
      return;
    }

    _isCapturing = true;
    ui.Image? capturedImage;
    try {
      final double pixelRatio =
          widget.pixelRatio ??
          MediaQuery.maybeOf(context)?.devicePixelRatio ??
          1.0;
      capturedImage = await boundary.toImage(pixelRatio: pixelRatio);
      final DotMatrixFrameData frame = await _renderer.render(
        image: capturedImage,
        dotSize: widget.dotSize,
        spacing: widget.spacing,
        alignment: widget.alignment,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _frame = frame;
      });
      _lastCaptureTime = DateTime.now();
    } catch (error) {
      debugPrint('DotMatrixWidget capture failed: $error');
    } finally {
      capturedImage?.dispose();
      _isCapturing = false;
      if (_pendingCapture) {
        _pendingCapture = false;
        _scheduleCapture();
      }
    }
  }

  DotColorStrategy _buildColorStrategy() {
    return _colorFactory.create(
      mode: widget.colorMode,
      fallbackColor: widget.singleColor,
      preset: widget.stylePreset,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _handleConstraints(constraints);
        final DotMatrixFrameData? frame = _frame;
        final DotColorStrategy colorStrategy = _buildColorStrategy();
        final DotShape shape = widget.shape.toShape();
        final CustomPainter? painter = frame == null
            ? null
            : DotMatrixPainter(
                frame: frame,
                shape: shape,
                blankColor: widget.blankColor,
                alphaThreshold: widget.alphaThreshold,
                colorStrategy: colorStrategy,
              );

        return Stack(
          fit: StackFit.expand,
          children: [
            IgnorePointer(
              child: RepaintBoundary(
                key: _repaintKey,
                child: SizedBox.expand(child: widget.child),
              ),
            ),
            if (painter != null && widget.overlayVisible)
              Positioned.fill(
                child: CustomPaint(painter: painter, isComplex: true),
              ),
          ],
        );
      },
    );
  }
}
