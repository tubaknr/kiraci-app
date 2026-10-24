import 'package:sqflite/sqflite.dart';
import '../../features/records/models/record_model.dart';
import 'app_database.dart';

abstract class RecordRepository {
  /// Yalnızca yeni kayıt ekler. UPDATE veya DELETE metodu YOKTUR (Append-only).
  Future<RecordModel> insert(RecordModel record, {Transaction? txn});

  /// Bir dosyaya (case) ait tüm kayıtları kronolojik sırayla getirir.
  Future<List<RecordModel>> getByCase(String caseId);

  /// Belirtilen ID'ye sahip tekil kaydı getirir.
  Future<RecordModel?> getById(String id);

  /// Bir dosyadaki en son eklenmiş kaydı getirir (zincir bağlantısı için).
  Future<RecordModel?> getLast(String caseId, {Transaction? txn});

  /// Bir dosyadaki kayıt sayısını döndürür.
  Future<int> countByCase(String caseId);
}

class SqliteRecordRepository implements RecordRepository {
  final AppDatabase _appDatabase;

  SqliteRecordRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  @override
  Future<RecordModel> insert(RecordModel record, {Transaction? txn}) async {
    final executor = txn ?? await _appDatabase.database;
    await executor.insert(
      AppDatabase.tableRecords,
      record.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return record;
  }

  @override
  Future<List<RecordModel>> getByCase(String caseId) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppDatabase.tableRecords,
      where: 'case_id = ?',
      whereArgs: [caseId],
      orderBy: 'recorded_at ASC, rowid ASC',
    );
    return maps.map(RecordModel.fromMap).toList();
  }

  @override
  Future<RecordModel?> getById(String id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppDatabase.tableRecords,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return RecordModel.fromMap(maps.first);
  }

  @override
  Future<RecordModel?> getLast(String caseId, {Transaction? txn}) async {
    final executor = txn ?? await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await executor.query(
      AppDatabase.tableRecords,
      where: 'case_id = ?',
      whereArgs: [caseId],
      orderBy: 'recorded_at DESC, rowid DESC',
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return RecordModel.fromMap(maps.first);
  }

  @override
  Future<int> countByCase(String caseId) async {
    final db = await _appDatabase.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM ${AppDatabase.tableRecords} WHERE case_id = ?',
      [caseId],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }
}
