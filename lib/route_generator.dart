import 'dart:io';
import 'package:epub_search/epub_search.dart' as epub_search_package;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:epub_viewer/epub_viewer.dart' as epub_viewer;
import 'package:epub_bookmarks/epub_bookmarks.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:masaha/screen/chat/chat_screen.dart';
import 'package:masaha/screen/chat/cubit/chat_cubit.dart';
import 'package:masaha/screen/host/cubit/host_cubit.dart';
import 'package:masaha/screen/host/host_screen.dart';
import 'package:masaha/screen/color_palette/color_palette_screen.dart';
import 'package:masaha/screen/color_picker/color_picker_screen.dart';
import 'package:masaha/screen/liquid_glass_test/liquid_glass_test_screen.dart';
import 'model/book_model.dart';
import 'model/deep_link_model.dart';
import 'model/history_model.dart';
import 'model/reference_model.dart';
import 'model/search_model.dart' as host_search;
import 'model/tree_toc_model.dart';
import 'repository/hostory_database.dart';
import 'repository/reference_database.dart';
import 'repository/json_repository.dart';
import 'util/constants.dart';
import 'util/page_helper.dart';
import 'util/epub_helper.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>?;
    final isIOS = Platform.isIOS;

    switch (settings.name) {
      case '/':
        return _buildRoute(
          isIOS: isIOS,
          builder: (context) =>
              BlocProvider(
                create: (context) => HostCubit(),
                child: HostScreen(),
              ),
        );
      case '/epubViewer':
        if (args != null) {
          final epub_viewer.EpubViewerEntryData? providedEntryData =
          args['entryData'] as epub_viewer.EpubViewerEntryData?;
          final bool enableContentCache = args['enableContentCache'] is bool
              ? args['enableContentCache'] as bool
              : true;
          final Book? cat = args['cat'];
          final ReferenceModel? reference = args['reference'];
          final HistoryModel? history = args['history'];
          final EpubChaptersWithBookPath? toc = args['toc'];
          final host_search.SearchModel? search = args['search'];
          final DeepLinkModel? deepLink = args['deepLink'];
          // Support legacy fileName parameter for backward compatibility
          final String? fileName = args['fileName'];

          // Create DeepLinkModel from legacy fileName if needed
          DeepLinkModel? deepLinkModel = deepLink;
          if (deepLinkModel == null && fileName != null && reference != null) {
            deepLinkModel = DeepLinkModel(
              fileName: fileName,
              epubName: reference.bookPath,
              epubIndex: null,
            );
          }

          final epub_viewer.EpubViewerEntryData entryData = providedEntryData ??
              epub_viewer.EpubViewerEntryData(
                primaryBookPath: cat?.epub,
                bookmarkBookPath: reference?.bookPath,
                bookmarkFileName: reference?.fileName,
                bookmarkPageIndex: reference?.navIndex,
                historyBookPath: history?.bookPath,
                historyPageIndex: history?.navIndex,
                searchBookPath: search?.bookAddress,
                searchPageIndex: search?.pageIndex,
                searchQuery: search?.searchedWord,
                tocBookPath: toc?.bookPath,
                tocChapterFileName: toc?.epubChapter.ContentFileName,
                deepLinkBookPath: deepLinkModel?.epubName,
                deepLinkPageIndex: deepLinkModel?.epubIndex,
                deepLinkChapterFileName: deepLinkModel?.fileName,
              );

          return _buildRoute(
            isIOS: isIOS,
            builder: (context) =>
                BlocProvider(
                  create: (context) =>
                      epub_viewer.EpubViewerCubit(
                        persistence: _createEpubViewerPersistence(),
                      ),
                  child: epub_viewer.EpubViewerScreenV2(
                    entryData: entryData,
                    enableContentCache: enableContentCache,
                    onBookmarksChanged: () async {
                      try {
                        final bookmarkCubit = context.read<BookmarkCubit>();
                        bookmarkCubit.loadAllBookmarks();
                      } catch (_) {
                        // BookmarkCubit not available in ancestor tree – ignore.
                      }
                    },
                    onAnchorIdTap: (ctx, anchorId) async {
                      // anchorId already includes '#', e.g. "#note_12"
                      // 1) query your DB using anchorId as filter
                      final data = 'await myRepository.loadByAnchor(anchorId)';

                      // 2) show bottom sheet for this app
                      if (!ctx.mounted) return;
                      showModalBottomSheet(
                        context: ctx,
                        isScrollControlled: true,
                        builder: (_) =>
                            Container(
                              padding: EdgeInsets.all(20),
                              height: 600,
                              width: double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(anchorId)
                                ],
                              ),
                            ),
                      );
                    },
                    onTranslatePressed: (ctx, {
                      required pageNumber,
                      required sectionName,
                      required bookName,
                      required bookPath
                    }) {
                      showModalBottomSheet(
                        context: ctx,
                        isScrollControlled: true,
                        builder: (_) =>
                            Container(
                              padding: EdgeInsets.all(20),
                              height: 600,
                              width: double.infinity,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('''
                          کتاب $bookName 
                          عنوان $bookPath
                          الصفحة${pageNumber + 1}
                          '''),
                                ],
                              ),
                            ),
                      );
                    },


                  ),
                ),
          );
        }
        return _errorRoute();
      case '/bookmarkScreen':
        return _buildRoute(
          isIOS: isIOS,
          builder: (context) =>
              BookmarkScreen(
                persistence: _createBookmarkPersistence(),
                appBar: BookmarkAppBar(
                  title: 'منصة مساحة',
                ),
                onBookmarkTap: (screenContext, bookmark) async {
                  final reference = ReferenceModel(
                    id: bookmark.id,
                    title: bookmark.title,
                    bookName: bookmark.bookName,
                    bookPath: bookmark.bookPath,
                    navIndex: bookmark.pageIndex,
                    fileName: bookmark.fileName,
                  );
                  await openEpub(context: screenContext, reference: reference);
                },
                onHistoryTap: (screenContext, history) async {
                  final historyModel = HistoryModel(
                    id: history.id,
                    title: history.title,
                    bookName: history.bookName,
                    bookPath: history.bookPath,
                    navIndex: history.pageIndex,
                  );
                  await openEpub(context: screenContext, history: historyModel);
                },
              ),
        );
      case '/colorPalette':
        return _buildRoute(
          isIOS: isIOS,
          builder: (context) => const ColorPaletteScreen(),
        );
      case '/colorPicker':
        return _buildRoute(
          isIOS: isIOS,
          builder: (context) => const ColorPickerScreen(),
        );
      case '/chat':
        return _buildRoute(
          isIOS: isIOS,
          builder: (context) {
            final chatCubit = ChatCubit();
            // Initialize AI service with API key
            chatCubit.apiKey = Constants.openAIApiKey;
            return BlocProvider(
              create: (context) => chatCubit,
              child: const ChatScreen(),
            );
          },
        );
      case '/liquidGlassTest':
        return _buildRoute(
          isIOS: isIOS,
          builder: (context) => const LiquidGlassTestScreen(),
        );
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _buildRoute({
    required bool isIOS,
    required WidgetBuilder builder,
  }) {
    // Use MaterialWithModalsPageRoute to support iOS-style modal bottom sheets
    return MaterialWithModalsPageRoute(
      builder: builder,
    );
  }

  static Route _errorRoute() =>
      MaterialPageRoute(
        builder: (_) =>
        const Scaffold(
          body: Center(child: Text('Error: Page not found')),
        ),
      );

  static epub_viewer.EpubViewerPersistence _createEpubViewerPersistence() {
    return epub_viewer.EpubViewerPersistence(
      bookmarkDataSource: _BookmarkDataSource(),
      historyDataSource: _HistoryDataSource(),
      searchService: epub_viewer.DefaultSearchService(),
      pageProgressStore: _PageProgressStore(),
    );
  }

  static BookmarkPersistence _createBookmarkPersistence() {
    return BookmarkPersistence(
      bookmarkDataSource: _AppBookmarkDataSource(),
      historyDataSource: _AppHistoryDataSource(),
    );
  }

  static epub_search_package.SearchPersistence _createSearchPersistence() {
    return epub_search_package.SearchPersistence(
      bookDataSource: _AppBookDataSource(),
      recentSearchesDataSource: _AppRecentSearchesDataSource(),
    );
  }

  // Public method to create persistence (for use in host_screen)
  static BookmarkPersistence createBookmarkPersistence() {
    return _createBookmarkPersistence();
  }

  static epub_search_package.SearchPersistence createSearchPersistence() {
    return _createSearchPersistence();
  }

}

