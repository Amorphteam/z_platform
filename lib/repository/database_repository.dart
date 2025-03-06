import 'package:sqflite/sqflite.dart';
import '../model/rejal.dart';
import '../util/database_helper.dart';


class DatabaseRepository {

  Future<List<Rejal>> getRejalsByIds(List<int> ids) async {
    final db = await DatabaseHelper.database;
    String idList = ids.map((id) => '?').join(',');
    print('Searching for IDs: $ids');
    print('SQL Query: SELECT * FROM rejal WHERE id IN ($idList)');

    // First, let's check the table structure
    final List<Map<String, dynamic>> tableInfo = await db.rawQuery('PRAGMA table_info(rejal)');
    print('Table schema: $tableInfo');

    final List<Map<String, dynamic>> results =
        await db.query('rejal', where: 'id IN ($idList)', whereArgs: ids);
    print('Raw query results: $results');

    final rejals = results.map(Rejal.fromJson).toList();
    print('Parsed Rejal objects: ${rejals.first.ID}');

    return rejals;
  }
}
