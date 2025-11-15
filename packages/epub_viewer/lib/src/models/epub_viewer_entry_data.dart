class EpubViewerEntryData {
  const EpubViewerEntryData({
    this.primaryBookPath,
    this.bookmarkBookPath,
    this.bookmarkFileName,
    this.bookmarkPageIndex,
    this.historyBookPath,
    this.historyPageIndex,
    this.searchBookPath,
    this.searchPageIndex,
    this.searchQuery,
    this.tocBookPath,
    this.tocChapterFileName,
    this.deepLinkBookPath,
    this.deepLinkPageIndex,
    this.deepLinkChapterFileName,
  });

  /// Direct path to the EPUB source (e.g. book epub file id)
  final String? primaryBookPath;

  /// Bookmark specific info
  final String? bookmarkBookPath;
  final String? bookmarkFileName;
  final String? bookmarkPageIndex;

  /// History info
  final String? historyBookPath;
  final String? historyPageIndex;

  /// Search info
  final String? searchBookPath;
  final int? searchPageIndex;
  final String? searchQuery;

  /// TOC info
  final String? tocBookPath;
  final String? tocChapterFileName;

  /// Deep link info
  final String? deepLinkBookPath;
  final int? deepLinkPageIndex;
  final String? deepLinkChapterFileName;
}

