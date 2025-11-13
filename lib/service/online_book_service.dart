import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:masaha/model/book_page_model.dart';
import 'package:masaha/util/epub_helper.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

/// Service to fetch and cache online book pages
class OnlineBookService {
  static final OnlineBookService _instance = OnlineBookService._internal();
  factory OnlineBookService() => _instance;
  OnlineBookService._internal();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://api.masaha.org',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  ));

  /// Fetch book pages from API
  Future<List<BookPageModel>> fetchBookPages({
    required int bookId,
    int page = 1,
    int perPage = 700,
  }) async {
    try {
      debugPrint('Fetching book pages: bookId=$bookId, page=$page, perPage=$perPage');
      
      final response = await _dio.get(
        '/api/book/$bookId/get-pages',
        queryParameters: {
          'page': page,
          'per-page': perPage,
        },
      );

      if (response.statusCode == 200) {
        try {
          final bookPagesResponse = BookPagesResponse.fromJson(response.data);
          if (bookPagesResponse.success) {
            debugPrint('Fetched ${bookPagesResponse.data.records.length} pages');
            return bookPagesResponse.data.records;
          } else {
            throw Exception('API returned success=false');
          }
        } catch (e) {
          debugPrint('Error parsing API response: $e');
          debugPrint('Response data: ${response.data}');
          rethrow;
        }
      } else {
        throw Exception('Failed to fetch book pages: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching book pages: $e');
      rethrow;
    }
  }

  /// Convert online book pages to HtmlFileInfo format (compatible with offline EPUB)
  List<HtmlFileInfo> convertToHtmlFileInfo(
    List<BookPageModel> pages,
    String bookTitle,
  ) {
    final List<HtmlFileInfo> htmlContentList = [];
    
    for (int i = 0; i < pages.length; i++) {
      final page = pages[i];
      // Use page number as file name for consistency
      final fileName = 'page_${page.pageNum}.html';
      // Page index is 0-based for scrolling
      htmlContentList.add(
        HtmlFileInfo(
          fileName,
          page.text,
          i, // pageIndex for scrolling
        ),
      );
    }
    
    return htmlContentList;
  }

  /// Cache book pages locally for offline access
  Future<void> cacheBookPages({
    required int bookId,
    required List<BookPageModel> pages,
  }) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final cacheFile = File('${cacheDir.path}/book_${bookId}_pages.json');
      
      final jsonData = {
        'bookId': bookId,
        'cachedAt': DateTime.now().toIso8601String(),
        'pages': pages.map((p) => p.toJson()).toList(),
      };
      
      await cacheFile.writeAsString(jsonEncode(jsonData));
      debugPrint('Cached ${pages.length} pages for book $bookId');
    } catch (e) {
      debugPrint('Error caching book pages: $e');
    }
  }

  /// Load cached book pages
  Future<List<BookPageModel>?> loadCachedPages(int bookId) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final cacheFile = File('${cacheDir.path}/book_${bookId}_pages.json');
      
      if (await cacheFile.exists()) {
        final jsonString = await cacheFile.readAsString();
        final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
        
        final pages = (jsonData['pages'] as List)
            .map((p) => BookPageModel.fromJson(p as Map<String, dynamic>))
            .toList();
        
        debugPrint('Loaded ${pages.length} cached pages for book $bookId');
        return pages;
      }
    } catch (e) {
      debugPrint('Error loading cached pages: $e');
    }
    return null;
  }

  /// Check if book is cached
  Future<bool> isBookCached(int bookId) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final cacheFile = File('${cacheDir.path}/book_${bookId}_pages.json');
      return await cacheFile.exists();
    } catch (e) {
      return false;
    }
  }

  /// Get cache directory
  Future<Directory> _getCacheDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final cacheDir = Directory('${appDir.path}/book_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  /// Clear cache for a specific book
  Future<void> clearBookCache(int bookId) async {
    try {
      final cacheDir = await _getCacheDirectory();
      final cacheFile = File('${cacheDir.path}/book_${bookId}_pages.json');
      if (await cacheFile.exists()) {
        await cacheFile.delete();
        debugPrint('Cleared cache for book $bookId');
      }
    } catch (e) {
      debugPrint('Error clearing cache: $e');
    }
  }
}

