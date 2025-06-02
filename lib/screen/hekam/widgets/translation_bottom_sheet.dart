import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zahra/model/hekam.dart';
import 'package:zahra/util/style_helper.dart';

import '../../../model/style_model.dart';

class TranslationBottomSheet extends StatefulWidget {
  final Hekam hekam;

  const TranslationBottomSheet({
    super.key,
    required this.hekam,
  });

  @override
  State<TranslationBottomSheet> createState() => _TranslationBottomSheetState();
}

class _TranslationBottomSheetState extends State<TranslationBottomSheet> {
  String selectedTranslation = 'الكل';
  double _rejalFontSize = 18.0;
  static const double _minFontSize = 14.0;
  static const double _maxFontSize = 24.0;
  static const double _fontSizeStep = 2.0;
  static const String _rejalFontSizeKey = 'rejal_font_size';

  @override
  void initState() {
    super.initState();
    _loadRejalFontSize();
  }

  Future<void> _loadRejalFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rejalFontSize = prefs.getDouble(_rejalFontSizeKey) ?? 18.0;
    });
  }

  Future<void> _saveRejalFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_rejalFontSizeKey, fontSize);
  }

  List<String> get availableTranslations {
    final translations = <String>['الكل'];
    if (widget.hekam.english1 != null) translations.add('English');
    if (widget.hekam.farsi1 != null) translations.add('فارسي ـ جعفري');
    if (widget.hekam.farsi2 != null) translations.add('فارسي ـ انصاريان');
    if (widget.hekam.farsi3 != null) translations.add('فارسي ـ فيض الإسلام');
    if (widget.hekam.farsi4 != null) translations.add('فارسي ـ شهيدي');
    return translations;
  }

  bool shouldShowTranslation(String title) {
    if (selectedTranslation == 'الكل') return true;
    return title == selectedTranslation;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.5,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.text_decrease),
                              onPressed: () {
                                setState(() {
                                  if (_rejalFontSize > _minFontSize) {
                                    _rejalFontSize -= _fontSizeStep;
                                    _saveRejalFontSize(_rejalFontSize);
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.text_increase),
                              onPressed: () {
                                setState(() {
                                  if (_rejalFontSize < _maxFontSize) {
                                    _rejalFontSize += _fontSizeStep;
                                    _saveRejalFontSize(_rejalFontSize);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        Text(
                          'الترجمة',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: availableTranslations.map((translation) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: FilterChip(
                          backgroundColor: Colors.transparent,
                          labelStyle: TextStyle(
                            color: selectedTranslation == translation
                                          ? Theme.of(context).colorScheme.surface
                                            : Theme.of(context).colorScheme.onSurface,
                          ),
                          checkmarkColor: Theme.of(context).colorScheme.surface,
                          label: Text(translation),
                          selected: selectedTranslation == translation,
                          onSelected: (selected) {
                            setState(() {
                              selectedTranslation = translation;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (widget.hekam.english1 != null && shouldShowTranslation('English')) ...[
                        Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'English',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Html(
                                  data: widget.hekam.english1!,
                                  style: {
                                    ...StyleHelper.getStyles(context),
                                    'html': Style(
                                      fontSize: FontSize(_rejalFontSize),
                                      textAlign: TextAlign.justify,
                                      fontFamily: 'font1',
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    'p': Style(
                                      textAlign: TextAlign.justify,
                                    ),
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (widget.hekam.farsi1 != null && shouldShowTranslation('فارسي ـ جعفري')) ...[
                        Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'فارسي ـ جعفري',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Html(
                                  data: widget.hekam.farsi1!,
                                  style: {
                                    ...StyleHelper.getStyles(context),
                                    'html': Style(
                                      fontSize: FontSize(_rejalFontSize),
                                      textAlign: TextAlign.justify,
                                      fontFamily: 'font1',
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    'p': Style(
                                      textAlign: TextAlign.justify,
                                    ),
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (widget.hekam.farsi2 != null && shouldShowTranslation('فارسي ـ انصاريان')) ...[
                        Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'فارسي ـ انصاريان',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Html(
                                  data: widget.hekam.farsi2!,
                                  style: {
                                    ...StyleHelper.getStyles(context),
                                    'html': Style(
                                      fontSize: FontSize(_rejalFontSize),
                                      textAlign: TextAlign.justify,
                                      fontFamily: 'font1',
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    'p': Style(
                                      textAlign: TextAlign.justify,
                                    ),
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (widget.hekam.farsi3 != null && shouldShowTranslation('فارسي ـ فيض الإسلام')) ...[
                        Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'فارسي ـ فيض الإسلام',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Html(
                                  data: widget.hekam.farsi3!,
                                  style: {
                                    ...StyleHelper.getStyles(context),
                                    'html': Style(
                                      fontSize: FontSize(_rejalFontSize),
                                      textAlign: TextAlign.justify,
                                      fontFamily: 'font1',
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    'p': Style(
                                      textAlign: TextAlign.justify,
                                    ),
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (widget.hekam.farsi4 != null && shouldShowTranslation('فارسي ـ شهيدي')) ...[
                        Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'فارسي ـ شهيدي',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Html(
                                  data: widget.hekam.farsi4!,
                                  style: {
                                    ...StyleHelper.getStyles(context),
                                    'html': Style(
                                      fontSize: FontSize(_rejalFontSize),
                                      textAlign: TextAlign.justify,
                                      fontFamily: 'font1',
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                                    'p': Style(
                                      textAlign: TextAlign.justify,
                                    ),
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
} 