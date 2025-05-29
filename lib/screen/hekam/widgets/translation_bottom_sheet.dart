import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:zahra/model/hekam.dart';

import '../../../util/style_helper.dart';

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
                          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            color: selectedTranslation == translation 
                                ? Colors.white 
                                : Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                          checkmarkColor: Colors.white,
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
                                  style: StyleHelper.getStyles(context),
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
                                  style: StyleHelper.getStyles(context),
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
                                  style: StyleHelper.getStyles(context),
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
                                  style: StyleHelper.getStyles(context),
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
                                  style: StyleHelper.getStyles(context),
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