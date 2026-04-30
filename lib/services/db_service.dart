import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('launcher_ai.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
      onOpen: (db) async {
        // Migration: Ensure geo columns exist
        final columns = await db.rawQuery('PRAGMA table_info(app_usage_logs)');
        final columnNames = columns.map((e) => e['name'] as String).toSet();
        if (!columnNames.contains('latitude')) {
          await db.execute('ALTER TABLE app_usage_logs ADD COLUMN latitude REAL');
        }
        if (!columnNames.contains('longitude')) {
          await db.execute('ALTER TABLE app_usage_logs ADD COLUMN longitude REAL');
        }
      },
    );
  }

  Future _createDB(Database db, int version) async {
    // Stores every app open event with context
    await db.execute('''
      CREATE TABLE app_usage_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        packageName TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        hourOfDay INTEGER NOT NULL,
        dayOfWeek INTEGER NOT NULL,
        latitude REAL,
        longitude REAL,
        sessionDuration INTEGER DEFAULT 0
      )
    ''');

    // Stores daily summaries for quick insights
    await db.execute('''
      CREATE TABLE daily_stats (
        date TEXT PRIMARY KEY,
        totalScreenTime INTEGER DEFAULT 0,
        unconsciousOpens INTEGER DEFAULT 0,
        topApp TEXT
      )
    ''');
  }

  Future<void> logAppOpen(String packageName, {double? lat, double? lng}) async {
    final db = await instance.database;
    final now = DateTime.now();
    await db.insert('app_usage_logs', {
      'packageName': packageName,
      'timestamp': now.millisecondsSinceEpoch,
      'hourOfDay': now.hour,
      'dayOfWeek': now.weekday,
      'latitude': lat,
      'longitude': lng,
    });
  }

  Future<List<Map<String, dynamic>>> getFrequencyByHour(int hour) async {
    final db = await instance.database;
    return await db.query(
      'app_usage_logs',
      where: 'hourOfDay = ?',
      whereArgs: [hour],
      groupBy: 'packageName',
      orderBy: 'COUNT(*) DESC',
      limit: 5,
    );
  }

  Future<Map<String, int>> getAllFrequencies() async {
    final db = await instance.database;
    final res = await db.rawQuery(
      'SELECT packageName, COUNT(*) as count FROM app_usage_logs GROUP BY packageName',
    );
    return {
      for (var item in res)
        item['packageName'] as String: item['count'] as int,
    };
  }

  Future<void> close() async {
    final db = await _database;
    if (db != null) await db.close();
  }
}
