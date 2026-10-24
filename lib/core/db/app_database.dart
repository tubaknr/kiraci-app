import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static const String databaseName = 'saferenthouse.db';
  static const int databaseVersion = 1;

  static const String tableCases = 'cases';
  static const String tableRecords = 'records';

  Database? _db;

  AppDatabase([this._db]);

  static final AppDatabase instance = AppDatabase();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, databaseName);

    return openDatabase(
      path,
      version: databaseVersion,
      onCreate: _onCreate,
      onConfigure: _onConfigure,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableCases (
        id TEXT PRIMARY KEY NOT NULL,
        title TEXT NOT NULL,
        address TEXT NOT NULL,
        my_role TEXT NOT NULL,
        other_party_name TEXT NOT NULL,
        lease_start TEXT NOT NULL,
        lease_end TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $tableRecords (
        id TEXT PRIMARY KEY NOT NULL,
        case_id TEXT NOT NULL,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        note TEXT,
        file_path TEXT,
        content_hash TEXT NOT NULL,
        prev_chain_hash TEXT NOT NULL,
        chain_hash TEXT NOT NULL,
        recorded_at TEXT NOT NULL,
        clock_anomaly INTEGER NOT NULL DEFAULT 0,
        form_type TEXT,
        corrects_record_id TEXT,
        FOREIGN KEY (case_id) REFERENCES $tableCases (id) ON DELETE RESTRICT
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_records_case_id ON $tableRecords (case_id)',
    );
    await db.execute(
      'CREATE INDEX idx_records_recorded_at ON $tableRecords (recorded_at)',
    );
  }

  Future<void> close() async {
    if (_db != null) {
      await _db!.close();
      _db = null;
    }
  }
}
