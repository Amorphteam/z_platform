import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../model/rejal.dart';

class RejalBottomSheetContent extends StatefulWidget {
  final Rejal rejal;
  final ScrollController scrollController;

  const RejalBottomSheetContent({
    required this.rejal,
    required this.scrollController,
  });

  @override
  State<RejalBottomSheetContent> createState() => RejalBottomSheetContentState();
}

class RejalBottomSheetContentState extends State<RejalBottomSheetContent> {
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
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
                        padding: const EdgeInsets.only(top: 28.0),
                        child: Text(
                          widget.rejal.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontFamily: 'kuffi', color: Theme.of(context).colorScheme.secondary),
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
                    padding: const EdgeInsets.all(16),
                    child: Html(
                      data: widget.rejal.det,
                      style: {
                        'html': Style(
                          fontSize: FontSize(_rejalFontSize),
                          lineHeight: LineHeight(1.5),
                          textAlign: TextAlign.justify,
                          fontFamily: 'font1',
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
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: Text(
                  '  معجم رجال الحديث ${widget.rejal.joz} : ${widget.rejal.page} / ${widget.rejal.ID}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}