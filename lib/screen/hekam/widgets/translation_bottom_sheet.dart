import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:zahra/model/hekam.dart';
import 'package:zahra/util/style_helper.dart';
import 'package:zahra/util/translation_helper.dart';

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
  late FontSizeCustom _fontSize;
  late LineHeightCustom _lineHeight;
  late FontFamily _fontFamily;
  List<String> _availableTranslations = ['الكل'];

  @override
  void initState() {
    super.initState();
    _loadFontPreferences();
    _loadAvailableTranslations();
  }

  Future<void> _loadFontPreferences() async {
    final styleHelper = await StyleHelper.loadFromPrefs();
    setState(() {
      _fontSize = styleHelper.fontSize;
      _lineHeight = styleHelper.lineSpace;
      _fontFamily = styleHelper.fontFamily;
    });
  }

  Future<void> _loadAvailableTranslations() async {
    final translations = await TranslationHelper.getAvailableTranslations();
    setState(() {
      _availableTranslations = translations;
    });
  }

  bool shouldShowTranslation(String title) {
    if (selectedTranslation == 'الكل') {
      // When "الكل" is selected, only show translations that are enabled in settings
      return _availableTranslations.contains(title);
    }
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
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 48.0),
                            child: Center(
                              child: Text(
                                'الترجمة',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                          ),
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
                    children: _availableTranslations.map((translation) {
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
                    children: _buildTranslationContent(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildTranslationContent() {
    List<Widget> content = [];
    if (widget.hekam.english1 != null && shouldShowTranslation('English')) {
      content.add(Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Html(
                data: widget.hekam.english1!,
                style: {
                  ...StyleHelper.getStyles(context),
                  'html': Style(
                    fontSize: FontSize(_fontSize.size),
                    lineHeight: LineHeight(_lineHeight.size),
                    fontFamily: 'arial',
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  'p': Style(
                    direction: TextDirection.ltr,
                    textAlign: TextAlign.left,
                    fontFamily: 'arial',
                  ),
                },
              ),
            ],
          ),
        ),
      ));
      content.add(const SizedBox(height: 16));
    }
    if (widget.hekam.farsi1 != null && shouldShowTranslation('فارسي ـ جعفري')) {
      content.add(Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Html(
                data: widget.hekam.farsi1!,
                style: {
                  ...StyleHelper.getStyles(context),
                  'html': Style(
                    fontSize: FontSize(_fontSize.size),
                    lineHeight: LineHeight(_lineHeight.size),
                    textAlign: TextAlign.justify,
                    fontFamily: _fontFamily.name,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  'p': Style(
                    textAlign: TextAlign.justify,
                    fontFamily: _fontFamily.name,
                  ),
                },
              ),
            ],
          ),
        ),
      ));
      content.add(const SizedBox(height: 16));
    }
    if (widget.hekam.farsi2 != null && shouldShowTranslation('فارسي ـ انصاريان')) {
      content.add(Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Html(
                data: widget.hekam.farsi2!,
                style: {
                  ...StyleHelper.getStyles(context),
                  'html': Style(
                    fontSize: FontSize(_fontSize.size),
                    lineHeight: LineHeight(_lineHeight.size),
                    textAlign: TextAlign.justify,
                    fontFamily: _fontFamily.name,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  'p': Style(
                    textAlign: TextAlign.justify,
                    fontFamily: _fontFamily.name,
                  ),
                },
              ),
            ],
          ),
        ),
      ));
      content.add(const SizedBox(height: 16));
    }
    if (widget.hekam.farsi3 != null && shouldShowTranslation('فارسي ـ فيض الإسلام')) {
      content.add(Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Html(
                data: widget.hekam.farsi3!,
                style: {
                  ...StyleHelper.getStyles(context),
                  'html': Style(
                    fontSize: FontSize(_fontSize.size),
                    lineHeight: LineHeight(_lineHeight.size),
                    textAlign: TextAlign.justify,
                    fontFamily: _fontFamily.name,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  'p': Style(
                    textAlign: TextAlign.justify,
                    fontFamily: _fontFamily.name,
                  ),
                },
              ),
            ],
          ),
        ),
      ));
      content.add(const SizedBox(height: 16));
    }
    if (widget.hekam.farsi4 != null && shouldShowTranslation('فارسي ـ شهيدي')) {
      content.add(Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Html(
                data: widget.hekam.farsi4!,
                style: {
                  ...StyleHelper.getStyles(context),
                  'html': Style(
                    fontSize: FontSize(_fontSize.size),
                    lineHeight: LineHeight(_lineHeight.size),
                    textAlign: TextAlign.justify,
                    fontFamily: _fontFamily.name,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  'p': Style(
                    textAlign: TextAlign.justify,
                    fontFamily: _fontFamily.name,
                  ),
                },
              ),
            ],
          ),
        ),
      ));
      content.add(const SizedBox(height: 16));
    }
    return content;
  }
} 