import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zahra/screen/hekam/cubit/hekam_cubit.dart';
import 'package:zahra/screen/hekam/widgets/translation_bottom_sheet.dart';
import 'package:html/parser.dart' as html_parser;

import '../../widget/custom_appbar.dart';

class HekamScreen extends StatefulWidget {
  const HekamScreen({super.key});

  @override
  State<HekamScreen> createState() => _HekamScreenState();
}

class _HekamScreenState extends State<HekamScreen> {
  bool isDarkMode = false;
  bool showFavorites = false;
  String _searchQuery = '';

  String _removeDiacritics(String text) {
    return text
        .replaceAll(RegExp(r'[ًٌٍَُِّْ]'), '') // Arabic diacritics
        .replaceAll(RegExp(r'[.ـ:،]'), '') // Arabic punctuation
        .replaceAll(RegExp(r'\s+'), ' ') // Normalize spaces
        .trim();
  }

  void _filterHekam(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  String _cleanHtmlText(String htmlText) {
    final document = html_parser.parse(htmlText);
    return document.body?.text ?? htmlText;
  }

  String _getShareText(String text) {
    final cleanText = _cleanHtmlText(text);
    return '''$cleanText

تحميل تطبيق نهج البلاغة:
Android: https://play.google.com/store/apps/details?id=com.zahra.app
iOS: https://apps.apple.com/app/zahra-app''';
  }

  void _toggleFavorites() {
    setState(() {
      showFavorites = !showFavorites;
    });
  }

  @override
  Widget build(BuildContext context) {
    isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => HekamCubit()..fetchHekam(),
      child: Builder(
        builder: (context) => Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            appBar: CustomAppBar(
              rightIcon: showFavorites ? Icons.star_rate_rounded : Icons.star_border_outlined,
              backgroundImage: 'assets/image/back_tazhib_light.jpg',
              title: showFavorites ? 'المفضلة' : 'الحكم والمواعظ',
              showSearchBar: true,
              onSearch: _filterHekam,
              onRightTap: _toggleFavorites,
            ),
            body: BlocBuilder<HekamCubit, HekamState>(
              builder: (context, state) => state.when(
                  initial: () => const Center(child: CircularProgressIndicator()),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  loaded: (hekam) {
                    var items = showFavorites
                        ? hekam.where((item) => item.isFavorite).toList()
                        : hekam.toList();

                    // Apply search filter if there's a search query
                    if (_searchQuery.isNotEmpty) {
                      final cleanQuery = _removeDiacritics(_searchQuery.toLowerCase());
                      items = items.where((item) => _removeDiacritics(_cleanHtmlText(item.asl)
                          .toLowerCase())
                          .contains(cleanQuery)).toList();
                    }

                    if (showFavorites && items.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'لا توجد عناصر في المفضلة',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              onPressed: _toggleFavorites,
                              label: const Text('عرض الحكم والمواعظ'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        return Card(
                          elevation: 0,
                          color: Theme.of(context).colorScheme.primaryContainer,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Html(
                                  data: item.asl,
                                  style: {
                                    'body': Style(
                                      direction: TextDirection.rtl,
                                      textAlign: TextAlign.justify,
                                      textDecoration: TextDecoration.none,
                                    ),
                                    'p': Style(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      textAlign: TextAlign.justify,
                                      fontFamily: 'Lotus Qazi Light',
                                      fontSize: FontSize(17),
                                      margin: Margins.only(bottom: 10),
                                      padding: HtmlPaddings.only(right: 7),
                                    ),
                                    'p.center': Style(
                                      color: isDarkMode ? Colors.white : const Color(0xFF996633),
                                      textAlign: TextAlign.center,
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                    ),
                                    'a': Style(
                                      textDecoration: TextDecoration.none,
                                    ),
                                    'a:link': Style(
                                      color: const Color(0xFF2484C6),
                                    ),
                                    'a:visited': Style(
                                      color: Colors.red,
                                    ),
                                    'h1': Style(
                                      color: isDarkMode ? Colors.white : const Color(0xFF00AA00),
                                      textAlign: TextAlign.center,
                                      margin: Margins.only(bottom: 10),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    'h2': Style(
                                      color: isDarkMode ? Colors.white : const Color(0xFF000080),
                                      textAlign: TextAlign.center,
                                      margin: Margins.only(bottom: 10),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    'h3': Style(
                                      color: isDarkMode ? Colors.white : const Color(0xFF006400),
                                      textAlign: TextAlign.right,
                                      margin: Margins.only(bottom: 10),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    'h3.tit3_1': Style(
                                      color: isDarkMode ? Colors.white : const Color(0xFF800000),
                                      textAlign: TextAlign.right,
                                      margin: Margins.only(bottom: 10),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    'h4.tit4': Style(
                                      color: isDarkMode ? Colors.white : Colors.red,
                                      textAlign: TextAlign.center,
                                      margin: Margins.zero,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    '.pagen': Style(
                                      textAlign: TextAlign.center,
                                      color: isDarkMode ? Color(0xfff9825e) : Colors.red,
                                    ),
                                    '.shareef': Style(
                                      color: isDarkMode ? Colors.white : const Color(0xFF996633),
                                      textAlign: TextAlign.justify,
                                      margin: Margins.only(bottom: 5),
                                      padding: HtmlPaddings.only(right: 7),
                                    ),
                                    '.shareef_sher': Style(
                                      textAlign: TextAlign.center,
                                      color: isDarkMode ? Colors.white : const Color(0xFF996633),
                                      margin: Margins.symmetric(vertical: 5),
                                      padding: HtmlPaddings.zero,
                                    ),
                                    '.fnote': Style(
                                      color: isDarkMode ? const Color(0xFF8a8afa) : const Color(0xFF000080),
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                    ),
                                    '.sher': Style(
                                      textAlign: TextAlign.center,
                                      color: isDarkMode ? Colors.white : const Color(0xFF990000),
                                      margin: Margins.symmetric(vertical: 10),
                                      padding: HtmlPaddings.zero,
                                    ),
                                    '.psm': Style(
                                      textAlign: TextAlign.center,
                                      color: isDarkMode ? Colors.white : const Color(0xFF990000),
                                      margin: Margins.symmetric(vertical: 10),
                                      padding: HtmlPaddings.zero,
                                    ),
                                    '.shareh': Style(
                                      color: isDarkMode ? Colors.white : const Color(0xFF996633),
                                    ),
                                    '.msaleh': Style(
                                      color: Colors.purple,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    '.onwan': Style(
                                      color: isDarkMode ? Colors.white : const Color(0xFF088888),
                                      fontWeight: FontWeight.bold,
                                    ),
                                    '.fn': Style(
                                      color: isDarkMode ? const Color(0xff8a8afa) : const Color(0xFF000080),
                                      fontWeight: FontWeight.normal,
                                      textDecoration: TextDecoration.none,
                                      verticalAlign: VerticalAlign.top,
                                    ),
                                    '.fm': Style(
                                      color: isDarkMode ? Color(0xffa2e1a2) : Colors.green,
                                      fontWeight: FontWeight.bold,
                                      textDecoration: TextDecoration.none,
                                    ),
                                    '.quran': Style(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Color(0xffa2e1a2) : const Color(0xFF509368),
                                    ),
                                    '.hadith': Style(
                                      color: isDarkMode ? Color(0xffC1C1C1) : Colors.black,
                                    ),
                                    '.hadith-num': Style(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Color(0xfff9825e) : Colors.red,
                                    ),
                                    '.shreah': Style(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Color(0xffC1C1C1) : Colors.black,
                                    ),
                                    '.kalema': Style(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.white : const Color(0xFFCC0066),
                                    ),
                                    'mark': Style(
                                      backgroundColor: Colors.yellow,
                                    ),
                                  },
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.share),
                                      onPressed: () {
                                        Share.share(_getShareText(item.asl));
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.translate),
                                      onPressed: () {
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) => TranslationBottomSheet(hekam: item),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        item.isFavorite ? Icons.star_rate : Icons.star_border_outlined,
                                        color: item.isFavorite ? Theme.of(context).colorScheme.secondaryContainer : null,
                                      ),
                                      onPressed: () {
                                        context.read<HekamCubit>().toggleFavorite(item.id);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                  error: (message) => Center(child: Text(message)),
                ),
            ),
          ),
      ),
    );
  }
} 