import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:epub_parser/epub_parser.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../model/history_model.dart';
import '../../../model/reference_model.dart';
import '../../../model/search_model.dart';
import '../../../model/style_model.dart';
import '../../../repository/hostory_database.dart';
import '../../../repository/reference_database.dart';
import '../../../util/epub_helper.dart';
import '../../../util/search_helper.dart';
import '../../../util/style_helper.dart';
part 'epub_viewer_cubit.freezed.dart';
part 'epub_viewer_state.dart';

/// Helper class to store information about a block tag
class _BlockTagInfo {
  final String blockTag;
  final int startIndex;
  final int endIndex;
  
  const _BlockTagInfo(this.blockTag, this.startIndex, this.endIndex);
}

class EpubViewerCubit extends Cubit<EpubViewerState> {
  EpubViewerCubit() : super(const EpubViewerState.initial());
  
  EpubBook? _epubBook;
  List<String>? _spineHtmlContent;
  List<String>? _spineHtmlFileName;
  List<int>? _spineHtmlFileIndex;
  List<HtmlFileInfo>? _epubContent;

  String? _assetPath;
  String? _bookTitle;
  List<EpubChapter>? _tocTreeList;
  StyleHelper styleHelper = StyleHelper();

  final ReferencesDatabase referencesDatabase = ReferencesDatabase.instance;
  final searchHelper = SearchHelper();


  Future<void> checkBookmark(String bookPath, String pageIndex) async {
    final bool isBookmarked = await referencesDatabase.isBookmarkExist(bookPath, pageIndex);
    emit(isBookmarked ? const EpubViewerState.bookmarkPresent() : const EpubViewerState.bookmarkAbsent());
  }


  Future<void> removeBookmark(String bookPath, String pageNumber) async {
    try {
      final int result = await referencesDatabase.deleteReferenceByBookPathAndPageNumber(bookPath, pageNumber);
      if (result != 0) {
        emit(const EpubViewerState.bookmarkAbsent());
      } else {
      }
    } catch (error) {
      emit(EpubViewerState.error(error: error.toString()));
    }
  }


  Future<void> loadAndParseEpub(String assetPath) async {
    emit(const EpubViewerState.loading());

    try {
      final EpubBook epubBook = await loadEpubFromAsset(assetPath);
      final List<HtmlFileInfo> epubContent =
      await extractHtmlContentWithEmbeddedImages(epubBook);
      final spineItems = epubBook.Schema?.Package?.Spine?.Items;
      final List<String> idRefs = [];

      if (spineItems != null) {
        for (final item in spineItems) {
          if (item.IdRef != null) {
            idRefs.add(item.IdRef!);
          }
        }
      }

      _storeEpubDetails(epubBook, reorderHtmlFilesBasedOnSpine(epubContent, idRefs), assetPath);
          emit(const EpubViewerState.loading());
          await Future.delayed(const Duration(milliseconds: 200));

      emit(EpubViewerState.loaded(content: _spineHtmlContent!,
        epubTitle: _bookTitle ?? '',
        tocTreeList: _tocTreeList,),);
    } catch (error) {
      emit(EpubViewerState.error(error: error.toString()));
    }
  }


  Future<void> emitLastPageSeen() async {
    final lastPageNumber = await getLastPageNumberForBook(
      assetPath: _assetPath!,);
    if (lastPageNumber != null) {
      jumpToPage(newPage: lastPageNumber.toInt());
    }
  }

  Future<void> emitCustomPageSeen(String customPage) async {
    jumpToPage(newPage: int.parse(customPage));
  }

  void _storeEpubDetails(EpubBook epubBook, List<HtmlFileInfo> epubContent,
      String assetPath,) {
    _epubBook = epubBook;
    _epubContent = epubContent;
    _spineHtmlContent =
        epubContent.map((info) => info.modifiedHtmlContent).toList();
    _spineHtmlFileName = epubContent.map((info) => info.fileName).toList();
    _spineHtmlFileIndex = epubContent.map((info) => info.pageIndex).toList();
    _assetPath = assetPath;
    _bookTitle = epubBook.Title;
    _tocTreeList = epubBook.Chapters;

  }

