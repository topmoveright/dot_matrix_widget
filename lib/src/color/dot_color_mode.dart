import 'dart:ui';

import '../style/dot_matrix_style.dart';

/// Abstract strategy for computing the color of a dot.
abstract class DotColorStrategy {
  const DotColorStrategy();

  Color transform(
    Color inputColor, {
    required int x,
    required int y,
    required int columns,
    required int rows,
  });
}

class OriginalColorStrategy extends DotColorStrategy {
  const OriginalColorStrategy();

  @override
  Color transform(
    Color inputColor, {
    required int x,
    required int y,
    required int columns,
    required int rows,
  }) =>
      inputColor;
}

class SingleColorStrategy extends DotColorStrategy {
  const SingleColorStrategy(this.color);

  final Color color;

  @override
  Color transform(
    Color inputColor, {
    required int x,
    required int y,
    required int columns,
    required int rows,
  }) {
    return color.withAlpha(inputColor.alpha);
  }
}

class StylePresetStrategy extends DotColorStrategy {
  const StylePresetStrategy(this.preset);

  final DotMatrixStylePreset preset;

  @override
  Color transform(
    Color inputColor, {
    required int x,
    required int y,
    required int columns,
    required int rows,
  }) {
    return preset.transform(
      inputColor,
      x: x,
      y: y,
      columns: columns,
      rows: rows,
    );
  }
}

enum DotColorMode { original, singleColor, preset }

class DotColorStrategyFactory {
  const DotColorStrategyFactory();

  DotColorStrategy create({
    required DotColorMode mode,
    Color? fallbackColor,
    DotMatrixStylePreset? preset,
  }) {
    switch (mode) {
      case DotColorMode.original:
        return const OriginalColorStrategy();
      case DotColorMode.singleColor:
        return SingleColorStrategy(
          fallbackColor ?? const Color(0xFFFFFFFF),
        );
      case DotColorMode.preset:
        final safePreset = preset ?? DotMatrixStylePreset.ledPanel();
        return StylePresetStrategy(safePreset);
    }
  }
}
