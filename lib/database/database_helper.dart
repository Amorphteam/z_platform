import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'app.sqlite');

    // Create database from scratch
    final database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Create mobile_apps table
        await _createMobileAppsTable(db);
        
        // Create other tables as needed
        await _createAllTables(db);
      },
    );
    
    // Ensure mobile_apps table exists (for existing databases)
    await _createMobileAppsTable(database);
    
    return database;
  }

  Future<void> _createMobileAppsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS mobile_apps (
        id INTEGER PRIMARY KEY,
        appName TEXT NOT NULL,
        shortDescription TEXT NOT NULL,
        fullDescription TEXT NOT NULL,
        picPath TEXT NOT NULL,
        iosID INTEGER NOT NULL,
        androidLink TEXT NOT NULL,
        showAds INTEGER NOT NULL
      )
    ''');
  }

  Future<void> _createAllTables(Database db) async {
    // Create hekam table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS hekam (
        id INTEGER PRIMARY KEY,
        text TEXT,
        isFavorite INTEGER DEFAULT 0
      )
    ''');

    // Create occasions table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS occasions (
        id INTEGER PRIMARY KEY,
        day INTEGER,
        month INTEGER,
        text TEXT
      )
    ''');

    // Create onscreen table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS onscreen (
        id INTEGER PRIMARY KEY,
        text_ar TEXT
      )
    ''');

    // Create words table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS words (
        id INTEGER PRIMARY KEY,
        word TEXT,
        saleh TEXT,
        abdah TEXT
      )
    ''');

    // Create translate_khotab table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS translate_khotab (
        id INTEGER PRIMARY KEY,
        main INTEGER,
        translation TEXT
      )
    ''');

    // Create translate_letters table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS translate_letters (
        id INTEGER PRIMARY KEY,
        main INTEGER,
        translation TEXT
      )
    ''');
  }

  Future<List<Map<String, dynamic>>> getHekam() async {
    final db = await database;
    return await db.query('hekam');
  }

  Future<List<Map<String, dynamic>>> getHekamById(int id) async {
    final db = await database;
    return await db.query(
      'hekam',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> updateHekamFavorite(int id, bool isFavorite) async {
    final db = await database;
    await db.update(
      'hekam',
      {'isFavorite': isFavorite ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getOccasionsByDate(int day, int month) async {
    final db = await database;
    return await db.query(
      'occasions',
      where: 'day = ? AND month = ?',
      whereArgs: [day, month],
    );
  }

  Future<Map<String, dynamic>?> getRandomOnscreenText() async {
    final db = await database;
    final results = await db.query(
      'onscreen',
      columns: ['id', 'text_ar'],
      orderBy: 'RANDOM()',
      limit: 1,
    );
    
    if (results.isEmpty) return null;
    
    final result = results.first;
    // Ensure proper type casting
    return {
      'id': result['id'] as int,
      'text_ar': result['text_ar'] as String,
    };
  }

  Future<List<Map<String, dynamic>>> getWordsById(int id) async {
    final db = await database;
    return await db.query(
      'words',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getWords() async {
    final db = await database;
    return await db.query('words');
  }

  Future<List<Map<String, dynamic>>> getWordById(int id) async {
    final db = await database;
    return await db.query(
      'words',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> searchWords(String query) async {
    final db = await database;
    return await db.query(
      'words',
      where: 'word LIKE ? OR saleh LIKE ? OR abdah LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
    );
  }

  Future<List<Map<String, dynamic>>> getKhotabTranslation(int mainId) async {
    final db = await database;
    return await db.query(
      'translate_khotab',
      where: 'main = ?',
      whereArgs: [mainId],
    );
  }

  Future<List<Map<String, dynamic>>> getLettersTranslation(int mainId) async {
    final db = await database;
    return await db.query(
      'translate_letters',
      where: 'main = ?',
      whereArgs: [mainId],
    );
  }

  // Mobile Apps caching methods
  Future<void> saveMobileApps(List<Map<String, dynamic>> mobileApps) async {
    final db = await database;
    
    // First, clear existing mobile apps data
    await db.delete('mobile_apps');
    
    // Insert new mobile apps data
    for (final app in mobileApps) {
      await db.insert('mobile_apps', app);
    }
  }

  Future<List<Map<String, dynamic>>> getCachedMobileApps() async {
    final db = await database;
    return await db.query('mobile_apps');
  }

  Future<bool> hasCachedMobileApps() async {
    final db = await database;
    final result = await db.query('mobile_apps', limit: 1);
    return result.isNotEmpty;
  }

  Future<void> clearMobileAppsCache() async {
    final db = await database;
    await db.delete('mobile_apps');
  }
} 