import 'package:flutter/material.dart';
import 'package:dynamic_color/dynamic_color.dart';

class ColorPaletteScreen extends StatelessWidget {
  const ColorPaletteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final colorScheme = isDark ? darkDynamic : lightDynamic;
        
        if (colorScheme == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Color Palette')),
            body: const Center(
              child: Text('No dynamic colors available'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Dynamic Color Palette'),
            backgroundColor: colorScheme.surface,
            foregroundColor: colorScheme.onSurface,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildColorSection(
                  'Primary Colors',
                  [
                    _ColorItem('Primary', colorScheme.primary, colorScheme.onPrimary),
                    _ColorItem('Primary Container', colorScheme.primaryContainer, colorScheme.onPrimaryContainer),
                  ],
                ),
                const SizedBox(height: 24),
                _buildColorSection(
                  'Secondary Colors',
                  [
                    _ColorItem('Secondary', colorScheme.secondary, colorScheme.onSecondary),
                    _ColorItem('Secondary Container', colorScheme.secondaryContainer, colorScheme.onSecondaryContainer),
                  ],
                ),
                const SizedBox(height: 24),
                _buildColorSection(
                  'Tertiary Colors',
                  [
                    _ColorItem('Tertiary', colorScheme.tertiary, colorScheme.onTertiary),
                    _ColorItem('Tertiary Container', colorScheme.tertiaryContainer, colorScheme.onTertiaryContainer),
                  ],
                ),
                const SizedBox(height: 24),
                _buildColorSection(
                  'Surface Colors',
                  [
                    _ColorItem('Surface', colorScheme.surface, colorScheme.onSurface),
                    _ColorItem('Surface Variant', colorScheme.surfaceVariant, colorScheme.onSurfaceVariant),
                    _ColorItem('Surface Tint', colorScheme.surfaceTint, colorScheme.onSurface),
                  ],
                ),
                const SizedBox(height: 24),
                _buildColorSection(
                  'Error Colors',
                  [
                    _ColorItem('Error', colorScheme.error, colorScheme.onError),
                    _ColorItem('Error Container', colorScheme.errorContainer, colorScheme.onErrorContainer),
                  ],
                ),
                const SizedBox(height: 24),
                _buildColorSection(
                  'Outline Colors',
                  [
                    _ColorItem('Outline', colorScheme.outline, colorScheme.surface),
                    _ColorItem('Outline Variant', colorScheme.outlineVariant, colorScheme.surface),
                  ],
                ),
                const SizedBox(height: 24),
                _buildColorSection(
                  'Utility Colors',
                  [
                    _ColorItem('Shadow', colorScheme.shadow, colorScheme.onSurface),
                    _ColorItem('Scrim', colorScheme.scrim, colorScheme.onSurface),
                    _ColorItem('Inverse Surface', colorScheme.inverseSurface, colorScheme.onInverseSurface),
                    _ColorItem('Inverse Primary', colorScheme.inversePrimary, colorScheme.surface),
                  ],
                ),
                const SizedBox(height: 24),
                _buildOpacityExamples(colorScheme),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorSection(String title, List<_ColorItem> colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...colors.map((color) => _buildColorCard(color)),
      ],
    );
  }

  Widget _buildColorCard(_ColorItem colorItem) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: colorItem.color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Text(
                colorItem.color.value.toRadixString(16).toUpperCase().substring(2),
                style: TextStyle(
                  color: colorItem.textColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  colorItem.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Color(0x${colorItem.color.value.toRadixString(16).toUpperCase().substring(2)})',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOpacityExamples(ColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Opacity Examples',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Primary with different opacity levels:',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildOpacityCard('5%', colorScheme.primary.withOpacity(0.05)),
            const SizedBox(width: 8),
            _buildOpacityCard('10%', colorScheme.primary.withOpacity(0.1)),
            const SizedBox(width: 8),
            _buildOpacityCard('20%', colorScheme.primary.withOpacity(0.2)),
            const SizedBox(width: 8),
            _buildOpacityCard('50%', colorScheme.primary.withOpacity(0.5)),
          ],
        ),
      ],
    );
  }

  Widget _buildOpacityCard(String label, Color color) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}

class _ColorItem {
  final String name;
  final Color color;
  final Color textColor;

  _ColorItem(this.name, this.color, this.textColor);
}
