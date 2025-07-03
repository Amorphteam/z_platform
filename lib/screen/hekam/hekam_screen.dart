import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:share_plus/share_plus.dart';
import 'package:zahra/screen/hekam/cubit/hekam_cubit.dart';
import 'package:zahra/screen/hekam/widgets/translation_bottom_sheet.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:zahra/model/style_model.dart';
import 'package:zahra/util/style_helper.dart';
import 'package:zahra/util/translation_helper.dart';

import '../../model/hekam.dart';
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
Android: https://play.google.com/store/apps/details?id=org.masaha.nahj
iOS: https://apps.apple.com/app/6746411657''';
  }

  void _toggleFavorites() {
    setState(() {
      showFavorites = !showFavorites;
    });
  }

  Future<void> _showTranslationBottomSheet(Hekam hekam) async {
    // Check for available translations before opening the sheet
    final availableTranslations = await TranslationHelper.getAvailableTranslations();
    
    // If only "الكل" is available (no translations enabled), show snackbar and don't open sheet
    if (availableTranslations.length == 1 && availableTranslations.first == 'الكل') {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('لا توجد ترجمات مفعلة. يرجى تفعيل ترجمة واحدة على الأقل من الإعدادات.'),
            duration: const Duration(seconds: 6),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.onSurface,
            action: SnackBarAction(
              label: 'الإعدادات',
              textColor: Theme.of(context).colorScheme.primary,
              onPressed: () {
                Navigator.pushNamed(context, '/settingScreen');
              },
            ),
          ),
        );
      }
      return;
    }
    
    // If translations are available, show the bottom sheet
    if (mounted) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => TranslationBottomSheet(hekam: hekam),
      );
    }
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
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 4),
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
                                      lineHeight: LineHeight(_lineHeight.size),
                                      textDecoration: TextDecoration.none,
                                    ),
                                    'p': Style(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      textAlign: TextAlign.justify,
                                      fontFamily: _fontFamily.name,
                                      fontSize: FontSize(_fontSize.size),
                                      margin: Margins.only(bottom: 10),
                                      padding: HtmlPaddings.only(right: 7),
                                    ),
                                    'p.center': Style(
                                      color: isDarkMode ? Colors.white : const Color(0xFF996633),
                                      textAlign: TextAlign.center,
                                      margin: Margins.zero,
                                      fontFamily: _fontFamily.name,
                                      fontSize: FontSize(_fontSize.size),
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
                                      fontFamily: _fontFamily.name,
                                      fontSize: FontSize(_fontSize.size * 1.1),
                                    ),
                                    'h2': Style(
                                      color: isDarkMode ? Colors.white : const Color(0xFF000080),
                                      textAlign: TextAlign.center,
                                      margin: Margins.only(bottom: 10),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: _fontFamily.name,
                                      fontSize: FontSize(_fontSize.size),
                                    ),
                                    'h3': Style(
                                      color: isDarkMode ? Colors.white : const Color(0xFF006400),
                                      textAlign: TextAlign.right,
                                      margin: Margins.only(bottom: 10),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: _fontFamily.name,
                                      fontSize: FontSize(_fontSize.size),
                                    ),
                                    'h3.tit3_1': Style(
                                      color: isDarkMode ? Colors.white : const Color(0xFF800000),
                                      textAlign: TextAlign.right,
                                      margin: Margins.only(bottom: 10),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: _fontFamily.name,
                                      fontSize: FontSize(_fontSize.size),
                                    ),
                                    'h4.tit4': Style(
                                      color: isDarkMode ? Colors.white : Colors.red,
                                      textAlign: TextAlign.center,
                                      margin: Margins.zero,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: _fontFamily.name,
                                      fontSize: FontSize(_fontSize.size),
                                    ),
                                    '.pagen': Style(
                                      textAlign: TextAlign.center,
                                      color: isDarkMode ? Color(0xfff9825e) : Colors.red,
                                      fontFamily: _fontFamily.name,
                                      fontSize: FontSize(_fontSize.size),
                                    ),
                                    '.shareef': Style(
                                      color: isDarkMode ? Colors.white : const Color(0xFF996633),
                                      textAlign: TextAlign.justify,
                                      margin: Margins.only(bottom: 5),
                                      padding: HtmlPaddings.only(right: 7),
                                      fontFamily: _fontFamily.name,
                                      fontSize: FontSize(_fontSize.size * 0.9),
                                    ),
                                    '.shareef_sher': Style(
                                      textAlign: TextAlign.center,
                                      color: isDarkMode ? Colors.white : const Color(0xFF996633),
                                      margin: Margins.symmetric(vertical: 5),
                                      padding: HtmlPaddings.zero,
                                      fontFamily: _fontFamily.name,
                                      fontSize: FontSize(_fontSize.size * 0.9),
                                    ),
                                    '.fnote': Style(
                                      color: isDarkMode ? const Color(0xFF8a8afa) : const Color(0xFF000080),
                                      margin: Margins.zero,
                                      padding: HtmlPaddings.zero,
                                      fontSize: FontSize(_fontSize.size * 0.75),
                                    ),
                                    '.sher': Style(
                                      textAlign: TextAlign.center,
                                      color: isDarkMode ? Colors.white : const Color(0xFF990000),
                                      margin: Margins.symmetric(vertical: 10),
                                      padding: HtmlPaddings.zero,
                                      fontFamily: _fontFamily.name,
                                      fontSize: FontSize(_fontSize.size),
                                    ),
                                    '.psm': Style(
                                      textAlign: TextAlign.center,
                                      color: isDarkMode ? Colors.white : const Color(0xFF990000),
                                      margin: Margins.symmetric(vertical: 10),
                                      padding: HtmlPaddings.zero,
                                      fontFamily: _fontFamily.name,
                                      fontSize: FontSize(_fontSize.size * 0.8),
                                    ),
                                    '.shareh': Style(
                                      color: isDarkMode ? Colors.white : const Color(0xFF996633),
                                    ),
                                    '.msaleh': Style(
                                      color: Colors.purple,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: _fontFamily.name,
                                    ),
                                    '.onwan': Style(
                                      color: isDarkMode ? Colors.white : const Color(0xFF088888),
                                      fontWeight: FontWeight.bold,
                                      fontFamily: _fontFamily.name,
                                    ),
                                    '.fn': Style(
                                      color: isDarkMode ? const Color(0xff8a8afa) : const Color(0xFF000080),
                                      fontWeight: FontWeight.normal,
                                      fontSize: FontSize(_fontSize.size * 0.75),
                                      textDecoration: TextDecoration.none,
                                      verticalAlign: VerticalAlign.top,
                                    ),
                                    '.fm': Style(
                                      color: isDarkMode ? Color(0xffa2e1a2) : Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: FontSize(_fontSize.size * 0.75),
                                      textDecoration: TextDecoration.none,
                                    ),
                                    '.quran': Style(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Color(0xffa2e1a2) : const Color(0xFF509368),
                                      fontFamily: _fontFamily.name,
                                      fontSize: FontSize(_fontSize.size),
                                    ),
                                    '.hadith': Style(
                                      color: isDarkMode ? Color(0xffC1C1C1) : Colors.black,
                                      fontSize: FontSize(_fontSize.size),
                                    ),
                                    '.hadith-num': Style(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Color(0xfff9825e) : Colors.red,
                                      fontFamily: _fontFamily.name,
                                      fontSize: FontSize(_fontSize.size),
                                    ),
                                    '.shreah': Style(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Color(0xffC1C1C1) : Colors.black,
                                      fontFamily: _fontFamily.name,
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
                                        _showTranslationBottomSheet(item);
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