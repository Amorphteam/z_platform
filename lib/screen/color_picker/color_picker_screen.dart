import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../util/color_helper.dart';
import '../../widget/theme_mode_toggle.dart';


class ColorPickerScreen extends StatefulWidget {
  const ColorPickerScreen({super.key});

  // Helper function to get platform-specific dynamic color description
  static String getDynamicColorDescription() {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return "ألوان النظام الافتراضية";
    } else {
      return "ألوان من النظام (Android)";
    }
  }

  @override
  State<ColorPickerScreen> createState() => _ColorPickerScreenState();
}

class _ColorPickerScreenState extends State<ColorPickerScreen> {
  Color _selectedColor = Colors.blue;

  // Predefined color palettes
  final List<Color> _predefinedColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
    Colors.amber,
    Colors.deepOrange,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.deepPurple,
    Colors.brown,
    Colors.grey,
  ];

  @override
  Widget build(BuildContext context) {
    final colorHelper = Provider.of<ColorHelper>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
     return Scaffold(
       appBar: AppBar(
         title: const Text('اختيار الألوان'),
         actions: [
           IconButton(
             icon: const Icon(Icons.refresh),
             onPressed: () {
               colorHelper.resetToDefaults();
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text('تم إعادة تعيين الألوان')),
               );
             },
           ),
         ],
       ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Theme Mode Toggle
              const ThemeModeToggle(),

              const SizedBox(height: 24),

               // Color Mode Selection
               Card(

                 child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نوع الألوان',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      Column(
                        children: [
                          Container(
                            height: 80,
                            child: RadioListTile<ColorMode>(
                              title: const Text('ألوان المطور'),
                              subtitle: const Text('الألوان الافتراضية'),
                              value: ColorMode.owner,
                              groupValue: colorHelper.colorMode,
                              onChanged: (value) {
                                if (value != null) {
                                  colorHelper.setColorMode(value);
                                }
                              },
                            ),
                          ),
                          Container(
                            height: 80,
                            child: RadioListTile<ColorMode>(
                              title: const Text('ديناميكي'),
                              subtitle: Text(ColorPickerScreen.getDynamicColorDescription()),
                              value: ColorMode.dynamic,
                              groupValue: colorHelper.colorMode,
                              onChanged: (value) {
                                if (value != null) {
                                  colorHelper.setColorMode(value);
                                }
                              },
                            ),
                          ),
                          Container(
                            height: 80,
                            child: RadioListTile<ColorMode>(
                              title: const Text('مخصص'),
                              subtitle: const Text('اختر ألوانك الخاصة'),
                              value: ColorMode.custom,
                              groupValue: colorHelper.colorMode,
                              onChanged: (value) {
                                if (value != null) {
                                  colorHelper.setColorMode(value);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

               // Owner Colors Preview Section
               if (colorHelper.colorMode == ColorMode.owner) ...[
                 Card(
                   color: Theme.of(context).colorScheme.surface,
                   elevation: 0,
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ألوان المطور',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'هذه هي الألوان الافتراضية للتطبيق. يمكنك تغييرها من خلال إعدادات المطور.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        _buildOwnerColorPreview(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

               // Custom Color Section
               if (colorHelper.colorMode == ColorMode.custom) ...[
                 Card(
                   child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اختيار اللون الأساسي',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),

                        // Color Picker
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: _selectedColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Center(
                            child: Text(
                              'اللون المحدد',
                              style: TextStyle(
                                color: _getContrastColor(_selectedColor),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Predefined Colors Grid
                        Text(
                          'ألوان جاهزة',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 8,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: _predefinedColors.length,
                          itemBuilder: (context, index) {
                            final color = _predefinedColors[index];
                            final isSelected = color == _selectedColor;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColor = color;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: isSelected ? Colors.white : Colors.grey,
                                    width: isSelected ? 3 : 1,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 16,
                                      )
                                    : null,
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Apply Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              _applyCustomColor(colorHelper);
                            },
                            child: const Text('تطبيق اللون'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                 // Preview Section
                 Card(
                   color: Theme.of(context).colorScheme.surface,
                   elevation: 0,
                   shape: RoundedRectangleBorder(
                     borderRadius: BorderRadius.circular(12),
                   ),
                   child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'معاينة الألوان',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        _buildColorPreview(colorHelper),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
           );
  }

  Widget _buildColorPreview(ColorHelper colorHelper) {
    final lightScheme = colorHelper.generateSchemeFromColor(_selectedColor, false);
    final darkScheme = colorHelper.generateSchemeFromColor(_selectedColor, true);
    
    return Column(
      children: [
        // Light Theme Preview
        Text(
          'الوضع الفاتح',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildColorRow('أساسي', lightScheme.primary, lightScheme.onPrimary),
        const SizedBox(height: 4),
        _buildColorRow('ثانوي', lightScheme.secondary, lightScheme.onSecondary),
        const SizedBox(height: 4),
        _buildColorRow('سطح', lightScheme.surface, lightScheme.onSurface),
        const SizedBox(height: 4),
        _buildColorRow('خطأ', lightScheme.error, lightScheme.onError),
        
        const SizedBox(height: 16),
        
        // Dark Theme Preview
        Text(
          'الوضع الداكن',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildColorRow('أساسي', darkScheme.primary, darkScheme.onPrimary),
        const SizedBox(height: 4),
        _buildColorRow('ثانوي', darkScheme.secondary, darkScheme.onSecondary),
        const SizedBox(height: 4),
        _buildColorRow('سطح', darkScheme.surface, darkScheme.onSurface),
        const SizedBox(height: 4),
        _buildColorRow('خطأ', darkScheme.error, darkScheme.onError),
      ],
    );
  }

  Widget _buildOwnerColorPreview() {
    final colorHelper = Provider.of<ColorHelper>(context, listen: false);
    
    // Get owner colors
    final lightScheme = colorHelper.getColorScheme(
      isDark: false,
      dynamicLight: null,
      dynamicDark: null,
    );
    
    final darkScheme = colorHelper.getColorScheme(
      isDark: true,
      dynamicLight: null,
      dynamicDark: null,
    );
    
    if (lightScheme == null || darkScheme == null) return const SizedBox();
    
    return Column(
      children: [
        // Light Theme Preview
        Text(
          'الوضع الفاتح',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildColorRow('أساسي', lightScheme.primary, lightScheme.onPrimary),
        const SizedBox(height: 4),
        _buildColorRow('ثانوي', lightScheme.secondary, lightScheme.onSecondary),
        const SizedBox(height: 4),
        _buildColorRow('سطح', lightScheme.surface, lightScheme.onSurface),
        const SizedBox(height: 4),
        _buildColorRow('خطأ', lightScheme.error, lightScheme.onError),
        
        const SizedBox(height: 16),
        
        // Dark Theme Preview
        Text(
          'الوضع الداكن',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildColorRow('أساسي', darkScheme.primary, darkScheme.onPrimary),
        const SizedBox(height: 4),
        _buildColorRow('ثانوي', darkScheme.secondary, darkScheme.onSecondary),
        const SizedBox(height: 4),
        _buildColorRow('سطح', darkScheme.surface, darkScheme.onSurface),
        const SizedBox(height: 4),
        _buildColorRow('خطأ', darkScheme.error, darkScheme.onError),
      ],
    );
  }

  Widget _buildColorRow(String label, Color color, Color textColor) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label),
        ),
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Center(
              child: Text(
                '#${color.value.toRadixString(16).substring(2).toUpperCase()}',
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Color _getContrastColor(Color color) {
    // Calculate luminance to determine if we should use white or black text
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  void _applyCustomColor(ColorHelper colorHelper) {
    final lightScheme = colorHelper.generateSchemeFromColor(_selectedColor, false);
    final darkScheme = colorHelper.generateSchemeFromColor(_selectedColor, true);
    
    colorHelper.setCustomLightScheme(lightScheme);
    colorHelper.setCustomDarkScheme(darkScheme);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تطبيق الألوان المخصصة')),
    );
  }
}
