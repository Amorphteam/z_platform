import 'dart:async';
import 'dart:isolate';

import 'package:epub_parser/epub_parser.dart';
import 'package:html/parser.dart' show parse;

import '../model/epubBookLocal.dart';
import '../model/search_model.dart';
import 'epub_helper.dart';
import 'arabic_text_helper.dart';

class SearchHelper {

  // Factory constructor
  factory SearchHelper() => _instance;

  // Private constructor
  SearchHelper._internal();
  // Singleton instance
  static final SearchHelper _instance = SearchHelper._internal();

  final int searchSurroundCharNum = 40;
  bool _isSearchStopped = false;


  Future<void> searchAllBooks(
    List<EpubBookLocal> allBooks, 
    String word, 
    Function(List<SearchModel>) onPartialResults,
    [int? maxResultsPerBook]
  ) async {
    final receivePort = ReceivePort();
    await Isolate.spawn(_searchAllBooks, SearchTask(allBooks, word, receivePort.sendPort, maxResultsPerBook));

    await for (final message in receivePort) {
      if (message is List<SearchModel>) {
        onPartialResults(message);
      } else if (message is String && message == 'done') {
        break;
      } else if (message is SendPort) {
        message.send(null);
      }
    }
  }

  String removeArabicDiacritics(String text) {
    // Use the enhanced Arabic text normalization
    return ArabicTextHelper.normalizeArabicText(text);
  }

  Future<void> _searchAllBooks(SearchTask task) async {
    final port = ReceivePort();
    task.sendPort.send(port.sendPort);

    final List<SearchModel> allResults = [];

    for (final epubBook in task.allBooks) {
      if (_isSearchStopped) break;

      final bookName = epubBook.epubBook?.Title;
      final bookAddress = epubBook.bookPath;
      final List<HtmlFileInfo> epubContent = await extractHtmlContentWithEmbeddedImages(epubBook.epubBook!);

      final spineItems = epubBook.epubBook?.Schema?.Package?.Spine?.Items;
      final List<String> idRefs = [];

      if (spineItems != null) {
        for (final item in spineItems) {
          if (item.IdRef != null) {
            idRefs.add(item.IdRef!);
          }
        }
      }

      final epubNewContent = reorderHtmlFilesBasedOnSpine(epubContent, idRefs);
      final spineHtmlContent = epubNewContent.map((info) => info.modifiedHtmlContent).toList();

      final result = await searchHtmlContents(
        spineHtmlContent, 
        task.word, 
        bookName, 
        bookAddress,
        task.maxResultsPerBook
      );

      allResults.addAll(result);
      task.sendPort.send(List<SearchModel>.from(allResults));
    }

    task.sendPort.send('done');
  }


  Future<List<SearchModel>> _searchSingleBook(String bookPath, String sw, EpubBook? epub, [List<HtmlFileInfo>? spineFile]) async {
    spineFile ??= [];

    final List<SearchModel> tempResult = [];
    EpubBook epubBook;
    List<HtmlFileInfo> spine;
    try {
      if (spineFile.isEmpty || epub == null) {
        epubBook = await loadEpubFromAsset(bookPath);
        spine = await extractHtmlContentWithEmbeddedImages(epubBook);
      } else {
        spine = spineFile;
        epubBook = epub;
      }
      final spineHtmlContent = spine.map((info) => info.modifiedHtmlContent).toList();
      final spineHtmlFileName = spine.map((info) => info.fileName).toList();
      final spineHtmlIndex = spine.map((info) => info.pageIndex).toList();

      for (int i = 0; i < spineHtmlContent.length; i++) {
        final page = _removeHtmlTags(spineHtmlContent[i]);
        var searchIndex = _searchInString(page, sw, 0);
        while (searchIndex.startIndex >= 0) {
          tempResult.add(SearchModel(
            searchedWord: sw,
            pageIndex: spineHtmlIndex[i],
            bookAddress: bookPath,
            bookTitle: epubBook.Title,
            pageId: spineHtmlFileName[i],
            searchCount: tempResult.length + 1, // Updated to directly use the length of tempResult for search count
            spanna: _getHighlightedSection(searchIndex, page),
          ),);

          searchIndex = _searchInString(page, sw, searchIndex.lastIndex + 1);
        }
      }
    } catch (e) {
      print('error in parsing epub: ${e.toString()}');
    }

    return tempResult;
  }

