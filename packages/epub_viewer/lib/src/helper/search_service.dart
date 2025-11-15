import 'package:html/parser.dart' as html_parser;

import '../models/search_model.dart';
import '../models/epub_viewer_persistence.dart';
import '../utils/arabic_text_helper.dart';

class DefaultSearchService implements SearchService {
  DefaultSearchService({this.searchSurroundCharCount = 40});

  final int searchSurroundCharCount;

  @override
  Future<List<SearchModel>> searchHtmlContents(List<String> htmlPages, String searchTerm) async {
    final results = <SearchModel>[];
    final normalizedSearch = removeArabicDiacritics(searchTerm);

    for (int i = 0; i < htmlPages.length; i++) {
      final plainText = _stripHtml(htmlPages[i]);
      _MatchRange? match = _findMatch(plainText, normalizedSearch, 0);

      while (match != null) {
        results.add(
          SearchModel(
            pageIndex: i + 1,
            searchedWord: searchTerm,
            searchCount: results.length + 1,
            spanna: _buildSnippet(plainText, match.start, match.end),
          ),
        );
        match = _findMatch(plainText, normalizedSearch, match.end);
      }
    }

    return results;
  }

  @override
  String removeArabicDiacritics(String input) {
    return ArabicTextHelper.removeArabicDiacritics(input);
  }

  _MatchRange? _findMatch(String content, String normalizedSearch, int start) {
    final normalizedContent = removeArabicDiacritics(content);
    final startIndex = normalizedContent.indexOf(normalizedSearch, start);
    if (startIndex < 0) return null;
    return _MatchRange(startIndex, startIndex + normalizedSearch.length);
  }

  String _stripHtml(String htmlString) {
    final text = html_parser.parse(htmlString).documentElement?.text ?? '';
    return text;
  }

  String _buildSnippet(String content, int start, int end) {
    final begin = start - searchSurroundCharCount > 0 ? start - searchSurroundCharCount : 0;
    final finish = end + searchSurroundCharCount > content.length ? content.length : end + searchSurroundCharCount;
    final before = content.substring(begin, start);
    final match = content.substring(start, end);
    final after = content.substring(end, finish);
    return '...$before<mark>$match</mark>$after...';
  }
}

class _MatchRange {
  _MatchRange(this.start, this.end);
  final int start;
  final int end;
}

