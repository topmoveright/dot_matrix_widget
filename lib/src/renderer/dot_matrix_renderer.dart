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
    int? presetColumns,
    int? presetRows,
  }) async {
    assert(dotSize > 0, 'dotSize must be positive');
    final int imageWidth = image.width;
    final int imageHeight = image.height;

    final double cellSize = dotSize + spacing;
    final int columns = _safeCount(
      (presetColumns ?? ((imageWidth + spacing) / cellSize).floor()),
    );
    final int rows = _safeCount(
      (presetRows ?? ((imageHeight + spacing) / cellSize).floor()),
    );

    // Downscale the captured image to grid resolution to reduce the amount
    // of data processed during sampling.
    final ui.Image scaled = await _resizeTo(image, columns, rows);
    final ByteData? byteData =
        await scaled.toByteData(format: ui.ImageByteFormat.rawRgba);
    if (byteData == null) {
      scaled.dispose();
      throw StateError('Unable to read pixel data from image.');
    }

    final Uint8List pixels = byteData.buffer.asUint8List();
    final List<ui.Color> sampledColors =
        List<ui.Color>.filled(columns * rows, const ui.Color(0x00000000));
    final List<int> alphaMask = List<int>.filled(columns * rows, 0);

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < columns; col++) {
        final int index = (row * columns + col) * 4;
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
    // Safe to dispose the scaled image after reading pixels.
    scaled.dispose();

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

  Future<ui.Image> _resizeTo(ui.Image source, int width, int height) async {
    if (source.width == width && source.height == height) {
      return source;
    }
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    final ui.Rect src = ui.Rect.fromLTWH(
        0, 0, source.width.toDouble(), source.height.toDouble());
    final ui.Rect dst =
        ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble());
    final ui.Paint paint = ui.Paint()..filterQuality = ui.FilterQuality.low;
    canvas.drawImageRect(source, src, dst, paint);
    final ui.Image img = await recorder.endRecording().toImage(width, height);
    return img;
  }
}
