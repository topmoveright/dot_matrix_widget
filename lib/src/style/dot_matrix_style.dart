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
        final double luma = 0.299 * input.red + 0.587 * input.green + 0.114 * input.blue;
        final int base = luma.round().clamp(0, 255).toInt();
        final bool scanLine = y.isOdd;
        final double scanFactor = scanLine ? 0.7 : 1.0;
        final double noise = 0.04 * math.sin((x + y) * 0.5);
        final double value = (base * scanFactor * (1 - noise)).clamp(0, 255);
        final int tinted = value.round();
        return Color.fromARGB(
          input.alpha,
          (tinted * 0.6).round(),
          (tinted * 0.75).round(),
          (tinted * 0.65).round(),
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
        int enhance(int channel) {
          final double normalized = channel / 255.0;
          final double boosted = math.pow(normalized, 0.8) * factor;
          return (boosted.clamp(0.0, 1.0) * 255).round();
        }

        final double glowPhase = math.sin((x / columns) * math.pi) * math.sin((y / rows) * math.pi);
        final int glow = (30 * glowPhase.abs()).round();
        return Color.fromARGB(
          input.alpha,
          (enhance(input.red) + glow).clamp(0, 255),
          (enhance(input.green) + glow).clamp(0, 255),
          (enhance(input.blue) + glow).clamp(0, 255),
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
        final double luma = 0.2126 * input.red + 0.7152 * input.green + 0.0722 * input.blue;
        final int base = luma.round().clamp(0, 255).toInt();
        final double flicker = 0.05 * math.sin((x + y) * 0.8);
        final double brightness = (base / 255.0 + flicker).clamp(0.1, 1.0);
        final int value = (brightness * 255).round();
        return Color.fromARGB(
          input.alpha,
          (value * 1.0).clamp(0, 255).round(),
          (value * 0.7).clamp(0, 255).round(),
          (value * 0.2).clamp(0, 255).round(),
        );
      },
    );
  }

  @override
  String toString() => 'DotMatrixStylePreset(name: $name)';
}
