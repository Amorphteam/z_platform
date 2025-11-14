import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:cupertino_native/cupertino_native.dart';

import '../../../model/style_model.dart';
import '../cubit/epub_viewer_cubit.dart';

class StyleSheet extends StatefulWidget {

  const StyleSheet({
    super.key,
    required this.epubViewerCubit,
    required this.fontSize,
    required this.fontFamily,
    required this.lineSpace,
    this.backgroundColor,
    this.useUniformTextColor,
    this.uniformTextColor,
    this.hideArabicDiacritics,
  });
  final EpubViewerCubit epubViewerCubit;
  final FontSizeCustom fontSize;
  final FontFamily fontFamily;
  final LineHeightCustom lineSpace;
  final Color? backgroundColor;
  final bool? useUniformTextColor;
  final Color? uniformTextColor;
  final bool? hideArabicDiacritics;

  @override
  State<StyleSheet> createState() => _StyleSheetState();
}

class _StyleSheetState extends State<StyleSheet> {
  late int _selectedChipIndex;
  late FontSizeCustom fontSizeCustom;
  late FontFamily fontFamily;
  late LineHeightCustom lineSpace;
  late double _fontSizeSliderValue;
  late double _lineHeightSliderValue;
  bool _isFontSizeSliderChange = false;
  bool _isLineHeightSliderChange = false;
  late Color _backgroundColor;
  late bool _useUniformTextColor;
  late Color _uniformTextColor;
  late bool _hideArabicDiacritics;
  static const List<Color> _backgroundOptions = [
    Color(0xFFFFFFFF),
    Color(0xFFFDF0D5),
    Color(0xFFF4F6F8),
    Color(0xFFE6F4EA),
    Color(0xFF1B1B1B),
  ];
  static const List<Color> _textColorOptions = [
    Color(0xFF111111),
    Color(0xFF00695C),
    Color(0xFF6A1B9A),
    Color(0xFF5D4037),
    Color(0xFFFFFFFF),
  ];

  @override
  void initState() {
    super.initState();
    fontSizeCustom = widget.fontSize;
    fontFamily = widget.fontFamily;
    lineSpace = widget.lineSpace;
    _fontSizeSliderValue = fontSizeToSliderValue(widget.fontSize);
    _lineHeightSliderValue = lineSpaceToSliderValue(widget.lineSpace);
    _selectedChipIndex = FontFamily.values.indexOf(widget.fontFamily);
    _backgroundColor =
        widget.backgroundColor ?? widget.epubViewerCubit.cachedBackgroundColor;
    _useUniformTextColor =
        widget.useUniformTextColor ?? widget.epubViewerCubit.useUniformTextColor;
    _uniformTextColor = widget.uniformTextColor ??
        widget.epubViewerCubit.cachedUniformTextColor;
    _hideArabicDiacritics =
        widget.hideArabicDiacritics ?? widget.epubViewerCubit.hideArabicDiacritics;
  }

  void _handleChipSelection(int index) {
    setState(() {
      _selectedChipIndex = index;
    });
    fontFamily = FontFamily.values[index];
    widget.epubViewerCubit.changeStyle(
      fontSize: fontSizeCustom,
      lineSpace: lineSpace,
      fontFamily: fontFamily,
    );
  }

  double fontSizeToSliderValue(FontSizeCustom fontSize) {
    // Assuming FontSizeCustom enum values are ordered from smallest to largest
    return fontSize.index / (FontSizeCustom.values.length - 1);
  }

  double lineSpaceToSliderValue(LineHeightCustom lineSpace) {
    // Assuming LineHeightCustom enum values are ordered from smallest to largest
    return lineSpace.index / (LineHeightCustom.values.length - 1);
  }

  void _handleFontSizeSliderChange(double newValue) {
    setState(() {
      _fontSizeSliderValue = newValue;
    });
    _isFontSizeSliderChange = true;
    
    fontSizeCustom = FontSizeCustom.values[(newValue * (FontSizeCustom.values.length - 1)).round()];
    widget.epubViewerCubit.changeStyle(
      fontSize: fontSizeCustom,
      lineSpace: lineSpace,
      fontFamily: fontFamily,
    );
  }

