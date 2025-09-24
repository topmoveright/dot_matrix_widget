import 'package:dot_matrix_widget/dot_matrix_widget.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const DotMatrixExampleApp());
}

class DotMatrixExampleApp extends StatelessWidget {
  const DotMatrixExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dot Matrix Widget Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(
          primary: Colors.cyanAccent,
          secondary: Color(0xFF8E44FF),
          surface: Color(0xFF0F1218),
          background: Color(0xFF08090D),
        ),
        scaffoldBackgroundColor: const Color(0xFF08090D),
        useMaterial3: true,
      ),
      home: const DotMatrixDemoPage(),
    );
  }
}

class DotMatrixDemoPage extends StatefulWidget {
  const DotMatrixDemoPage({super.key});

  @override
  State<DotMatrixDemoPage> createState() => _DotMatrixDemoPageState();
}

class _DotMatrixDemoPageState extends State<DotMatrixDemoPage> {
  static const Map<String, Color> _singleColorOptions = {
    'Cyan': Color(0xFF4DF3FF),
    'Amber': Color(0xFFFFB84D),
    'Magenta': Color(0xFFE94CFF),
    'Lime': Color(0xFF5CFF6A),
  };

  static final Map<String, DotMatrixStylePreset Function()> _presetFactories = {
    'LED Panel': DotMatrixStylePreset.ledPanel,
    'Analog TV': DotMatrixStylePreset.analogTv,
    'Vintage Amber': DotMatrixStylePreset.vintageAmber,
  };

  DotShapeType _shape = DotShapeType.circle;
  DotColorMode _colorMode = DotColorMode.original;
  double _dotSize = 6;
  double _spacing = 2;
  String _singleColorKey = _singleColorOptions.keys.first;
  String _presetKey = _presetFactories.keys.first;

  Color get _selectedSingleColor => _singleColorOptions[_singleColorKey]!;

  DotMatrixStylePreset? get _selectedPreset {
    final factory = _presetFactories[_presetKey];
    return factory?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dot Matrix Widget Demo'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPreview(context),
              const SizedBox(height: 32),
              _buildControls(context),
              const SizedBox(height: 32),
              _buildGallery(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Live preview',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF121620), Color(0xFF080A0F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(color: Colors.white10, width: 1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: DotMatrixWidget(
                  dotSize: _dotSize,
                  spacing: _spacing,
                  shape: _shape,
                  colorMode: _colorMode,
                  singleColor:
                      _colorMode == DotColorMode.singleColor ? _selectedSingleColor : null,
                  stylePreset:
                      _colorMode == DotColorMode.preset ? _selectedPreset : null,
                  blankColor: const Color(0xFF050608),
                  child: _buildPreviewChild(context),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewChild(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0D2847), Color(0xFF09111C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'DOT MATRIX',
              style: textTheme.displaySmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 8,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Bring retro vibes to any widget. Experiment with LED shapes, colors, and classic display styles.',
              style: textTheme.bodyLarge?.copyWith(color: Colors.white70, height: 1.4),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: const [
                _DemoTag(label: 'Analog TV'),
                _DemoTag(label: 'LED Panel'),
                _DemoTag(label: 'Vintage Amber'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.titleMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Controls', style: labelStyle),
        const SizedBox(height: 12),
        _ControlSection(
          children: [
            _buildDropdown<DotShapeType>(
              label: 'Dot shape',
              value: _shape,
              items: DotShapeType.values
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(type.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _shape = value);
                }
              },
            ),
            _buildDropdown<DotColorMode>(
              label: 'Color mode',
              value: _colorMode,
              items: DotColorMode.values
                  .map(
                    (mode) => DropdownMenuItem(
                      value: mode,
                      child: Text(mode.name.toUpperCase()),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _colorMode = value);
                }
              },
            ),
            if (_colorMode == DotColorMode.singleColor)
              _buildDropdown<String>(
                label: 'Single color',
                value: _singleColorKey,
                items: _singleColorOptions.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.key,
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: entry.value,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                            Text(entry.key),
                          ],
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _singleColorKey = value);
                  }
                },
              ),
            if (_colorMode == DotColorMode.preset)
              _buildDropdown<String>(
                label: 'Preset style',
                value: _presetKey,
                items: _presetFactories.keys
                    .map(
                      (key) => DropdownMenuItem(
                        value: key,
                        child: Text(key),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _presetKey = value);
                  }
                },
              ),
          ],
        ),
        const SizedBox(height: 20),
        _ControlSection(
          children: [
            _buildSlider(
              context: context,
              label: 'Dot size',
              value: _dotSize,
              min: 2,
              max: 16,
              onChanged: (value) => setState(() => _dotSize = value),
            ),
            _buildSlider(
              context: context,
              label: 'Spacing',
              value: _spacing,
              min: 0,
              max: 6,
              onChanged: (value) => setState(() => _spacing = value),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGallery(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.titleMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gallery', style: labelStyle),
        const SizedBox(height: 12),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            _buildGalleryCard(
              context,
              title: 'Flutter Logo',
              child: const Center(child: FlutterLogo(size: 96)),
            ),
            _buildGalleryCard(
              context,
              title: 'Music',
              child: const Center(
                child: Text(
                  '🎶',
                  style: TextStyle(fontSize: 80),
                ),
              ),
            ),
            _buildGalleryCard(
              context,
              title: 'Space Capsule',
              child: Center(
                child: Icon(
                  Icons.rocket_launch_rounded,
                  size: 72,
                  color: Colors.white,
                ),
              ),
            ),
            _buildGalleryCard(
              context,
              title: 'Typography',
              child: Center(
                child: Text(
                  'HELLO',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6,
                      ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGalleryCard(BuildContext context,
      {required String title, required Widget child}) {
    return SizedBox(
      width: 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0C10),
                  border: Border.all(color: Colors.white12, width: 1),
                ),
                child: DotMatrixWidget(
                  dotSize: _dotSize,
                  spacing: _spacing,
                  shape: _shape,
                  colorMode: _colorMode,
                  singleColor:
                      _colorMode == DotColorMode.singleColor ? _selectedSingleColor : null,
                  stylePreset:
                      _colorMode == DotColorMode.preset ? _selectedPreset : null,
                  blankColor: const Color(0xFF050608),
                  child: Container(color: Colors.black, child: child),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: const Color(0xFF12151C),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: DropdownButton<T>(
                value: value,
                isExpanded: true,
                underline: const SizedBox.shrink(),
                dropdownColor: const Color(0xFF12151C),
                borderRadius: BorderRadius.circular(12),
                items: items,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider({
    required BuildContext context,
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            Text(value.toStringAsFixed(1),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _DemoTag extends StatelessWidget {
  const _DemoTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white12),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.white),
      ),
    );
  }
}

class _ControlSection extends StatelessWidget {
  const _ControlSection({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10131B),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white10),
      ),
      child: Wrap(
        spacing: 20,
        runSpacing: 20,
        children: children,
      ),
    );
  }
}
