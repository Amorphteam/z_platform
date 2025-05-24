import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:zahra/model/hekam.dart';

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
  String selectedTranslation = 'All';

  Map<String, Style> get translationStyles => {
    "body": Style(
      fontSize: FontSize(16),
      color: Theme.of(context).textTheme.bodyLarge?.color,
      textAlign: TextAlign.right,
      direction: TextDirection.rtl,
      textDecoration: TextDecoration.none,
    ),
    "p": Style(
      textAlign: TextAlign.justify,
      margin: Margins.only(top: 0, bottom: 10),
      fontFamily: 'Lotus Qazi Light',
    ),
    "p.center": Style(
      textAlign: TextAlign.center,
    ),
    "p.sher": Style(
      textAlign: TextAlign.center,
      color: const Color(0xFF990000),
      fontSize: FontSize(16),
      margin: Margins.only(top: 10, bottom: 10),
    ),
    "p.english": Style(
      color: const Color(0xFF800000),
      direction: TextDirection.ltr,
    ),
    "p.arabic": Style(
      color: const Color(0xFF000080),
      direction: TextDirection.rtl,
    ),
    "p.farsi": Style(
      color: const Color(0xFF006400),
      fontSize: FontSize(16),
      margin: Margins.only(top: 10, bottom: 10),
      fontFamily: 'nazanin',
    ),
    "p.farsi-title": Style(
      color: const Color(0xFF000080),
      fontSize: FontSize(16),
      margin: Margins.only(top: 10, bottom: 10),
      fontFamily: 'nazaninBold',
    ),
    "h1": Style(
      color: const Color(0xFF00AA00),
      fontSize: FontSize(16),
      margin: Margins.only(top: 0, bottom: 10),
      textAlign: TextAlign.center,
      fontFamily: 'Lotus Qazi Bold',
    ),
    "h2": Style(
      color: const Color(0xFF000080),
      fontSize: FontSize(16),
      margin: Margins.only(top: 0, bottom: 10),
      textAlign: TextAlign.center,
      fontFamily: 'Lotus Qazi Bold',
    ),
    "h3": Style(
      color: const Color(0xFF800000),
      fontSize: FontSize(16),
      margin: Margins.only(top: 0, bottom: 10),
      textAlign: TextAlign.center,
      fontFamily: 'Lotus Qazi Bold',
    ),
    "h4": Style(
      color: Colors.red,
      fontSize: FontSize(16),
      margin: Margins.only(top: 0, bottom: 0),
      textAlign: TextAlign.center,
      fontFamily: 'Lotus Qazi Bold',
    ),
    ".fn": Style(
      color: Colors.blue,
      fontWeight: FontWeight.normal,
      fontSize: FontSize(12),
      textDecoration: TextDecoration.none,
      verticalAlign: VerticalAlign.top,
    ),
    ".fm": Style(
      color: const Color(0xFF008000),
      fontWeight: FontWeight.bold,
      fontSize: FontSize(12),
      textDecoration: TextDecoration.none,
    ),
    ".quran": Style(
      fontWeight: FontWeight.bold,
      color: Colors.green,
    ),
    ".hadith": Style(
      fontWeight: FontWeight.bold,
      color: const Color(0xFF008080),
    ),
  };

  List<String> get availableTranslations {
    final translations = <String>['All'];
    if (widget.hekam.english1 != null) translations.add('English');
    if (widget.hekam.farsi1 != null) translations.add('فارسی ۱');
    if (widget.hekam.farsi2 != null) translations.add('فارسی ۲');
    if (widget.hekam.farsi3 != null) translations.add('فارسی ۳');
    if (widget.hekam.farsi4 != null) translations.add('فارسی ۴');
    return translations;
  }

  bool shouldShowTranslation(String title) {
    if (selectedTranslation == 'All') return true;
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
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
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
                                  style: translationStyles,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (widget.hekam.farsi1 != null && shouldShowTranslation('فارسی ۱')) ...[
                        Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'فارسی ۱',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Html(
                                  data: widget.hekam.farsi1!,
                                  style: translationStyles,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (widget.hekam.farsi2 != null && shouldShowTranslation('فارسی ۲')) ...[
                        Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'فارسی ۲',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Html(
                                  data: widget.hekam.farsi2!,
                                  style: translationStyles,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (widget.hekam.farsi3 != null && shouldShowTranslation('فارسی ۳')) ...[
                        Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'فارسی ۳',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Html(
                                  data: widget.hekam.farsi3!,
                                  style: translationStyles,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      if (widget.hekam.farsi4 != null && shouldShowTranslation('فارسی ۴')) ...[
                        Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'فارسی ۴',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 8),
                                Html(
                                  data: widget.hekam.farsi4!,
                                  style: translationStyles,
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