class _BookmarkDataSource implements epub_viewer.BookmarkDataSource {
  final ReferencesDatabase _referencesDatabase = ReferencesDatabase.instance;

  @override
  Future<bool> isBookmarked(String bookPath, String pageIndex) {
    return _referencesDatabase.isBookmarkExist(bookPath, pageIndex);
  }

  @override
  Future<void> removeBookmark(String bookPath, String pageIndex) {
    return _referencesDatabase.deleteReferenceByBookPathAndPageNumber(
        bookPath, pageIndex);
  }

  @override
  Future<bool> saveBookmark(epub_viewer.EpubBookmark bookmark) async {
    final existing = await _referencesDatabase.getReferenceByBookTitleAndPage(
        bookmark.bookPath, bookmark.pageIndex);
    if (existing.isNotEmpty) {
      return false;
    }
    final reference = ReferenceModel(
      title: bookmark.title,
      bookName: bookmark.bookName,
      bookPath: bookmark.bookPath,
      navIndex: bookmark.pageIndex,
      fileName: bookmark.fileName,
    );
    final result = await _referencesDatabase.addReference(reference);
    return result != 0;
  }
}

class _HistoryDataSource implements epub_viewer.HistoryDataSource {
  final HistoryDatabase _historyDatabase = HistoryDatabase.instance;

