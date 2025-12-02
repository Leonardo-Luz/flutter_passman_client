import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart' as p;

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();
  static Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;

    DatabaseFactory factory;

    if (Platform.isAndroid || Platform.isIOS) {
      factory = databaseFactory;
    } else {
      sqfliteFfiInit();
      factory = databaseFactoryFfi;
    }

    final dbPath = await factory.getDatabasesPath();
    final path = p.join(dbPath, "passmancli.db");

    _db = await factory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE passwords (
              id TEXT PRIMARY KEY,
              service TEXT NOT NULL,
              secret TEXT NOT NULL,
              description TEXT
            );
          ''');
        },
      ),
    );

    return _db!;
  }
}
