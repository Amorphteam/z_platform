import 'package:zahra/database/database_helper.dart';
import 'package:zahra/model/hekam.dart';
import 'package:zahra/model/occasion.dart';
import 'package:zahra/model/onscreen.dart';
import 'package:zahra/model/word.dart';

import '../model/translate_khotab.dart';

class DatabaseRepository {
  final DatabaseHelper _dbHelper;

  DatabaseRepository({DatabaseHelper? dbHelper}) : _dbHelper = dbHelper ?? DatabaseHelper();

  // Hekam operations
  Future<Hekam?> getHekamById(int id) async {
    try {
      final results = await _dbHelper.getHekamById(id);
      if (results.isEmpty) return null;
      return Hekam.fromJson(results.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Hekam>> getAllHekam() async {
    try {
      final results = await _dbHelper.getHekam();
      return results.map((map) => Hekam.fromJson(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> toggleFavorite(int id) async {
    try {
      final hekam = await getHekamById(id);
      if (hekam != null) {
        await _dbHelper.updateHekamFavorite(id, !hekam.isFavorite);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Occasion>> getOccasionsByDate(int day, int month) async {
    try {
      final results = await _dbHelper.getOccasionsByDate(day, month);
      return results.map((map) => Occasion.fromJson(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Onscreen?> getRandomOnscreenText() async {
    try {
      final result = await _dbHelper.getRandomOnscreenText();
      print('result is ${result.toString()}');
      if (result == null) return null;
      
      // Ensure text_ar is not null
      if (result['text_ar'] == null) {
        print('Warning: text_ar is null in database result');
        return null;
      }
      
      try {
        return Onscreen.fromJson(result);
      } catch (e) {
        print('Error parsing Onscreen from JSON: $e');
        print('JSON data: $result');
        return null;  // Return null instead of rethrowing
      }
    } catch (e) {
      print('Error in getRandomOnscreenText: $e');
      return null;  // Return null instead of rethrowing
    }
  }

  // Word operations
  Future<Word?> getWordById(int id) async {
    try {
      final results = await _dbHelper.getWordById(id);
      if (results.isEmpty) return null;
      return Word.fromJson(results.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Word>> getAllWords() async {
    try {
      final results = await _dbHelper.getWords();
      return results.map((map) => Word.fromJson(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Word>> searchWords(String query) async {
    try {
      final results = await _dbHelper.searchWords(query);
      return results.map((map) => Word.fromJson(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Translation operations
  Future<Translate?> getKhotabTranslation(int mainId) async {
    try {
      final results = await _dbHelper.getKhotabTranslation(mainId);
      if (results.isEmpty) return null;
      return Translate.fromJson(results.first);
    } catch (e) {
      rethrow;
    }
  }

  Future<Translate?> getLettersTranslation(int mainId) async {
    try {
      final results = await _dbHelper.getLettersTranslation(mainId);
      if (results.isEmpty) return null;
      return Translate.fromJson(results.first);
    } catch (e) {
      rethrow;
    }
  }

  // Add more table operations here as needed
  // For example:
  // Future<List<Category>> getAllCategories() async { ... }
  // Future<Book?> getBookById(int id) async { ... }
  // Future<List<Chapter>> getChaptersByBookId(int bookId) async { ... }
} 