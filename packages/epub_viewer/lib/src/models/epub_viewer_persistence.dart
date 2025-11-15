import 'search_model.dart';

/// Represents a bookmark entry used by the EPUB viewer.
class EpubBookmark {
  const EpubBookmark({
    required this.title,
    required this.bookName,
    required this.bookPath,
    required this.pageIndex,
    this.fileName,
  });

  final String title;
  final String bookName;
  final String bookPath;
  final String pageIndex;
  final String? fileName;
}

/// Represents a history entry for tracking last-read locations.
class EpubHistoryEntry {
  const EpubHistoryEntry({
    required this.title,
    required this.bookName,
    required this.bookPath,
    required this.pageIndex,
  });

  final String title;
  final String bookName;
  final String bookPath;
  final String pageIndex;
}

/// Abstraction over bookmark persistence.
abstract class BookmarkDataSource {
  Future<bool> isBookmarked(String bookPath, String pageIndex);
  Future<bool> saveBookmark(EpubBookmark bookmark);
  Future<void> removeBookmark(String bookPath, String pageIndex);
}

/// Abstraction over reading history persistence.
abstract class HistoryDataSource {
  Future<bool> saveHistory(EpubHistoryEntry historyEntry);
}

/// Abstraction over search functionality.
abstract class SearchService {
  Future<List<SearchModel>> searchHtmlContents(List<String> htmlPages, String searchTerm);
  String removeArabicDiacritics(String input);
}

/// Abstraction over storing/restoring last read page.
abstract class PageProgressStore {
  Future<void> saveLastPage(String bookPath, double pageIndex);
  Future<double?> loadLastPage(String bookPath);
}

/// Container for all persistence/search dependencies needed by the viewer cubit.
class EpubViewerPersistence {
  const EpubViewerPersistence({
    required this.bookmarkDataSource,
    required this.historyDataSource,
    required this.searchService,
    required this.pageProgressStore,
  });

  final BookmarkDataSource bookmarkDataSource;
  final HistoryDataSource historyDataSource;
  final SearchService searchService;
  final PageProgressStore pageProgressStore;
}

