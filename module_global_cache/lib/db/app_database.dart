import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static AppDatabase? _instance;
  static Database? _database;

  static const _dbName = 'module_sample.db';
  static const _dbVersion = 1;

  static Future<AppDatabase> init() async {
    _instance ??= AppDatabase._();
    _database ??= await _open();
    return _instance!;
  }

  static AppDatabase get instance {
    final db = _instance;
    if (db == null) {
      throw StateError('AppDatabase has not been initialized.');
    }
    return db;
  }

  Database get database {
    final db = _database;
    if (db == null) {
      throw StateError('AppDatabase has not been initialized.');
    }
    return db;
  }

  static Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);
    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE cache_entries (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            cache_key TEXT NOT NULL UNIQUE,
            cache_value TEXT NOT NULL,
            updated_at INTEGER NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> upsertCache(String key, String value) async {
    await database.insert(
      'cache_entries',
      {
        'cache_key': key,
        'cache_value': value,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> readCache(String key) async {
    final rows = await database.query(
      'cache_entries',
      where: 'cache_key = ?',
      whereArgs: [key],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first['cache_value'] as String?;
  }
}
