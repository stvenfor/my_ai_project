import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  AppDatabase._();

  static AppDatabase? _instance;
  static Database? _database;

  static const _dbName = 'module_sample.db';
  static const _dbVersion = 2;

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
        await _createV1(db);
        await _createV2(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createV2(db);
        }
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

  static Future<void> _createV1(Database db) async {
    await db.execute('''
      CREATE TABLE cache_entries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cache_key TEXT NOT NULL UNIQUE,
        cache_value TEXT NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  static Future<void> _createV2(Database db) async {
    await db.execute('''
      CREATE TABLE ws_outbound_queue (
        message_id TEXT PRIMARY KEY,
        topic TEXT NOT NULL,
        event_name TEXT NOT NULL,
        payload_json TEXT NOT NULL,
        status TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
  }

  Future<void> upsertOutbound({
    required String messageId,
    required String topic,
    required String eventName,
    required String payloadJson,
    required String status,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await database.insert(
      'ws_outbound_queue',
      {
        'message_id': messageId,
        'topic': topic,
        'event_name': eventName,
        'payload_json': payloadJson,
        'status': status,
        'created_at': now,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateOutboundStatus(String messageId, String status) async {
    await database.update(
      'ws_outbound_queue',
      {
        'status': status,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'message_id = ?',
      whereArgs: [messageId],
    );
  }

  Future<List<Map<String, dynamic>>> pendingOutbound() async {
    return database.query(
      'ws_outbound_queue',
      where: 'status IN (?, ?)',
      whereArgs: ['pending', 'sent'],
      orderBy: 'created_at ASC',
    );
  }

  Future<void> deleteOutbound(String messageId) async {
    await database.delete(
      'ws_outbound_queue',
      where: 'message_id = ?',
      whereArgs: [messageId],
    );
  }

  Future<void> clearOutbound() async {
    await database.delete('ws_outbound_queue');
  }
}
