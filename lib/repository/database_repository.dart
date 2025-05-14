import 'package:zahra/database/database_helper.dart';
import 'package:zahra/model/hekam.dart';

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

  // Add more table operations here as needed
  // For example:
  // Future<List<Category>> getAllCategories() async { ... }
  // Future<Book?> getBookById(int id) async { ... }
  // Future<List<Chapter>> getChaptersByBookId(int bookId) async { ... }
} 