## 0.1.1

- Fix: Live preview shows immediately on first render with a fallback dot overlay.
- Improve: More reliable capture scheduling and warm-up retries for late-loading images.
- Perf: Default capture pixelRatio to 1.0 and downscale to grid resolution before sampling.
- API: Rename `showDotLayer` to `overlayVisible` (breaking rename).
- Test: Add performance tests for initial render and delayed content.

## 0.1.0

- Initial public release of `dot_matrix_widget`.
- Render any widget into a pixel-perfect dot matrix.
- Supports configurable dot size, spacing, shapes, color strategies, and style presets.
- Includes example app with adjustable controls and demo assets.
- Added capture throttling and background masking optimizations for smoother performance.
