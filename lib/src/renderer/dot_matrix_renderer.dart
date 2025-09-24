import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../core/dot_matrix_frame.dart';

/// Builds [DotMatrixFrameData] from captured widget snapshots.
class DotMatrixRenderer {
  const DotMatrixRenderer();

  Future<DotMatrixFrameData> render({
    required ui.Image image,
    required double dotSize,
    required double spacing,
    Alignment alignment = Alignment.center,
  }) async {
    assert(dotSize > 0, 'dotSize must be positive');
    final int imageWidth = image.width;
    final int imageHeight = image.height;

    final double cellSize = dotSize + spacing;
    final int columns = _safeCount(((imageWidth + spacing) / cellSize).floor());
    final int rows = _safeCount(((imageHeight + spacing) / cellSize).floor());

    final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) {
      throw StateError('Unable to read pixel data from image.');
    }

    final Uint8List pixels = byteData.buffer.asUint8List();
    final List<ui.Color> sampledColors =
        List<ui.Color>.filled(columns * rows, const ui.Color(0x00000000));
    final List<int> alphaMask = List<int>.filled(columns * rows, 0);

    final double sampleStepX = imageWidth / columns;
    final double sampleStepY = imageHeight / rows;

    for (int row = 0; row < rows; row++) {
      final double sampleY = (row + 0.5) * sampleStepY;
      final int pixelY = sampleY.clamp(0, imageHeight - 1).floor();
      for (int col = 0; col < columns; col++) {
        final double sampleX = (col + 0.5) * sampleStepX;
        final int pixelX = sampleX.clamp(0, imageWidth - 1).floor();
        final int index = (pixelY * imageWidth + pixelX) * 4;
        final int alpha = pixels[index + 3];
        final int listIndex = row * columns + col;
        alphaMask[listIndex] = alpha;
        if (alpha > 0) {
          final int red = pixels[index];
          final int green = pixels[index + 1];
          final int blue = pixels[index + 2];
          sampledColors[listIndex] = ui.Color.fromARGB(alpha, red, green, blue);
        } else {
          sampledColors[listIndex] = const ui.Color(0x00000000);
        }
      }
    }

    final Size boardSize = Size(
      _boardDimension(columns, dotSize, spacing),
      _boardDimension(rows, dotSize, spacing),
    );

    return DotMatrixFrameData(
      columns: columns,
      rows: rows,
      dotSize: dotSize,
      spacing: spacing,
      alignment: alignment,
      boardSize: boardSize,
      sampledColors: sampledColors,
      alphaMask: alphaMask,
    );
  }

  int _safeCount(int value) => value.clamp(1, 1 << 14);

  double _boardDimension(int count, double dotSize, double spacing) {
    if (count <= 0) {
      return 0;
    }
    return count * dotSize + (count - 1) * spacing;
  }
}
