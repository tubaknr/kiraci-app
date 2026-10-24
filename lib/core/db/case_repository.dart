import 'package:sqflite/sqflite.dart';
import '../../features/cases/models/case_model.dart';
import 'app_database.dart';

abstract class CaseRepository {
  Future<CaseModel> insert(CaseModel caseModel);
  Future<List<CaseModel>> getAll();
  Future<CaseModel?> getById(String id);
}

class SqliteCaseRepository implements CaseRepository {
  final AppDatabase _appDatabase;

  SqliteCaseRepository({AppDatabase? appDatabase})
      : _appDatabase = appDatabase ?? AppDatabase.instance;

  @override
  Future<CaseModel> insert(CaseModel caseModel) async {
    final db = await _appDatabase.database;
    await db.insert(
      AppDatabase.tableCases,
      caseModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
    return caseModel;
  }

  @override
  Future<List<CaseModel>> getAll() async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppDatabase.tableCases,
      orderBy: 'created_at DESC',
    );
    return maps.map(CaseModel.fromMap).toList();
  }

  @override
  Future<CaseModel?> getById(String id) async {
    final db = await _appDatabase.database;
    final List<Map<String, dynamic>> maps = await db.query(
      AppDatabase.tableCases,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return CaseModel.fromMap(maps.first);
  }
}
