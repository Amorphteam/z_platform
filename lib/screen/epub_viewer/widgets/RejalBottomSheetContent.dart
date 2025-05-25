import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zahra/model/word.dart';


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

  @override
  Widget build(BuildContext context) {
    final saleh = widget.word?.saleh?.replaceAll('.', '. <br>').replaceFirst('&', '<h1>').replaceFirst('&', '</h1>');
    final abdah = widget.word?.abdah?.replaceAll('.', '. <br>').replaceFirst('&', '<h1>').replaceFirst('&', '</h1>');
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
            child: Column(
              children: [
                // Top bar with title and controls
                Padding(
                  padding: const EdgeInsets.all(16),
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
                      Padding(
                        padding: const EdgeInsets.only(top: 48.0),
                        child: Text(
                          widget.word?.word??'',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'almarai', color: Theme.of(context).colorScheme.secondary),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 48.0),
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                    ],
                  ),
                ),

                // Scrollable content

                Expanded(
                  child: SingleChildScrollView(
                    controller: widget.scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        buildCard(context, saleh, 'محمد عبده:'  ),
                        buildCard(context, saleh, 'صبحي صالح:'  ),
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
                        color: Theme.of(context).colorScheme.primaryContainer,
                        margin: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(title??'محمد عبده:', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontFamily: 'almarai', color: Theme.of(context).colorScheme.onPrimaryContainer),),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Html(
                                data: saleh,
                                style: {
                                  'html': Style(
                                    fontSize: FontSize(_rejalFontSize),
                                    lineHeight: LineHeight(1.5),
                                    textAlign: TextAlign.justify,
                                    fontFamily: 'font1',
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                  'h1': Style(
                                    fontSize: FontSize(_rejalFontSize + 1),
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