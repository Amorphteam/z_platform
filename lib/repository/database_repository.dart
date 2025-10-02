import '../database/database_helper.dart';
import '../model/hekam.dart';
import '../model/mobile_app_model.dart';
import '../model/occasion.dart';
import '../model/onscreen.dart';
import '../model/translate_khotab.dart';
import '../model/word.dart';

class DatabaseRepository {
  final DatabaseHelper _dbHelper;

  DatabaseRepository({DatabaseHelper? dbHelper}) : _dbHelper = dbHelper ?? DatabaseHelper();

  // Mobile Apps caching operations
  Future<void> saveMobileApps(List<MobileApp> mobileApps) async {
    try {
      final appsData = mobileApps.map((app) => app.toJson()).toList();
      await _dbHelper.saveMobileApps(appsData);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<MobileApp>> getCachedMobileApps() async {
    try {
      final results = await _dbHelper.getCachedMobileApps();
      return results.map((map) => MobileApp.fromJson(map)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> hasCachedMobileApps() async {
    try {
      return await _dbHelper.hasCachedMobileApps();
    } catch (e) {
      return false;
    }
  }

  Future<void> clearMobileAppsCache() async {
    try {
      await _dbHelper.clearMobileAppsCache();
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