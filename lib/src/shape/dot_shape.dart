import 'dart:ui';

/// The geometric strategy used to render each dot cell.
abstract class DotShape {
  const DotShape();

  /// Paints a single dot at [center] using the provided [size] and [paint].
  void paint(Canvas canvas, Offset center, double size, Paint paint);

  /// Optionally pre-build a reusable path for batch painting.
  Path buildPath(Offset center, double size) {
    final path = Path();
    addToPath(path, center, size);
    return path;
  }

  /// Adds the dot geometry to an existing [path].
  void addToPath(Path path, Offset center, double size);
}

class CircleDotShape extends DotShape {
  const CircleDotShape();

  @override
  void paint(Canvas canvas, Offset center, double size, Paint paint) {
    canvas.drawCircle(center, size / 2, paint);
  }

  @override
  void addToPath(Path path, Offset center, double size) {
    path.addOval(Rect.fromCircle(center: center, radius: size / 2));
  }
}

class SquareDotShape extends DotShape {
  const SquareDotShape();

  @override
  void paint(Canvas canvas, Offset center, double size, Paint paint) {
    final half = size / 2;
    canvas.drawRect(
      Rect.fromLTWH(center.dx - half, center.dy - half, size, size),
      paint,
    );
  }

  @override
  void addToPath(Path path, Offset center, double size) {
    final half = size / 2;
    path.addRect(
      Rect.fromLTWH(center.dx - half, center.dy - half, size, size),
    );
  }
}

enum DotShapeType { circle, square }

extension DotShapeTypeMapper on DotShapeType {
  DotShape toShape() {
    switch (this) {
      case DotShapeType.circle:
        return const CircleDotShape();
      case DotShapeType.square:
        return const SquareDotShape();
    }
  }
}
