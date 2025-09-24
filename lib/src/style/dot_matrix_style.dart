import 'dart:math' as math;
import 'dart:ui';

/// A reusable preset that can transform sampled colors to emulate classic displays.
class DotMatrixStylePreset {
  const DotMatrixStylePreset._({
    required this.name,
    required this.transformer,
  });

  final String name;
  final Color Function(
    Color input, {
    required int x,
    required int y,
    required int columns,
    required int rows,
  }) transformer;

  Color transform(
    Color input, {
    required int x,
    required int y,
    required int columns,
    required int rows,
  }) {
    return transformer(
      input,
      x: x,
      y: y,
      columns: columns,
      rows: rows,
    );
  }

  /// Simulates an analog TV look using desaturation and scanlines.
  factory DotMatrixStylePreset.analogTv() {
    return DotMatrixStylePreset._(
      name: 'AnalogTV',
      transformer: (
        Color input, {
        required int x,
        required int y,
        required int columns,
        required int rows,
      }) {
        final double luma = 0.299 * input.r + 0.587 * input.g + 0.114 * input.b;
        final double base = (luma * 255.0).clamp(0.0, 255.0);
        final bool scanLine = y.isOdd;
        final double scanFactor = scanLine ? 0.7 : 1.0;
        final double noise = 0.04 * math.sin((x + y) * 0.5);
        final double value =
            (base * scanFactor * (1 - noise)).clamp(0.0, 255.0);
        final int alpha = (input.a * 255.0).round().clamp(0, 255);
        final int red = (value * 0.6).round().clamp(0, 255);
        final int green = (value * 0.75).round().clamp(0, 255);
        final int blue = (value * 0.65).round().clamp(0, 255);
        return Color.fromARGB(
          alpha,
          red,
          green,
          blue,
        );
      },
    );
  }

  /// Simulates a vibrant LED panel with high saturation and glow.
  factory DotMatrixStylePreset.ledPanel() {
    return DotMatrixStylePreset._(
      name: 'LedPanel',
      transformer: (
        Color input, {
        required int x,
        required int y,
        required int columns,
        required int rows,
      }) {
        final double factor = 1.3;
        int enhance(double normalized) {
          final double boosted = math.pow(normalized, 0.8).toDouble() * factor;
          return (boosted.clamp(0.0, 1.0) * 255).round();
        }

        final double glowPhase =
            math.sin((x / columns) * math.pi) * math.sin((y / rows) * math.pi);
        final int glow = (30 * glowPhase.abs()).round();
        final int alpha = (input.a * 255.0).round().clamp(0, 255);
        return Color.fromARGB(
          alpha,
          (enhance(input.r) + glow).clamp(0, 255),
          (enhance(input.g) + glow).clamp(0, 255),
          (enhance(input.b) + glow).clamp(0, 255),
        );
      },
    );
  }

  /// Emulates vintage amber monochrome displays.
  factory DotMatrixStylePreset.vintageAmber() {
    return DotMatrixStylePreset._(
      name: 'VintageAmber',
      transformer: (
        Color input, {
        required int x,
        required int y,
        required int columns,
        required int rows,
      }) {
        final double luma =
            0.2126 * input.r + 0.7152 * input.g + 0.0722 * input.b;
        final double base = (luma * 255.0).clamp(0.0, 255.0);
        final double flicker = 0.05 * math.sin((x + y) * 0.8);
        final double brightness = ((base / 255.0) + flicker).clamp(0.1, 1.0);
        final int alpha = (input.a * 255.0).round().clamp(0, 255);
        final int value = (brightness * 255).round().clamp(0, 255);
        return Color.fromARGB(
          alpha,
          value,
          (value * 0.7).round().clamp(0, 255),
          (value * 0.2).round().clamp(0, 255),
        );
      },
    );
  }

  @override
  String toString() => 'DotMatrixStylePreset(name: $name)';
}
