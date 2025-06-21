import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zahra/model/word.dart';
import 'package:zahra/util/style_helper.dart';
import 'package:zahra/model/style_model.dart';

class WordBottomSheetContent extends StatefulWidget {
  final Word? word;
  final ScrollController scrollController;

  const WordBottomSheetContent({
    required this.word,
    required this.scrollController,
  });

  @override
  State<WordBottomSheetContent> createState() => WordBottomSheetContentState();
}

class WordBottomSheetContentState extends State<WordBottomSheetContent> {
  late FontSizeCustom _fontSize;
  late LineHeightCustom _lineHeight;
  late FontFamily _fontFamily;

  @override
  void initState() {
    super.initState();
    _loadFontPreferences();
  }

  Future<void> _loadFontPreferences() async {
    final styleHelper = await StyleHelper.loadFromPrefs();
    setState(() {
      _fontSize = styleHelper.fontSize;
      _lineHeight = styleHelper.lineSpace;
      _fontFamily = styleHelper.fontFamily;
    });
  }

  Future<void> _saveFontPreferences() async {
    final styleHelper = StyleHelper();
    styleHelper.changeFontSize(_fontSize);
    styleHelper.changeLineSpace(_lineHeight);
    styleHelper.changeFontFamily(_fontFamily);
    await styleHelper.saveToPrefs();
  }

  @override
  Widget build(BuildContext context) {
    final saleh = widget.word?.saleh
            ?.replaceAll('.', '. <br>')
            .replaceFirst('&', '<h1>')
            .replaceFirst('&', '</h1>') ??
        '';
    final abdah = widget.word?.abdah
            ?.replaceAll('.', '. <br>')
            .replaceFirst('&', '<h1>')
            .replaceFirst('&', '</h1>') ??
        '';
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(
              children: [
                // Top bar with title and controls
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 48.0),
                            child: Text(
                              widget.word?.word ?? 'کلمه',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontFamily: 'almarai',
                                  color: Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),

                      // Scrollable content
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        if (abdah != null && abdah.isNotEmpty)
                          buildCard(context, abdah, 'محمد عبده:'),
                        if (saleh != null && saleh.isNotEmpty)
                          buildCard(context, saleh, 'صبحي صالح:'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Card buildCard(BuildContext context, String? saleh, String? title) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 16.0, right: 16.0),
            child: Text(
              title ?? 'محمد عبده:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontFamily: 'almarai',
                  color: Theme.of(context).colorScheme.secondaryContainer),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Html(
              data: saleh,
              style: {
                'html': Style(
                  fontSize: FontSize(_fontSize.size),
                  lineHeight: LineHeight(_lineHeight.size),
                  textAlign: TextAlign.justify,
                  fontFamily: _fontFamily.name,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                'h1': Style(
                  fontSize: FontSize(_fontSize.size + 1),
                  fontWeight: FontWeight.bold,
                  textAlign: TextAlign.justify,
                  fontFamily: 'kuffi',
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                'p': Style(
                  textAlign: TextAlign.justify,
                ),
                'br': Style(
                  display: Display.block,
                ),
              },
            ),
          ),
        ],
      ),
    );
  }
}
