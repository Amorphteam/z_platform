import 'dart:ui';

import 'package:epub_parser/epub_parser.dart';
import '../../../model/search_model.dart';
import '../../../model/style_model.dart';
import '../cubit/epub_viewer_cubit.dart';

/// Extracts state data from EpubViewerState, with fallback to cubit cached values
class EpubViewerStateExtractor {
  static EpubViewerStateData extract(EpubViewerState state, EpubViewerCubit? cubit) {
    final content = state.maybeWhen(
      loaded: (content, _, __) => content,
      contentHighlighted: (content, _, __) => content,
      orElse: () => <String>[],
    );

    final bookTitle = state.maybeWhen(
      loaded: (_, title, __) => title,
      orElse: () => '',
    );

    final tocList = state.maybeWhen(
      loaded: (_, __, tocList) => tocList,
      orElse: () => <EpubChapter>[],
    );

    final isBookmarked = state.maybeWhen(
      bookmarkPresent: () => true,
      orElse: () => false,
    );

    // Extract search results - use from state if available, otherwise use cubit's cached results
    List<SearchModel> searchResults = [];
    state.maybeWhen(
      searchResultsFound: (results) {
        searchResults = results;
      },
      orElse: () {
        // Fallback to cubit's search results if state doesn't have them
        searchResults = cubit?.currentSearchResults ?? <SearchModel>[];
      },
    );

    // Extract current page - use from state if available, otherwise use cubit's current page
    double currentPage = 0.0;
    state.maybeWhen(
      pageChanged: (pageNumber) {
        currentPage = pageNumber?.toDouble() ?? 0.0;
      },
      orElse: () {
        // Fallback to cubit's current page if state doesn't have it
        currentPage = cubit?.currentPage.toDouble() ?? 0.0;
      },
    );

    // Extract style - use from state if available, otherwise use cached from cubit or defaults
    FontSizeCustom? tempFontSize;
    LineHeightCustom? tempLineHeight;
    FontFamily? tempFontFamily;
    Color? tempBackgroundColor;
    bool? tempUseUniformTextColor;
    Color? tempUniformTextColor;
    
    state.maybeWhen(
      styleChanged: (fs, lh, ff, bg, uniformEnabled, uniformColor) {
        tempFontSize = fs;
        tempLineHeight = lh;
        tempFontFamily = ff;
        tempBackgroundColor = bg;
        tempUseUniformTextColor = uniformEnabled;
        tempUniformTextColor = uniformColor;
      },
      orElse: () {},
    );

    return EpubViewerStateData(
      content: content,
      bookTitle: bookTitle,
      tocList: tocList,
      isBookmarked: isBookmarked,
      searchResults: searchResults,
      currentPage: currentPage,
      fontSize: tempFontSize ?? cubit?.cachedFontSize ?? FontSizeCustom.medium,
      lineHeight: tempLineHeight ?? cubit?.cachedLineHeight ?? LineHeightCustom.medium,
      fontFamily: tempFontFamily ?? cubit?.cachedFontFamily ?? FontFamily.font1,
      backgroundColor: tempBackgroundColor ?? cubit?.cachedBackgroundColor ?? const Color(0xFFFFFFFF),
      useUniformTextColor: tempUseUniformTextColor ?? cubit?.useUniformTextColor ?? false,
      uniformTextColor: tempUniformTextColor ?? cubit?.cachedUniformTextColor ?? const Color(0xFF000000),
    );
  }
}

class EpubViewerStateData {
  final List<String> content;
  final String bookTitle;
  final List<EpubChapter>? tocList;
  final bool isBookmarked;
  final List<SearchModel> searchResults;
  final double currentPage;
  final FontSizeCustom fontSize;
  final LineHeightCustom lineHeight;
  final FontFamily fontFamily;
  final Color backgroundColor;
  final bool useUniformTextColor;
  final Color uniformTextColor;

  EpubViewerStateData({
    required this.content,
    required this.bookTitle,
    this.tocList,
    required this.isBookmarked,
    required this.searchResults,
    required this.currentPage,
    required this.fontSize,
    required this.lineHeight,
    required this.fontFamily,
    required this.backgroundColor,
    required this.useUniformTextColor,
    required this.uniformTextColor,
  });
}