  @override
  Future<bool> saveHistory(epub_viewer.EpubHistoryEntry historyEntry) async {
    final existing = await _historyDatabase.getHistoryByBookTitleAndPage(
        historyEntry.bookPath, historyEntry.pageIndex);
    if (existing.isNotEmpty) {
      return false;
    }
    final history = HistoryModel(
      title: historyEntry.title,
      bookName: historyEntry.bookName,
      bookPath: historyEntry.bookPath,
      navIndex: historyEntry.pageIndex,
    );
    final result = await _historyDatabase.addHistory(history);
    return result != 0;
  }
}

class _PageProgressStore implements epub_viewer.PageProgressStore {
  final PageHelper _pageHelper = PageHelper();

  @override
  Future<double?> loadLastPage(String bookPath) {
    return _pageHelper.getLastPageNumberForBook(bookPath);
  }

  @override
  Future<void> saveLastPage(String bookPath, double pageIndex) {
    return _pageHelper.saveBookData(bookPath, pageIndex);
  }
}

class _AppBookmarkDataSource implements BookmarkDataSource {
  final ReferencesDatabase _database = ReferencesDatabase.instance;

  @override
  Future<List<Bookmark>> getAllBookmarks() async {
    final references = await _database.getAllReferences();
    return references.map((reference) =>
        Bookmark(
          id: reference.id,
          title: reference.title,
          bookName: reference.bookName,
          bookPath: reference.bookPath,
          pageIndex: reference.navIndex,
          fileName: reference.fileName,
        )).toList();
  }

  @override
  Future<void> deleteBookmark(int id) async {
    await _database.deleteReference(id);
  }

  @override
  Future<void> clearAllBookmarks() async {
    await _database.clearAllReferences();
  }

  @override
  Future<bool> isBookmarked(String bookPath, String pageIndex) async {
    return await _database.isBookmarkExist(bookPath, pageIndex);
  }

  @override
  Future<List<Bookmark>> filterBookmarks(String query) async {
    final references = await _database.getFilterReference(query);
    return references.map((reference) =>
        Bookmark(
          id: reference.id,
          title: reference.title,
          bookName: reference.bookName,
          bookPath: reference.bookPath,
          pageIndex: reference.navIndex,
          fileName: reference.fileName,
        )).toList();
  }
}

class _AppHistoryDataSource implements HistoryDataSource {
  final HistoryDatabase _database = HistoryDatabase.instance;

  @override
  Future<List<History>> getAllHistory() async {
    final historyList = await _database.getAllHistory();
    return historyList.map((history) =>
        History(
          id: history.id,
          title: history.title,
          bookName: history.bookName,
          bookPath: history.bookPath,
          pageIndex: history.navIndex,
        )).toList();
  }

  @override
  Future<void> deleteHistory(int id) async {
    await _database.deleteHistory(id);
  }

  @override
  Future<void> clearAllHistory() async {
    await _database.clearAllHistory();
  }
}

class _AppBookDataSource implements epub_search_package.BookDataSource {
  final JsonRepository _repository = JsonRepository();

  @override
  Future<List<epub_search_package.Book>> getBooks() async {
    final books = await _repository.loadEpubFromJson();
    return books.map((book) => epub_search_package.Book(
      title: book.title,
      author: book.author,
      description: book.description,
      image: book.image,
      epub: book.epub,
      series: book.series?.map((s) => epub_search_package.Series(
        title: s.title,
        description: s.description,
        image: s.image,
        epub: s.epub,
      )).toList(),
    )).toList();
  }
}

class _AppRecentSearchesDataSource implements epub_search_package.RecentSearchesDataSource {
  static const String _key = 'recent_searches';
  static const int _maxRecentSearches = 10;

  @override
  Future<List<String>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList(_key) ?? [];
    return searches;
  }

  @override
  Future<void> saveRecentSearches(List<String> searches) async {
    final prefs = await SharedPreferences.getInstance();
    // Limit to max items
    final limitedSearches = searches.length > _maxRecentSearches
        ? searches.sublist(0, _maxRecentSearches)
        : searches;
    await prefs.setStringList(_key, limitedSearches);
  }

  @override
  Future<void> addRecentSearch(String term) async {
    if (term.trim().isEmpty) return;
    
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList(_key) ?? [];
    
    // Remove if already exists
    searches.remove(term);
    
    // Add to beginning
    searches.insert(0, term);
    
    // Keep only max items
    if (searches.length > _maxRecentSearches) {
      searches.removeRange(_maxRecentSearches, searches.length);
    }
    
    await prefs.setStringList(_key, searches);
  }

  @override
  Future<void> removeRecentSearch(String term) async {
    final prefs = await SharedPreferences.getInstance();
    final searches = prefs.getStringList(_key) ?? [];
    searches.remove(term);
    await prefs.setStringList(_key, searches);
  }
}

