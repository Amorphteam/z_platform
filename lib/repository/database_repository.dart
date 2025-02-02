import 'package:sqflite/sqflite.dart';
import '../model/rejal.dart';
import '../util/database_helper.dart';


class DatabaseRepository {

  Future<List<Rejal>> getRejalsByIds(List<int> ids) async {
    final db = await DatabaseHelper.database;
    String idList = ids.map((id) => '?').join(',');
    final List<Map<String, dynamic>> results =
    await db.query('rejal', where: 'ID IN ($idList)', whereArgs: ids);
    return results.map(Rejal.fromJson).toList();
  }
}
