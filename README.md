# dot_matrix_widget

<center>
<img src="https://raw.githubusercontent.com/topmoveright/dot_matrix_widget/refs/heads/main/screenshots/screenshot.png" alt="screenshot">
</center>

Render any Flutter widget as a dot-matrix (LED/LCD) display. The package captures its child and redraws it using configurable dot shapes, spacing, and color treatments to produce a retro display effect.



## Features

- Configurable dot size, spacing, and board alignment
- Built-in dot shapes: circle, square, diamond, rounded square (and extendable via `DotShape`)
- Flexible color pipeline: preserve original pixels, use a single color, or choose from preset styles like analog TV, LED panel, and vintage amber
- Adjustable alpha threshold to control lit/unlit dots
- Capture throttling with `captureInterval` for smoother performance on animated content
- Example app with live preview, gallery, and interactive controls

## Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  dot_matrix_widget: ^0.1.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

```dart
import 'package:dot_matrix_widget/dot_matrix_widget.dart';
import 'package:flutter/material.dart';

class DotMatrixPreview extends StatelessWidget {
  const DotMatrixPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return DotMatrixWidget(
      dotSize: 5,
      spacing: 2,
      shape: DotShapeType.circle,
      colorMode: DotColorMode.preset,
      stylePreset: DotMatrixStylePreset.analogTv(),
      captureInterval: const Duration(milliseconds: 50),
      child: Container(
        color: Colors.black,
        alignment: Alignment.center,
        child: const Text(
          'HELLO',
          style: TextStyle(fontSize: 72, color: Colors.cyanAccent),
        ),
      ),
    );
  }
}
```

## API Overview

`DotMatrixWidget` exposes the following configuration points:

- `dotSize` (`double`): Diameter or edge length of each rendered dot.
- `spacing` (`double`): Gap between dots.
- `shape` (`DotShapeType`): Choose the built-in shape, or convert to a custom `DotShape`.
- `colorMode` (`DotColorMode`): Select original pixels, a single color, or a preset style.
- `singleColor` (`Color?`): Color override when using `DotColorMode.singleColor`.
- `stylePreset` (`DotMatrixStylePreset?`): Curated color transforms like `analogTv`, `ledPanel`, or `vintageAmber`.
- `blankColor` (`Color`): Fill color for unlit dots and canvas background.
- `alphaThreshold` (`int`): Minimum alpha (0–255) required for a dot to be lit.
- `pixelRatio` (`double?`): Override device pixel ratio for the capture pass.
- `captureInterval` (`Duration?`): Minimum delay between captures; set to `Duration.zero` to capture every frame.
- `overlayVisible` (`bool`): Toggle between showing the dot overlay or only updating capture data.

## Example App

The `example/` directory includes a fully interactive demo with live preview, gallery, and configuration controls.

```bash
flutter run example
```

## Roadmap

- Additional style presets and glow effects
- Custom shape editor utilities
- Performance profiling on lower-end devices

## Contributing

Contributions are welcome! Please file issues and open pull requests with clear descriptions and test coverage where applicable.

## License

Licensed under the MIT License. See [LICENSE](LICENSE) for full terms.