  void _handleFontSizeSliderChangeEnd(double newValue) {
    _isFontSizeSliderChange = false;
  }

  void _handleLineHeightSliderChange(double newValue) {
    setState(() {
      _lineHeightSliderValue = newValue;
    });
    _isLineHeightSliderChange = true;
    
    lineSpace = LineHeightCustom.values[(newValue * (LineHeightCustom.values.length - 1)).round()];
    widget.epubViewerCubit.changeStyle(
      fontSize: fontSizeCustom,
      lineSpace: lineSpace,
      fontFamily: fontFamily,
    );
  }

  void _handleLineHeightSliderChangeEnd(double newValue) {
    _isLineHeightSliderChange = false;
  }

  void _updateBackgroundColor(Color color) {
    setState(() {
      _backgroundColor = color;
    });
    widget.epubViewerCubit.changeStyle(backgroundColor: color);
  }

  void _updateUniformTextColor(Color color) {
    setState(() {
      _uniformTextColor = color;
    });
    widget.epubViewerCubit.changeStyle(uniformTextColor: color);
  }


  @override
  Widget build(BuildContext context) => Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // SizedBox(height: 16),
            // Text(
            //   'Text setting wizard',
            //   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            // ),
            // SizedBox(height: 26),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Column(
            //       children: [
            //         IconButton(
            //           icon: Icon(Icons.contrast),
            //           onPressed: () {
            //
            //           },
            //         ),
            //         const Text(
            //           'High Contrast',
            //           style: TextStyle(fontSize: 10),
            //         ),
            //       ],
            //     ),
            //     Column(
            //       children: [
            //         IconButton(
            //           icon: Icon(Icons.dark_mode),
            //           onPressed: () {
            //
            //           },
            //         ),
            //         Text(
            //           'Dark Mode',
            //           style: TextStyle(fontSize: 10),
            //         ),
            //       ],
            //     ),
            //     Column(
            //       children: [
            //         IconButton(
            //           icon: Icon(Icons.zoom_out_map),
            //           onPressed: () {
            //             _handleFontSizeSliderChange(0.8);
            //             _handleLineHeightSliderChange(0.8);
            //           },
            //         ),
            //         Text(
            //           'More readability',
            //           style: TextStyle(fontSize: 10),
            //         ),
            //       ],
            //     ),
            //     Column(
            //       children: [
            //         IconButton(
            //           icon: Icon(Icons.article),
            //           onPressed: () {
            //           },
            //         ),
            //         Text(
            //           'High Contrast',
            //           style: TextStyle(fontSize: 10),
            //         ),
            //       ],
            //     ),
            //   ],
            // ),
            // SizedBox(height: 18,),
            // Divider(), // Add a divider here

