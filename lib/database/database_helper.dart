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
    String path = join(documentsDirectory.path, 'nahj.sqlite');

    // Check if the database exists
    bool exists = await databaseExists(path);

    if (!exists) {
      // Copy from asset
      ByteData data = await rootBundle.load(join('assets', 'db', 'nahj.sqlite'));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes);
    }

    return await openDatabase(path);
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
} 