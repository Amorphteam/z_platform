import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:zahra/model/hekam.dart';
import 'package:zahra/util/style_helper.dart';

import '../../../model/style_model.dart';

class IbnHadidBottomSheet extends StatefulWidget {
  final Hekam hekam;

  const IbnHadidBottomSheet({
    super.key,
    required this.hekam,
  });

  @override
  State<IbnHadidBottomSheet> createState() => _IbnHadidBottomSheetState();
}

class _IbnHadidBottomSheetState extends State<IbnHadidBottomSheet> {
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
                                'شرح ابن أبي الحدید',
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
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    padding: const EdgeInsets.all(16),
                    children: _buildDescriptionContent(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildDescriptionContent() {
    List<Widget> content = [];
    if (widget.hekam.hadid != null && widget.hekam.hadid!.isNotEmpty) {
      content.add(Card(
        elevation: 0,
        color: Theme.of(context).colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Html(
                data: widget.hekam.hadid!,
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

