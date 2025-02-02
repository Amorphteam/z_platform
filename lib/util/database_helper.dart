import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static const String dbName = "rejal.db";
  static Database? _database;

  /// Get the database instance
  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize database (copy from assets if not exists)
  static Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbPath = join(documentsDirectory.path, dbName);

    // Check if the database exists
    bool dbExists = await databaseExists(dbPath);
    if (!dbExists) {
      // Copy from assets
      ByteData data = await rootBundle.load("assets/db/$dbName");
      List<int> bytes = data.buffer.asUint8List();
      await File(dbPath).writeAsBytes(bytes, flush: true);
    }

    return await openDatabase(dbPath, version: 1);
  }
}
