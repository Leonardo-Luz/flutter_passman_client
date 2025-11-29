import 'package:flutter_passman_client/data/database.dart';
import 'package:flutter_passman_client/models/passentry.dart';

class PasswordDao {
  Future<void> insert(PassEntry entry) async {
    final db = await AppDatabase.instance.database;
    await db.insert('passwords', entry.toMap());
  }

  Future<List<PassEntry>> getAll() async {
    final db = await AppDatabase.instance.database;
    final res = await db.query('passwords', orderBy: 'service ASC');
    return res.map((m) => PassEntry.fromMap(m)).toList();
  }

  Future<List<PassEntry>> getByService(String service) async {
    final db = await AppDatabase.instance.database;
    final result = await db.query(
      'passwords',
      where: 'service = ?',
      whereArgs: [service],
    );

    return result.map((row) => PassEntry.fromMap(row)).toList();
  }

  Future<void> update(PassEntry entry) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'passwords',
      entry.toMap(),
      where: 'id = ?',
      whereArgs: [entry.id],
    );
  }

  Future<void> deleteById(String id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('passwords', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteAll() async {
    final db = await AppDatabase.instance.database;
    await db.delete('passwords');
  }
}