            const SizedBox(height: 18,),
             Padding(padding: const EdgeInsets.only(right: 26, left: 26),
            child: Text('إعدادات النص', style: Theme.of(context).textTheme.titleMedium),
            ),
             const SizedBox(height: 18), // Add spacing before the Chip widgets

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     InputChip(
            //       label: Text('خط ١'),
            //       selected: _selectedChipIndex == 0,
            //       onSelected: (isSelected) {
            //         _handleChipSelection(isSelected ? 0 : -1);
            //       },
            //     ),
            //     InputChip(
            //       label: Text('خط ٢'),
            //       selected: _selectedChipIndex == 1,
            //       onSelected: (isSelected) {
            //         _handleChipSelection(isSelected ? 1 : -1);
            //       },
            //     ),
            //     InputChip(
            //       label: Text('خط ٣'),
            //       selected: _selectedChipIndex == 2,
            //       onSelected: (isSelected) {
            //         _handleChipSelection(isSelected ? 2 : -1);
            //       },
            //     ),
            //     InputChip(
            //       label: Text('خط ٤'),
            //       selected: _selectedChipIndex == 3,
            //       onSelected: (isSelected) {
            //         _handleChipSelection(isSelected ? 3 : -1);
            //       },
            //     ),
            //     InputChip(
            //       label: Text('خط ٥'),
            //       selected: _selectedChipIndex == 4,
            //       onSelected: (isSelected) {
            //         _handleChipSelection(isSelected ? 4 : -1);
            //       },
            //     ),
            //   ],
            // ),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: defaultTargetPlatform == TargetPlatform.iOS
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Transform.flip(
                            flipX: true,
                            child: CNSlider(
                              value: _fontSizeSliderValue,
                              min: 0.0,
                              max: 1.0,
                              onChanged: (newValue) {
                                _handleFontSizeSliderChange(newValue);
                                Future.delayed(Duration.zero, () {
                                  if (mounted) {
                                    _handleFontSizeSliderChangeEnd(newValue);
                                  }
                                });
                              },
                            ),
                          ),
                        )
                      : Slider(
                          divisions: FontSizeCustom.values.length - 1,
                          value: _fontSizeSliderValue,
                          onChanged: (newValue) {
                            _handleFontSizeSliderChange(newValue);
                          },
                          onChangeEnd: (newValue) {
                            _handleFontSizeSliderChangeEnd(newValue);
                          },
                        ),
                ),
                const Icon(Icons.text_increase),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: defaultTargetPlatform == TargetPlatform.iOS
                      ? Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Transform.flip(
                            flipX: true,
                            child: CNSlider(
                              value: _lineHeightSliderValue,
                              min: 0.0,
                              max: 1.0,
                              onChanged: (newValue) {
                                _handleLineHeightSliderChange(newValue);
                                Future.delayed(Duration.zero, () {
                                  if (mounted) {
                                    _handleLineHeightSliderChangeEnd(newValue);
                                  }
                                });
                              },
                            ),
                          ),
                        )
                      : Slider(
                          divisions: LineHeightCustom.values.length - 1,
                          value: _lineHeightSliderValue,
                          onChanged: (newValue) {
                            _handleLineHeightSliderChange(newValue);
                          },
                          onChangeEnd: (newValue) {
                            _handleLineHeightSliderChangeEnd(newValue);
                          },
                        ),
                ),
                const Icon(Icons.format_line_spacing),
              ],
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 26),
              child: Text(
                'لون الخلفية',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _backgroundOptions.map((color) {
                final isSelected = color.value == _backgroundColor.value;
                return _ColorSwatch(
                  color: color,
                  isSelected: isSelected,
                  onTap: () => _updateBackgroundColor(color),
                  showBorder: color.value == const Color(0xFFFFFFFF).value,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('استخدام لون موحّد للنص'),
              value: _useUniformTextColor,
              onChanged: (value) {
                setState(() {
                  _useUniformTextColor = value;
                });
                widget.epubViewerCubit
                    .changeStyle(useUniformTextColor: value);
              },
            ),
            SwitchListTile(
              title: const Text('إخفاء التشكيل (الحركات)'),
              value: _hideArabicDiacritics,
              onChanged: (value) {
                setState(() {
                  _hideArabicDiacritics = value;
                });
                widget.epubViewerCubit
                    .changeStyle(hideArabicDiacritics: value);
              },
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: _useUniformTextColor
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26),
                          child: Text(
                            'اختر لون النص',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: _textColorOptions.map((color) {
                            final isSelected =
                                color.value == _uniformTextColor.value;
                            return _ColorSwatch(
                              color: color,
                              isSelected: isSelected,
                              onTap: () => _updateUniformTextColor(color),
                              showBorder: color.value == const Color(0xFFFFFFFF).value,
                            );
                          }).toList(),
                        ),
                      ],
                    )
                  : const SizedBox.shrink(),
            ),
            // IconButton(
            //   icon: Icon(Icons.color_lens),
            //   onPressed: _showColorPicker,
            // ),
          ],
        ),


      ),
    );
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
    this.showBorder = false,
  });

  final Color color;
  final bool isSelected;
  final bool showBorder;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : (showBorder ? Colors.black26 : Colors.transparent),
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}
