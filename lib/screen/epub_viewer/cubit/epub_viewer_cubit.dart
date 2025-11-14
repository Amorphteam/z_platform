import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:epub_parser/epub_parser.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
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
  
  // Track current page for slider
  int _currentPage = 0;
  
  // UI State
  bool _isSliderVisible = true;
  bool _isSearchOpen = false;
  bool _isAboutUsBook = false;
  int _currentSearchIndex = 0;
  String _currentSearchTerm = '';
  
  // Content caching (persistent content)
  List<String> _cachedContent = [];
  String _cachedBookTitle = '';
  FontSizeCustom _cachedFontSize = FontSizeCustom.medium;
  LineHeightCustom _cachedLineHeight = LineHeightCustom.medium;
  FontFamily _cachedFontFamily = FontFamily.font1;
  Color _cachedBackgroundColor = const Color(0xFFFFFFFF);
  bool _cachedUseUniformTextColor = false;
  Color _cachedUniformTextColor = const Color(0xFF000000);
  
  // Search state
  List<String> _originalContent = []; // Store original content before highlighting
  List<SearchModel> _currentSearchResults = [];
  Map<int, List<String>> _pageHighlights = {}; // Map of page index to list of highlight IDs
  Map<int, int> _highlightIndexPerPage = {}; // Map of page index to current highlight index on that page
  
  // Debounce timer for iOS slider
  Timer? _iosSliderDebounceTimer;
  
  // History saving timer (debounced to avoid saving too frequently)
  Timer? _historySaveTimer;

  final ReferencesDatabase referencesDatabase = ReferencesDatabase.instance;
  final searchHelper = SearchHelper();
  
  // Getters for UI state
  bool get isSliderVisible => _isSliderVisible;
  bool get isSearchOpen => _isSearchOpen;
  bool get isAboutUsBook => _isAboutUsBook;
  int get currentSearchIndex => _currentSearchIndex;
  List<String> get cachedContent => _cachedContent;
  String get cachedBookTitle => _cachedBookTitle;
  FontSizeCustom get cachedFontSize => _cachedFontSize;
  LineHeightCustom get cachedLineHeight => _cachedLineHeight;
  FontFamily get cachedFontFamily => _cachedFontFamily;
  Color get cachedBackgroundColor => _cachedBackgroundColor;
  bool get useUniformTextColor => _cachedUseUniformTextColor;
  Color get cachedUniformTextColor => _cachedUniformTextColor;
  
  // Getters for book and TOC
  String? get currentBookPath => _assetPath;
  int get currentPage => _currentPage;
  List<EpubChapter>? get tocTreeList => _tocTreeList;
  
  // Getters for search
  List<SearchModel> get currentSearchResults => _currentSearchResults;
  Map<int, List<String>> get pageHighlights => _pageHighlights;
  int getHighlightIndexForPage(int pageIndex) => _highlightIndexPerPage[pageIndex] ?? 0;
  String? getCurrentHighlightId() {
    final highlights = _pageHighlights[_currentPage];
    if (highlights == null || highlights.isEmpty) return null;
    final highlightIndex = _highlightIndexPerPage[_currentPage] ?? 0;
    if (highlightIndex >= 0 && highlightIndex < highlights.length) {
      return highlights[highlightIndex];
    }
    return highlights.first;
  }


  Future<void> checkBookmark(String bookPath, String pageIndex) async {
    final bool isBookmarked = await referencesDatabase.isBookmarkExist(bookPath, pageIndex);
    emit(isBookmarked ? const EpubViewerState.bookmarkPresent() : const EpubViewerState.bookmarkAbsent());
  }

  /// Toggle bookmark - add if not exists, remove if exists
  Future<void> toggleBookmark() async {
    if (_assetPath == null || _spineHtmlContent == null) return;
    
    // Extract just the filename from the asset path (e.g., 'assets/epub/1.epub' -> '1.epub')
    final String bookPath = _assetPath!.replaceFirst('assets/epub/', '');
    final String pageIndex = _currentPage.toString();
    
    // Check if bookmark exists
    final bool isBookmarked = await referencesDatabase.isBookmarkExist(bookPath, pageIndex);
    
    if (isBookmarked) {
      // Remove bookmark
      await removeBookmark(bookPath, pageIndex);
      await checkBookmark(bookPath, pageIndex);
    } else {
      // Add bookmark
      final String? headingTitle = findPreviousHeading(_currentPage);
      final String bookmarkTitle = headingTitle ?? 'علامة مرجعية على كتاب $_cachedBookTitle';
      
      final reference = ReferenceModel(
        title: bookmarkTitle,
        bookName: _cachedBookTitle,
        bookPath: bookPath,
        navIndex: pageIndex,
      );
      
      await addBookmark(reference);
      await checkBookmark(bookPath, pageIndex);
    }
  }

  /// Find the previous heading from current page
  String? findPreviousHeading(int currentPage) {
    if (_spineHtmlContent == null || _spineHtmlContent!.isEmpty) return null;
    
    String? headingText;
    final int contentIndex = currentPage;

    // Traverse the pages backward from the current page to find the first heading
    for (int i = contentIndex; i >= 0 && i < _spineHtmlContent!.length; i--) {
      final dom.Document document = html_parser.parse(_spineHtmlContent![i]);
      final List<dom.Element> headings = document.querySelectorAll('h1, h2, h3, h4, h5, h6');

      if (headings.isNotEmpty) {
        // Check if the heading has a title attribute
        final dom.Element lastHeading = headings.last;
        final String? title = lastHeading.attributes['title'];

        if (title != null) {
          headingText = title.trim();
        } else {
          headingText = lastHeading.text.trim();
        }
        break;
      }
    }

    return headingText;
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
      
      // Cache content
      _cachedContent = _spineHtmlContent ?? [];
      _cachedBookTitle = _bookTitle ?? '';
      
      // Check if it's About Us book
      if (assetPath.contains('0.epub')) {
        _isAboutUsBook = true;
      }
      
      emit(const EpubViewerState.loading());
      await Future.delayed(const Duration(milliseconds: 200));

      emit(EpubViewerState.loaded(content: _spineHtmlContent!,
        epubTitle: _bookTitle ?? '',
        tocTreeList: _tocTreeList,),);
      
      // Wait a bit for the state handler to run and set up the jump flag
      await Future.delayed(const Duration(milliseconds: 100));
      
      // Handle post-load navigation (TOC chapter, initial page, etc.)
      await handlePostLoadNavigation();
      
      // Check bookmark after loading if we have a book path
      if (_assetPath != null && _currentPage >= 0) {
        final String bookPath = _assetPath!.replaceFirst('assets/epub/', '');
        await checkBookmark(bookPath, _currentPage.toString());
      }
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

  void changeStyle({
    FontSizeCustom? fontSize,
    LineHeightCustom? lineSpace,
    FontFamily? fontFamily,
    Color? backgroundColor,
    bool? useUniformTextColor,
    Color? uniformTextColor,
  }) {
    if (fontSize != null) {
      styleHelper.changeFontSize(fontSize);
      _cachedFontSize = fontSize;
    }
    if (lineSpace != null) {
      styleHelper.changeLineSpace(lineSpace);
      _cachedLineHeight = lineSpace;
    }
    if (fontFamily != null) {
      styleHelper.changeFontFamily(fontFamily);
      _cachedFontFamily = fontFamily;
    }
    if (backgroundColor != null) {
      styleHelper.changeBackgroundColor(backgroundColor);
      _cachedBackgroundColor = backgroundColor;
    }
    if (useUniformTextColor != null) {
      styleHelper.toggleUniformTextColor(useUniformTextColor);
      _cachedUseUniformTextColor = useUniformTextColor;
    }
    if (uniformTextColor != null) {
      styleHelper.changeUniformTextColor(uniformTextColor);
      _cachedUniformTextColor = uniformTextColor;
    }

    styleHelper.saveToPrefs();

    emit(EpubViewerState.styleChanged(
      fontSize: fontSize,
      lineHeight: lineSpace,
      fontFamily: fontFamily,
      backgroundColor: backgroundColor,
      useUniformTextColor: useUniformTextColor,
      uniformTextColor: uniformTextColor,
    ));
  }


  Future<void> jumpToPage({String? chapterFileName, int? newPage}) async {
    if (newPage != null) {
      _currentPage = newPage;
      emit(EpubViewerState.pageChanged(pageNumber: newPage));
      
      // Check bookmark after page change
      if (_assetPath != null) {
        final String bookPath = _assetPath!.replaceFirst('assets/epub/', '');
        // Debounce bookmark check to reduce database calls
        Future.delayed(const Duration(milliseconds: 500), () {
          checkBookmark(bookPath, _currentPage.toString());
        });
      }
    }
    if (chapterFileName != null) {
      try {
        final int spineNumber =
        await findPageIndexInEpub(_epubBook!, chapterFileName, useSpineOrder: true);
        _currentPage = spineNumber;
        emit(EpubViewerState.pageChanged(pageNumber: spineNumber));
      } catch (error) {
        emit(EpubViewerState.error(error: error.toString()));
      }
    }
  }

  /// Update current page from slider (for immediate UI feedback during dragging)
  void updateCurrentPageFromSlider(double page) {
    final int newPage = page.toInt();
    if (newPage != _currentPage) {
      _currentPage = newPage;
      emit(EpubViewerState.pageChanged(pageNumber: _currentPage));
    }
  }

  /// Jump to page when slider is released (Android) or after debounce (iOS)
  void jumpToPageFromSlider(double page) {
    final int targetPage = page.toInt();
    if (targetPage != _currentPage) {
      _currentPage = targetPage;
      emit(EpubViewerState.pageChanged(pageNumber: _currentPage));
    }
  }

  /// Update current page from scroll position (debounced)
  Timer? _scrollDebounceTimer;
  void updateCurrentPageFromScroll(int pageIndex) {
    if (pageIndex != _currentPage) {
      _currentPage = pageIndex;
      emit(EpubViewerState.pageChanged(pageNumber: _currentPage));
      
      // Debounce bookmark check to reduce database calls
      _scrollDebounceTimer?.cancel();
      _scrollDebounceTimer = Timer(const Duration(milliseconds: 500), () {
        if (_assetPath != null) {
          final String bookPath = _assetPath!.replaceFirst('assets/epub/', '');
          checkBookmark(bookPath, _currentPage.toString());
        }
      });
      
      // Debounce history saving (save after user stops scrolling for a bit)
      _historySaveTimer?.cancel();
      _historySaveTimer = Timer(const Duration(seconds: 2), () {
        saveCurrentHistory();
      });
    }
  }

  /// Toggle search bar visibility
  void toggleSearch(bool open) {
    _isSearchOpen = open;
    
    if (!open) {
      // Restore original content when search is closed
      if (_originalContent.isNotEmpty) {
        _cachedContent = _originalContent;
        _originalContent = [];
        _pageHighlights = {};
        _highlightIndexPerPage = {};
        // Emit loaded state with original content
        emit(EpubViewerState.loaded(
          content: _cachedContent,
          epubTitle: _cachedBookTitle,
          tocTreeList: _tocTreeList,
        ));
      } else {
        // Emit current state to trigger UI rebuild
        _emitCurrentStateForUIUpdate();
      }
    } else {
      // Emit current state to trigger UI rebuild when opening search
      _emitCurrentStateForUIUpdate();
    }
  }
  
  /// Emit current state to trigger UI rebuild (for UI-only changes like search toggle)
  void _emitCurrentStateForUIUpdate() {
    // Re-emit the current state to trigger a rebuild
    if (_cachedContent.isNotEmpty) {
      emit(EpubViewerState.loaded(
        content: _cachedContent,
        epubTitle: _cachedBookTitle,
        tocTreeList: _tocTreeList,
      ));
    } else {
      // If no content, emit pageChanged to trigger rebuild
      emit(EpubViewerState.pageChanged(pageNumber: _currentPage));
    }
  }

  /// Toggle slider visibility
  void toggleSlider(bool visible) {
    _isSliderVisible = visible;
  }

  /// Update current search index
  void updateSearchIndex(int index) {
    _currentSearchIndex = index;
  }

  /// Navigate to next search result
  void navigateToNextSearchResult(List<SearchModel> searchResults) {
    if (searchResults.isEmpty) return;
    
    final currentResult = searchResults[_currentSearchIndex];
    final currentPageIndex = currentResult.pageIndex - 1;
    final highlightsOnCurrentPage = _pageHighlights[currentPageIndex] ?? [];
    final currentHighlightIndex = _highlightIndexPerPage[currentPageIndex] ?? 0;
    
    // Check if there's a next highlight on the current page
    if (currentHighlightIndex < highlightsOnCurrentPage.length - 1) {
      // Move to next highlight on same page
      _highlightIndexPerPage[currentPageIndex] = currentHighlightIndex + 1;
      // Update current page to ensure we're tracking the right page
      _currentPage = currentPageIndex;
      // Emit pageChanged to trigger scroll to highlight (even though page number is same)
      emit(EpubViewerState.pageChanged(pageNumber: currentPageIndex));
    } else if (_currentSearchIndex < searchResults.length - 1) {
      // Move to next search result (different page)
      _currentSearchIndex++;
      highlightContent(
        searchResults[_currentSearchIndex].pageIndex,
        _currentSearchTerm,
      );
    }
  }

  /// Navigate to previous search result
  void navigateToPreviousSearchResult(List<SearchModel> searchResults) {
    if (searchResults.isEmpty) return;
    
    final currentResult = searchResults[_currentSearchIndex];
    final currentPageIndex = currentResult.pageIndex - 1;
    final currentHighlightIndex = _highlightIndexPerPage[currentPageIndex] ?? 0;
    
    // Check if there's a previous highlight on the current page
    if (currentHighlightIndex > 0) {
      // Move to previous highlight on same page
      _highlightIndexPerPage[currentPageIndex] = currentHighlightIndex - 1;
      // Update current page to ensure we're tracking the right page
      _currentPage = currentPageIndex;
      // Emit pageChanged to trigger scroll to highlight (even though page number is same)
      emit(EpubViewerState.pageChanged(pageNumber: currentPageIndex));
    } else if (_currentSearchIndex > 0) {
      // Move to previous search result (different page)
      _currentSearchIndex--;
      final previousPageIndex = searchResults[_currentSearchIndex].pageIndex - 1;
      final highlightsOnPreviousPage = _pageHighlights[previousPageIndex] ?? [];
      // Set highlight index to last highlight on previous page
      if (highlightsOnPreviousPage.isNotEmpty) {
        _highlightIndexPerPage[previousPageIndex] = highlightsOnPreviousPage.length - 1;
      }
      highlightContent(
        searchResults[_currentSearchIndex].pageIndex,
        _currentSearchTerm,
      );
    }
  }
  
  /// Navigate to a specific search result by index
  Future<void> navigateToSearchResult(int resultIndex) async {
    if (resultIndex < 0 || resultIndex >= _currentSearchResults.length) return;
    
    _currentSearchIndex = resultIndex;
    await highlightContent(
      _currentSearchResults[resultIndex].pageIndex,
      _currentSearchTerm,
    );
  }

  /// Handle iOS slider change with debounce
  void handleIOSSliderChange(double page, VoidCallback onJump) {
    updateCurrentPageFromSlider(page);
    // Cancel previous timer
    _iosSliderDebounceTimer?.cancel();
    // Debounce the jump
    _iosSliderDebounceTimer = Timer(Duration.zero, () {
      onJump();
    });
  }

  /// Cancel iOS slider debounce timer
  void cancelIOSSliderDebounce() {
    _iosSliderDebounceTimer?.cancel();
    _iosSliderDebounceTimer = null;
  }

  @override
  Future<void> close() {
    _iosSliderDebounceTimer?.cancel();
    _scrollDebounceTimer?.cancel();
    _historySaveTimer?.cancel();
    // Save history one final time before closing
    saveCurrentHistory();
    return super.close();
  }

  // Store initial navigation info for after loading
  String? _pendingChapterFileName;
  int? _pendingInitialPage;
  
  /// Initialize EPUB loading from different sources
  Future<void> initializeEpubLoading({
    String? bookPath,
    String? bookmarkPath,
    String? bookmarkFileName,
    String? historyPath,
    String? searchPath,
    String? tocPath,
    String? deepLinkPath,
    String? tocChapterFileName,
    String? deepLinkFileName,
    int? initialPage,
  }) async {
    String? pathToLoad;
    
    // Clear any pending navigation
    _pendingChapterFileName = null;
    _pendingInitialPage = null;
    
    // Determine which source to load from (priority order)
    if (bookmarkPath != null) {
      pathToLoad = bookmarkPath;
      // Store bookmark file name if provided (takes priority over initial page)
      if (bookmarkFileName != null) {
        _pendingChapterFileName = bookmarkFileName;
      }
    } else if (tocPath != null) {
      pathToLoad = tocPath;
      // Store chapter file name for TOC navigation
      if (tocChapterFileName != null) {
        _pendingChapterFileName = tocChapterFileName;
      }
    } else if (searchPath != null) {
      pathToLoad = searchPath;
    } else if (historyPath != null) {
      pathToLoad = historyPath;
    } else if (deepLinkPath != null) {
      pathToLoad = deepLinkPath;
      // Store deep link file name if provided (takes priority over initial page)
      if (deepLinkFileName != null) {
        _pendingChapterFileName = deepLinkFileName;
      }
    } else if (bookPath != null) {
      pathToLoad = bookPath;
    }
    
    // Store initial page if provided (only if no file name navigation)
    // Note: bookmarkFileName, tocChapterFileName, and deepLinkFileName all set _pendingChapterFileName
    if (initialPage != null && _pendingChapterFileName == null) {
      _pendingInitialPage = initialPage;
    }

    if (pathToLoad != null) {
      await loadAndParseEpub('assets/epub/$pathToLoad');
    }
  }
  
  /// Handle post-load navigation (called after EPUB is loaded)
  Future<void> handlePostLoadNavigation() async {
    // Handle chapter file name navigation (for TOC)
    if (_pendingChapterFileName != null) {
      await jumpToPage(chapterFileName: _pendingChapterFileName);
      _pendingChapterFileName = null;
    }
    // Handle initial page navigation (for bookmark, history, search)
    else if (_pendingInitialPage != null) {
      await jumpToPage(newPage: _pendingInitialPage);
      _pendingInitialPage = null;
    }
  }


  _saveStyleHelperToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final styleJson = styleHelper.toJson();
    prefs.setString('styleHelper', jsonEncode(styleJson));
  }

  Future<void> loadUserPreferences() async {
    StyleHelper.loadFromPrefs().then((_) {
      _cachedFontSize = styleHelper.fontSize;
      _cachedLineHeight = styleHelper.lineSpace;
      _cachedFontFamily = styleHelper.fontFamily;
      _cachedBackgroundColor = styleHelper.backgroundColor;
      _cachedUseUniformTextColor = styleHelper.useUniformTextColor;
      _cachedUniformTextColor = styleHelper.uniformTextColor;
      
      emit(EpubViewerState.styleChanged(
        fontSize: styleHelper.fontSize,
        lineHeight: styleHelper.lineSpace,
        fontFamily: styleHelper.fontFamily,
        backgroundColor: styleHelper.backgroundColor,
        useUniformTextColor: styleHelper.useUniformTextColor,
        uniformTextColor: styleHelper.uniformTextColor,
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
  
  /// Save current reading position to history
  Future<void> saveCurrentHistory() async {
    if (_assetPath == null || _cachedBookTitle.isEmpty) return;
    
    // Extract just the filename from the asset path (e.g., 'assets/epub/1.epub' -> '1.epub')
    final String bookPath = _assetPath!.replaceFirst('assets/epub/', '');
    
    // Find previous heading for history title
    final String? headingTitle = findPreviousHeading(_currentPage);
    final String historyTitle = headingTitle ?? 'علامة مرجعية على كتاب $_cachedBookTitle';
    
    final history = HistoryModel(
      title: historyTitle,
      bookName: _cachedBookTitle,
      bookPath: bookPath,
      navIndex: _currentPage.toString(),
    );
    
    await addHistory(history);
  }

  Future<void> openEpubByChapter(EpubChapter item) async {
    for (final String fileName in _spineHtmlFileName!){
      if (fileName == item.ContentFileName){
        final int spineNumber = await findPageIndexInEpub(_epubBook!, fileName);
        _currentPage = spineNumber;
        emit(EpubViewerState.pageChanged(pageNumber: spineNumber));
        
        // Check bookmark after chapter navigation
        if (_assetPath != null) {
          final String bookPath = _assetPath!.replaceFirst('assets/epub/', '');
          Future.delayed(const Duration(milliseconds: 500), () {
            checkBookmark(bookPath, _currentPage.toString());
          });
        }
      }
    }
  }

  Future<void> openEpubByName(String chapterName) async {
    for (final String fileName in _spineHtmlFileName!){
      if (fileName == chapterName){
        final int spineNumber = await findPageIndexInEpub(_epubBook!, fileName);
        _currentPage = spineNumber;
        emit(EpubViewerState.pageChanged(pageNumber: spineNumber));
        
        // Check bookmark after chapter navigation
        if (_assetPath != null) {
          final String bookPath = _assetPath!.replaceFirst('assets/epub/', '');
          Future.delayed(const Duration(milliseconds: 500), () {
            checkBookmark(bookPath, _currentPage.toString());
          });
        }
      }
    }
  }


  Future<void> searchUsingHtmlList(String searchTerm) async {
    if (_assetPath == null || searchTerm.isEmpty || _spineHtmlContent == null) {
      return; // Ensure there is content to search and a term to search for
    }

    try {
      // Store search term
      _currentSearchTerm = searchTerm;
      
      // Store original content if not already stored (first search)
      if (_originalContent.isEmpty && _cachedContent.isNotEmpty) {
        _originalContent = List<String>.from(_cachedContent);
      }
      
      // Assuming searchHtmlContents expects the book title, which we stored in _bookTitle
      final List<SearchModel> results = await searchHelper.searchHtmlContents(_spineHtmlContent!, searchTerm, null, null);

      // Store search results
      _currentSearchResults = results;
      
      // Reset search index when new results are found
      _currentSearchIndex = 0;
      _highlightIndexPerPage.clear();

      // Emit the search results to the state
      emit(EpubViewerState.searchResultsFound(searchResults: results));
      
      // Auto-highlight first result if available
      if (results.isNotEmpty) {
        await highlightContent(results[0].pageIndex, searchTerm);
      }
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

    // Store page highlights
    _pageHighlights = pageHighlights;
    
    // Reset highlight index for the target page
    final targetPageIndex = pageIndex - 1;
    _highlightIndexPerPage[targetPageIndex] = 0;
    
    // Update current page if needed
    if (_currentPage != targetPageIndex) {
      _currentPage = targetPageIndex;
    }

    // Cache highlighted content
    _cachedContent = updatedContent;

    // Emit the new state with updated content and page highlights map
    emit(EpubViewerState.contentHighlighted(
        content: updatedContent,
        highlightedIndex: targetPageIndex,
        pageHighlights: pageHighlights
    ));
  }

  String _applyHighlightingUsingMapping(String originalContent, String normalizedContent, String normalizedSearchTerm, int globalCounter) {
    final RegExp searchRegex = RegExp(RegExp.escape(normalizedSearchTerm), caseSensitive: false);

    final List<Match> matches = searchRegex.allMatches(normalizedContent).toList();
    if (matches.isEmpty) return originalContent;

    // Create a mapping between originalContent and normalizedContent indices
    // This enhanced mapping handles both character removals (diacritics) and replacements (hamza normalization)
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