  void changeStyle({FontSizeCustom? fontSize, LineHeightCustom? lineSpace, FontFamily? fontFamily}) {
    if (fontSize != null) styleHelper.changeFontSize(fontSize);
    if (lineSpace != null) styleHelper.changeLineSpace(lineSpace);
    if (fontFamily != null) styleHelper.changeFontFamily(fontFamily);

    styleHelper.saveToPrefs();

    emit(EpubViewerState.styleChanged(fontSize: fontSize, lineHeight: lineSpace, fontFamily: fontFamily));
  }


  Future<void> jumpToPage({String? chapterFileName, int? newPage}) async {

    if (newPage != null) {
      emit(EpubViewerState.pageChanged(pageNumber: newPage));
    }
    if (chapterFileName != null) {
      try {
        final int spineNumber =
        await findPageIndexInEpub(_epubBook!, chapterFileName);
        emit(EpubViewerState.pageChanged(pageNumber: spineNumber));
      } catch (error) {
        emit(EpubViewerState.error(error: error.toString()));
      }
    }
  }


  _saveStyleHelperToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final styleJson = styleHelper.toJson();
    prefs.setString('styleHelper', jsonEncode(styleJson));
  }

  Future<void> loadUserPreferences() async {
    StyleHelper.loadFromPrefs().then((_) {
      emit(EpubViewerState.styleChanged(
        fontSize: styleHelper.fontSize,
        lineHeight: styleHelper.lineSpace,
        fontFamily: styleHelper.fontFamily,
      ),);
    });
  }

  Future<void> addBookmark(ReferenceModel bookmark) async {
    try {
      final referencesDatabase = ReferencesDatabase.instance;
      final existingReferences = await referencesDatabase
          .getReferenceByBookTitleAndPage(bookmark.bookPath, bookmark.navIndex);
      if (existingReferences.isEmpty) {
        final int addStatus = await referencesDatabase.addReference(bookmark);
        emit(EpubViewerState.bookmarkAdded(status: addStatus));
      } else {
        emit(const EpubViewerState.bookmarkAdded(status: -1));
      }
    } catch (error) {
      if (error is Exception) {
        emit(EpubViewerState.error(error: error.toString()));
      }
    }
  }


  Future<void> addHistory(HistoryModel history) async {
    try {
      final historyDatabase = HistoryDatabase.instance;
      final existingHistory = await historyDatabase
          .getHistoryByBookTitleAndPage(history.bookPath, history.navIndex);
      if (existingHistory.isEmpty) {
        final int addStatus = await historyDatabase.addHistory(history);
        emit(EpubViewerState.historyAdded(status: addStatus));
      } else {
        emit(const EpubViewerState.historyAdded(status: -1));
      }
    } catch (error) {
      if (error is Exception) {
        emit(EpubViewerState.error(error: error.toString()));
      }
    }
  }

  Future<void> openEpubByChapter(EpubChapter item) async {
    for (final String fileName in _spineHtmlFileName!){
      if (fileName == item.ContentFileName){
        final int spineNumber = await findPageIndexInEpub(_epubBook!, fileName);
        emit(EpubViewerState.pageChanged(pageNumber: spineNumber));
      }
    }
  }

  Future<void> openEpubByName(String chapterName) async {
    for (final String fileName in _spineHtmlFileName!){
      if (fileName == chapterName){
        final int spineNumber = await findPageIndexInEpub(_epubBook!, fileName);
        emit(EpubViewerState.pageChanged(pageNumber: spineNumber));
      }
    }
  }


  Future<void> searchUsingHtmlList(String searchTerm) async {
    if (_assetPath == null || searchTerm.isEmpty || _spineHtmlContent == null) {
      return; // Ensure there is content to search and a term to search for
    }

    try {
      // Assuming searchHtmlContents expects the book title, which we stored in _bookTitle
      final List<SearchModel> results = await searchHelper.searchHtmlContents(_spineHtmlContent!, searchTerm, null, null);

      // Emit the search results to the state
      emit(EpubViewerState.searchResultsFound(searchResults: results));
    } catch (error) {
      emit(EpubViewerState.error(error: error.toString()));
    }
  }

  Future<void> highlightContent(int pageIndex, String searchTerm) async {
    if (_spineHtmlContent == null || _spineHtmlContent!.isEmpty) return;

    // Decode HTML entities and remove extra HTML tags from searchTerm
    var decodedSearchTerm = html_parser.parse(searchTerm).documentElement?.text ?? '';

    // Normalize the search term by removing diacritics
    final normalizedSearchTerm = searchHelper.removeArabicDiacritics(decodedSearchTerm);

    // Create a new list to store updated content
    final List<String> updatedContent = [];
    
    // Map to track page highlights: key = page index, value = list of highlight IDs
    final Map<int, List<String>> pageHighlights = {};
    
    // Global counter for unique IDs across all pages
    int globalCounter = 0;

    // Apply highlighting to each page content
    for (int pageIdx = 0; pageIdx < _spineHtmlContent!.length; pageIdx++) {
      final content = _spineHtmlContent![pageIdx];
      
      // Convert Latin numbers to Arabic in the content before highlighting
      final convertedContent = convertLatinNumbersToArabic(content);

      // Remove diacritics from the content for searching
      final normalizedContent = searchHelper.removeArabicDiacritics(convertedContent);

      // Get the positions of matches in the normalized content
      final highlightedContent = _applyHighlightingUsingMapping(convertedContent, normalizedContent, normalizedSearchTerm, globalCounter);

      updatedContent.add(highlightedContent);
      
      // Extract highlight IDs for this page
      final List<String> pageHighlightIds = _extractHighlightIdsFromContent(highlightedContent);
      if (pageHighlightIds.isNotEmpty) {
        pageHighlights[pageIdx] = pageHighlightIds;
      }
      
      // Update global counter by counting the actual matches found in this page
      globalCounter += _countMatchesInContent(normalizedContent, normalizedSearchTerm);
    }

    // Emit the new state with updated content and page highlights map
    emit(EpubViewerState.contentHighlighted(
      content: updatedContent, 
      highlightedIndex: pageIndex - 1,
      pageHighlights: pageHighlights
    ));
  }

  String _applyHighlightingUsingMapping(String originalContent, String normalizedContent, String normalizedSearchTerm, int globalCounter) {
    final RegExp searchRegex = RegExp(RegExp.escape(normalizedSearchTerm), caseSensitive: false);

    final List<Match> matches = searchRegex.allMatches(normalizedContent).toList();
    if (matches.isEmpty) return originalContent;

    // Create a mapping between originalContent and normalizedContent indices
    Map<int, int> indexMapping = {};
    int originalIndex = 0;
    int normalizedIndex = 0;

    while (originalIndex < originalContent.length && normalizedIndex < normalizedContent.length) {
      final originalChar = originalContent[originalIndex];
      final normalizedChar = normalizedContent[normalizedIndex];

      if (originalChar == normalizedChar) {
        // Characters match exactly - advance both indices
        indexMapping[normalizedIndex] = originalIndex;
        normalizedIndex++;
        originalIndex++;
      } else if (_isArabicDiacritic(originalChar)) {
        // Original character is a diacritic (removed in normalization) - skip it
        originalIndex++;
      } else if (_isHamzaNormalization(originalChar, normalizedChar)) {
        // Original character is a hamza form that got normalized to alef - map and advance both
        indexMapping[normalizedIndex] = originalIndex;
        normalizedIndex++;
        originalIndex++;
      } else {
        // Characters don't match and it's not a known normalization - advance original only
        originalIndex++;
      }
      originalIndex++;
    }

    String highlightedContent = originalContent;
    int offset = 0;
    int counter = globalCounter; // Use the global counter passed from parent method

    for (final match in matches) {
      if (!indexMapping.containsKey(match.start) || !indexMapping.containsKey(match.end - 1)) {
        continue; // Skip if mapping is missing
      }

      final int matchStart = indexMapping[match.start]! + offset;
      final int matchEnd = indexMapping[match.end - 1]! + 1 + offset;

      if (matchStart < 0 || matchEnd > highlightedContent.length) continue;

      // Extract the actual matched word from the original content
      final originalMatch = highlightedContent.substring(matchStart, matchEnd);

      // Find the parent block tag that contains this match
      final parentBlockTagInfo = _findParentBlockTag(highlightedContent, matchStart);
      
      if (parentBlockTagInfo != null) {
        // Add id attribute to the existing block tag
        final String blockTagWithId = _addIdToBlockTag(parentBlockTagInfo.blockTag, counter);
        
        // Replace the block tag with the one that has id
        highlightedContent = highlightedContent.replaceRange(
          parentBlockTagInfo.startIndex, 
          parentBlockTagInfo.endIndex, 
          blockTagWithId
        );
        
        // Adjust offset for the block tag change
        final int blockTagLengthDiff = blockTagWithId.length - (parentBlockTagInfo.endIndex - parentBlockTagInfo.startIndex);
        offset += blockTagLengthDiff;
        
        // Now wrap the matched text with <mark> tags
        final String markedText = '<mark>$originalMatch</mark>';
        
        // Calculate new positions after block tag modification
        final int newMatchStart = matchStart + blockTagLengthDiff;
        final int newMatchEnd = newMatchStart + originalMatch.length;
        
        // Replace the matched text with marked version
        highlightedContent = highlightedContent.replaceRange(newMatchStart, newMatchEnd, markedText);
        
        // Adjust offset for the mark tags
        final int markLengthDiff = markedText.length - originalMatch.length;
        offset += markLengthDiff;
        
        counter++; // Increment counter for next unique ID
      } else {
        // Fallback: if no parent p tag found, use the original approach
        final String replacement = '<p id="highlight_$counter" class="inline"><mark>$originalMatch</mark>';
        counter++; // Increment counter for next unique ID

        // Replace in the content
        highlightedContent = highlightedContent.replaceRange(matchStart, matchEnd, replacement);

        // Adjust offset to account for length increase due to <block> tags
        offset += replacement.length - originalMatch.length;
      }
    }

    return highlightedContent;
  }

  /// Find the parent block tag that contains the given position
  _BlockTagInfo? _findParentBlockTag(String content, int position) {
    // List of common block-level HTML tags
    final List<String> blockTags = [
      'p', 'div', 'section', 'article', 'header', 'footer', 'main', 'aside',
      'h1', 'h2', 'h3', 'h4', 'h5', 'h6', 'blockquote', 'pre', 'form',
      'table', 'ul', 'ol', 'li', 'fieldset', 'legend', 'figure', 'figcaption'
    ];
    
    int tagStart = -1;
    int tagEnd = -1;
    String? foundTagName;
    
    // Look backwards from the position to find the opening block tag
    for (int i = position; i >= 0; i--) {
      for (final tagName in blockTags) {
        if (i >= tagName.length + 1 && 
            content.substring(i - tagName.length, i + 1) == '<$tagName') {
          tagStart = i - tagName.length;
          foundTagName = tagName;
          break;
        }
      }
      if (tagStart != -1) break;
    }
    
    if (tagStart == -1 || foundTagName == null) return null;
    
    // Find the closing tag
    final String closingTag = '</$foundTagName>';
    for (int i = position; i < content.length; i++) {
      if (i + closingTag.length <= content.length && 
          content.substring(i, i + closingTag.length) == closingTag) {
        tagEnd = i + closingTag.length;
        break;
      }
    }
    
    if (tagEnd == -1) return null;
    
    final String blockTag = content.substring(tagStart, tagEnd);
    return _BlockTagInfo(blockTag, tagStart, tagEnd);
  }

  /// Add id attribute to a block tag
  String _addIdToBlockTag(String blockTag, int counter) {
    // Check if the block tag already has an id attribute
    if (blockTag.contains('id=')) {
      // If it already has an id, replace it
      return blockTag.replaceFirst(RegExp(r'id="[^"]*"'), 'id="highlight_$counter"');
    } else {
      // Find the opening tag and add id after it
      final int insertIndex = blockTag.indexOf('<') + 1;
      // Find the end of the tag name (space, >, or /)
      int tagEndIndex = insertIndex;
      while (tagEndIndex < blockTag.length && 
             blockTag[tagEndIndex] != ' ' && 
             blockTag[tagEndIndex] != '>' && 
             blockTag[tagEndIndex] != '/') {
        tagEndIndex++;
      }
      return blockTag.substring(0, tagEndIndex) + ' id="highlight_$counter"' + blockTag.substring(tagEndIndex);
    }
  }

  /// Helper method to count matches in content for updating global counter
  int _countMatchesInContent(String normalizedContent, String normalizedSearchTerm) {
    final RegExp searchRegex = RegExp(RegExp.escape(normalizedSearchTerm), caseSensitive: false);
    final matches = searchRegex.allMatches(normalizedContent);
    return matches.length;
  }

  /// Helper method to extract highlight IDs from content
  List<String> _extractHighlightIdsFromContent(String highlightedContent) {
    final RegExp highlightRegex = RegExp(r'id="highlight_(\d+)"');
    final matches = highlightRegex.allMatches(highlightedContent);
    
    final List<String> highlightIds = [];
    for (final match in matches) {
      final highlightId = 'highlight_${match.group(1)}';
      highlightIds.add(highlightId);
    }
    
    return highlightIds;
  }

  /// Helper method to get the next counter value based on the highlighted content
  int _getNextCounterValue(String highlightedContent) {
    // Find all highlight IDs in the content and get the highest number
    final RegExp highlightRegex = RegExp(r'id="highlight_(\d+)"');
    final matches = highlightRegex.allMatches(highlightedContent);
    
    int maxCounter = 0;
    for (final match in matches) {
      final counterValue = int.tryParse(match.group(1) ?? '0') ?? 0;
      if (counterValue > maxCounter) {
        maxCounter = counterValue;
      }
    }
    
    // Return the next available counter value
    return maxCounter + 1;
  }
  /// Helper method to check if a character is an Arabic diacritic
  bool _isArabicDiacritic(String char) {
    final int codeUnit = char.codeUnitAt(0);
    return (codeUnit >= 0x064B && codeUnit <= 0x065F) || // Main diacritics range
        (codeUnit >= 0x0610 && codeUnit <= 0x061A) || // Extended diacritics
        (codeUnit >= 0x06D6 && codeUnit <= 0x06DC) || // Additional diacritics
        (codeUnit >= 0x06DF && codeUnit <= 0x06E8) || // More diacritics
        (codeUnit >= 0x06EA && codeUnit <= 0x06ED);   // Final diacritics range
  }

  /// Helper method to check if original character is a hamza form that got normalized to the normalized character
  bool _isHamzaNormalization(String originalChar, String normalizedChar) {
    // Check if normalized char is alef (ا) and original is an alef-based hamza form
    if (normalizedChar == 'ا') {
      return originalChar == 'ء' ||  // hamza -> alef
          originalChar == 'آ' ||  // alef with madda -> alef
          originalChar == 'أ' ||  // alef with hamza above -> alef
          originalChar == 'إ';    // alef with hamza below -> alef
    }

    // Check if normalized char is waw (و) and original is waw with hamza (ؤ)
    if (normalizedChar == 'و' && originalChar == 'ؤ') {
      return true;  // waw with hamza -> waw
    }

    // Check if normalized char is yeh (ي) and original is yeh with hamza (ئ)
    if (normalizedChar == 'ي' && originalChar == 'ئ') {
      return true;  // yeh with hamza -> yeh
    }

    // Check if normalized char is heh (ه) and original is teh marbuta (ة)
    if (normalizedChar == 'ه' && originalChar == 'ة') {
      return true;  // teh marbuta -> heh
    }

    return false;
  }



}