  Future<List<SearchModel>> searchHtmlContents(
    List<String> htmlContents, 
    String searchWord, 
    String? bookName, 
    String? bookAddress,
    [int? maxResultsPerBook]
  ) async {
    final List<SearchModel> results = [];
    final normalizedSearchWord = ArabicTextHelper.normalizeArabicText(searchWord);
    int bookResultCount = 0;

    for (int i = 0; i < htmlContents.length && (maxResultsPerBook == null || bookResultCount < maxResultsPerBook); i++) {
      final String pageContent = _removeHtmlTags(htmlContents[i]);
      SearchIndex searchIndex = _searchInString(pageContent, normalizedSearchWord, 0);

      while (searchIndex.startIndex >= 0 && (maxResultsPerBook == null || bookResultCount < maxResultsPerBook)) {
        results.add(SearchModel(
          pageIndex: i + 1,
          searchedWord: searchWord,
          searchCount: results.length + 1,
          spanna: _getHighlightedSection(searchIndex, pageContent),
          bookAddress: bookAddress,
          bookTitle: bookName,
        ));

        bookResultCount++;
        if (maxResultsPerBook != null && bookResultCount >= maxResultsPerBook) break;

        searchIndex = _searchInString(pageContent, normalizedSearchWord, searchIndex.lastIndex + 1);
      }
    }

    return results;
  }


  String _getHighlightedSection(SearchIndex index, String wholeString) {
    final sw = wholeString.substring(index.startIndex, index.lastIndex);
    final swLength = index.lastIndex - index.startIndex;
    final lastIndex = wholeString.length;
    final firstCutIndex = index.startIndex - searchSurroundCharNum > 0 ? index.startIndex - searchSurroundCharNum : 0;
    final lastCutIndex = index.lastIndex + searchSurroundCharNum > lastIndex ? lastIndex : index.lastIndex + searchSurroundCharNum;
    final surr1 = '...${wholeString.substring(firstCutIndex, index.startIndex)}';
    final surr2 = '${wholeString.substring(index.lastIndex, lastCutIndex)}...';
    return '$surr1<mark>$sw</mark>$surr2';
  }

  SearchIndex _searchInString(String pageString, String sw, int start) {
    // Use enhanced Arabic text normalization for both text and search query
    final normalizedPage = ArabicTextHelper.normalizeArabicText(pageString);
    final normalizedSearchWord = ArabicTextHelper.normalizeArabicText(sw);

    final startIndex = normalizedPage.indexOf(normalizedSearchWord, start);
    return startIndex >= 0 ? SearchIndex(startIndex, startIndex + normalizedSearchWord.length) : SearchIndex(-1, -1);
  }

  Future<void> stopSearch(bool stop) async {
    _isSearchStopped = stop;
  }

  String _removeHtmlTags(String htmlString) {
    final text = parse(htmlString).documentElement!.text;
    return ArabicTextHelper.normalizeArabicText(text); // Enhanced Arabic text normalization
  }

  Future<List<SearchModel>> searchSingleBook(
    String bookPath, 
    String searchWord, 
    EpubBook? epubBook,
    [int? maxResultsPerBook]
  ) async {
    final List<SearchModel> results = [];
    final normalizedSearchWord = ArabicTextHelper.normalizeArabicText(searchWord);
    int bookResultCount = 0;

    try {
      final List<HtmlFileInfo> spine = await extractHtmlContentWithEmbeddedImages(epubBook!);
      final spineHtmlContent = spine.map((info) => info.modifiedHtmlContent).toList();
      final spineHtmlFileName = spine.map((info) => info.fileName).toList();
      final spineHtmlIndex = spine.map((info) => info.pageIndex).toList();

      for (int i = 0; i < spineHtmlContent.length && (maxResultsPerBook == null || bookResultCount < maxResultsPerBook); i++) {
        final String pageContent = _removeHtmlTags(spineHtmlContent[i]);
        SearchIndex searchIndex = _searchInString(pageContent, normalizedSearchWord, 0);

        while (searchIndex.startIndex >= 0 && (maxResultsPerBook == null || bookResultCount < maxResultsPerBook)) {
          results.add(SearchModel(
            pageIndex: spineHtmlIndex[i],
            searchedWord: searchWord,
            searchCount: results.length + 1,
            spanna: _getHighlightedSection(searchIndex, pageContent),
            bookAddress: bookPath,
            bookTitle: epubBook.Title,
            pageId: spineHtmlFileName[i],
          ));

          bookResultCount++;
          if (maxResultsPerBook != null && bookResultCount >= maxResultsPerBook) break;

          searchIndex = _searchInString(pageContent, normalizedSearchWord, searchIndex.lastIndex + 1);
        }
      }
    } catch (e) {
      print('Error searching in book: ${e.toString()}');
    }

    return results;
  }
}

class SearchIndex {

  SearchIndex(this.startIndex, this.lastIndex);
  final int startIndex;
  final int lastIndex;
}


class SearchTask {

  SearchTask(this.allBooks, this.word, this.sendPort, [this.maxResultsPerBook]);
  final List<EpubBookLocal> allBooks;
  final String word;
  final SendPort sendPort;
  final int? maxResultsPerBook;
}

const MAX_RESULTS_PER_BOOK = 10;