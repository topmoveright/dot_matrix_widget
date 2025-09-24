import 'dart:math' as math;

import 'package:flutter/rendering.dart';

import '../core/dot_matrix_frame.dart';
import '../color/dot_color_mode.dart';
import '../shape/dot_shape.dart';

class DotMatrixPainter extends CustomPainter {
  DotMatrixPainter({
    required this.frame,
    required this.shape,
    required this.blankColor,
    required this.alphaThreshold,
    required this.colorStrategy,
  })  : _dotPaint = Paint()..style = PaintingStyle.fill,
        _blankPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = blankColor,
        _backgroundPaint = Paint()
          ..style = PaintingStyle.fill
          ..color = blankColor;

  final DotMatrixFrameData frame;
  final DotShape shape;
  final Color blankColor;
  final int alphaThreshold;
  final DotColorStrategy colorStrategy;

  final Paint _dotPaint;
  final Paint _blankPaint;
  final Paint _backgroundPaint;

  @override
  void paint(Canvas canvas, Size size) {
    if (frame.length == 0) {
      return;
    }

    // Paint solid background to mask the source widget beneath the overlay.
    _backgroundPaint.color = blankColor;
    canvas.drawRect(Offset.zero & size, _backgroundPaint);

    final double scale = _calculateUniformScale(size, frame.boardSize);
    final double dotSize = frame.dotSize * scale;
    final double spacing = frame.spacing * scale;
    final double cellSize = dotSize + spacing;
    final double radius = dotSize / 2;

    final double contentWidth = frame.columns * cellSize - spacing;
    final double contentHeight = frame.rows * cellSize - spacing;

    final double offsetX = (size.width - contentWidth) * (frame.alignment.x + 1) / 2;
    final double offsetY = (size.height - contentHeight) * (frame.alignment.y + 1) / 2;

    for (int row = 0; row < frame.rows; row++) {
      final double centerY = offsetY + row * cellSize + radius;
      for (int col = 0; col < frame.columns; col++) {
        final int index = row * frame.columns + col;
        final double centerX = offsetX + col * cellSize + radius;
        final Offset center = Offset(centerX, centerY);

        if (frame.alphaAt(index) > alphaThreshold) {
          _dotPaint.color = colorStrategy.transform(
            frame.colorAt(index),
            x: col,
            y: row,
            columns: frame.columns,
            rows: frame.rows,
          );
          shape.paint(canvas, center, dotSize, _dotPaint);
        } else {
          shape.paint(canvas, center, dotSize, _blankPaint);
        }
      }
    }
  }

  double _calculateUniformScale(Size available, Size content) {
    if (content.width == 0 || content.height == 0) {
      return 1.0;
    }
    final double scaleX = available.width / content.width;
    final double scaleY = available.height / content.height;
    if (scaleX.isInfinite || scaleY.isInfinite) {
      return 1.0;
    }
    return math.min(scaleX, scaleY);
  }

  @override
  bool shouldRepaint(covariant DotMatrixPainter oldDelegate) {
    return oldDelegate.frame != frame ||
        oldDelegate.shape.runtimeType != shape.runtimeType ||
        oldDelegate.blankColor != blankColor ||
        oldDelegate.alphaThreshold != alphaThreshold ||
        oldDelegate.colorStrategy.runtimeType != colorStrategy.runtimeType;
  }
}
