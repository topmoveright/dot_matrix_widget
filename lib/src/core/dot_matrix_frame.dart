import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// Represents a processed dot-matrix frame ready for painting.
class DotMatrixFrameData {
  const DotMatrixFrameData({
    required this.columns,
    required this.rows,
    required this.dotSize,
    required this.spacing,
    required this.alignment,
    required this.boardSize,
    required this.sampledColors,
    required this.alphaMask,
  })  : assert(columns > 0),
        assert(rows > 0),
        assert(dotSize > 0);

  final int columns;
  final int rows;
  final double dotSize;
  final double spacing;
  final Alignment alignment;
  final ui.Size boardSize;
  final List<ui.Color> sampledColors;
  final List<int> alphaMask;

  int get length => sampledColors.length;

  ui.Color colorAt(int index) => sampledColors[index];

  int alphaAt(int index) => alphaMask[index];

  ui.Color colorAtPosition(int x, int y) {
    assert(x >= 0 && x < columns);
    assert(y >= 0 && y < rows);
    return sampledColors[y * columns + x];
  }

  int alphaAtPosition(int x, int y) {
    assert(x >= 0 && x < columns);
    assert(y >= 0 && y < rows);
    return alphaMask[y * columns + x];
  }
}
