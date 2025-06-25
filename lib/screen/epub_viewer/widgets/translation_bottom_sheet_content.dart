import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

import '../../../model/style_model.dart';
import '../../../util/style_helper.dart';

class TranslationBottomSheetContent extends StatefulWidget {
  final Map<String, dynamic> translation;

  const TranslationBottomSheetContent({
    Key? key,
    required this.translation,
  }) : super(key: key);

  @override
  State<TranslationBottomSheetContent> createState() => _TranslationBottomSheetContentState();
}

class _TranslationBottomSheetContentState extends State<TranslationBottomSheetContent> {
  String selectedTranslation = ''; // Will be set dynamically
  late FontSizeCustom _fontSize;
  late LineHeightCustom _lineHeight;
  late FontFamily _fontFamily;

  @override
  void initState() {
    super.initState();
    _loadFontPreferences();
    _setInitialTranslation();
  }

  void _setInitialTranslation() {
    // Set the first available translation as selected
    if (widget.translation['فارسي ـ جعفري'] != null) {
      selectedTranslation = 'فارسي ـ جعفري';
    } else if (widget.translation['فارسي ـ انصاريان'] != null) {
      selectedTranslation = 'فارسي ـ انصاريان';
    } else if (widget.translation['فارسي ـ فيض الإسلام'] != null) {
      selectedTranslation = 'فارسي ـ فيض الإسلام';
    } else if (widget.translation['فارسي ـ شهيدي'] != null) {
      selectedTranslation = 'فارسي ـ شهيدي';
    } else if (widget.translation['English'] != null) {
      selectedTranslation = 'English';
    }
  }

  Future<void> _loadFontPreferences() async {
    final styleHelper = await StyleHelper.loadFromPrefs();
    setState(() {
      _fontSize = styleHelper.fontSize;
      _lineHeight = styleHelper.lineSpace;
      _fontFamily = styleHelper.fontFamily;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Top bar with title and controls
            Padding(
              padding: const EdgeInsets.only(right: 16, left: 16, top: 56),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 48.0),
                      child: Center(
                        child: Text(
                            'الترجمة',
                            style: Theme.of(context).textTheme.titleLarge
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
            // Translation chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  if (widget.translation['فارسي ـ جعفري'] != null)
                    _buildTranslationChip(
                      context,
                      'فارسي ـ جعفري',
                      selectedTranslation == 'فارسي ـ جعفري',
                          () => setState(() => selectedTranslation = 'فارسي ـ جعفري'),
                    ),
                  if (widget.translation['فارسي ـ انصاريان'] != null)
                    _buildTranslationChip(
                      context,
                      'فارسي ـ انصاريان',
                      selectedTranslation == 'فارسي ـ انصاريان',
                          () => setState(() => selectedTranslation = 'فارسي ـ انصاريان'),
                    ),
                  if (widget.translation['فارسي ـ فيض الإسلام'] != null)
                    _buildTranslationChip(
                      context,
                      'فارسي ـ فيض الإسلام',
                      selectedTranslation == 'فارسي ـ فيض الإسلام',
                          () => setState(() => selectedTranslation = 'فارسي ـ فيض الإسلام'),
                    ),
                  if (widget.translation['فارسي ـ شهيدي'] != null)
                    _buildTranslationChip(
                      context,
                      'فارسي ـ شهيدي',
                      selectedTranslation == 'فارسي ـ شهيدي',
                          () => setState(() => selectedTranslation = 'فارسي ـ شهيدي'),
                    ),
                  if (widget.translation['English'] != null)
                    _buildTranslationChip(
                      context,
                      'English',
                      selectedTranslation == 'English',
                          () => setState(() => selectedTranslation = 'English'),
                    ),
                ],
              ),
            ),
            // Selected translation content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    if (widget.translation[selectedTranslation] != null)
                      buildCard(
                        context,
                        widget.translation[selectedTranslation].toString(),
                        selectedTranslation,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildTranslationChip(BuildContext context, String title, bool isSelected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          title,
          style: TextStyle(
            fontFamily: 'almarai',
            color: isSelected
                ? Theme.of(context).colorScheme.surface
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        selected: isSelected,
        onSelected: (_) => onTap(),
        checkmarkColor: Theme.of(context).colorScheme.surface,
        backgroundColor: Colors.transparent,
        selectedColor: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Card buildCard(BuildContext context, String content, String title) {
    final bool isEnglish = selectedTranslation == 'English';
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Directionality(
              textDirection: isEnglish ? TextDirection.ltr : TextDirection.rtl,
              child: Html(
                  data: content,
                  style: {
                    ...StyleHelper.getStyles(context, _fontFamily, _fontSize, _lineHeight, isEnglish),
                  }
              ),
            ),
          ),
        ],
      ),
    );
  }
}