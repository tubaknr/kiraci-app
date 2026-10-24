import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/core/db/app_database.dart';
import 'package:saferenthouse/core/db/case_repository.dart';
import 'package:saferenthouse/core/db/record_repository.dart';
import 'package:saferenthouse/features/cases/models/case_model.dart';
import 'package:saferenthouse/features/records/models/record_model.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late AppDatabase appDatabase;
  late CaseRepository caseRepository;
  late RecordRepository recordRepository;

  setUp(() async {
    db = await databaseFactory.openDatabase(
      inMemoryDatabasePath,
      options: OpenDatabaseOptions(
        version: AppDatabase.databaseVersion,
        onConfigure: (db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE ${AppDatabase.tableCases} (
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
            CREATE TABLE ${AppDatabase.tableRecords} (
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
              FOREIGN KEY (case_id) REFERENCES ${AppDatabase.tableCases} (id) ON DELETE RESTRICT
            )
          ''');
        },
      ),
    );

    appDatabase = AppDatabase(db);
    caseRepository = SqliteCaseRepository(appDatabase: appDatabase);
    recordRepository = SqliteRecordRepository(appDatabase: appDatabase);
  });

  tearDown(() async {
    await db.close();
  });

  group('CaseRepository Tests', () {
    test('Case ekleme ve id ile getirme calismalidir', () async {
      final sampleCase = CaseModel(
        id: 'case_1',
        title: 'Kadikoy Daire Kira',
        address: 'Moda Cad. No: 12 Kadikoy / Istanbul',
        myRole: 'tenant',
        otherPartyName: 'Ahmet Yilmaz',
        leaseStart: DateTime.utc(2026, 1, 1),
        leaseEnd: DateTime.utc(2027, 1, 1),
        createdAt: DateTime.utc(2026, 1, 1, 10, 0),
      );

      await caseRepository.insert(sampleCase);
      final fetched = await caseRepository.getById('case_1');

      expect(fetched, isNotNull);
      expect(fetched!.title, 'Kadikoy Daire Kira');
      expect(fetched.myRole, 'tenant');
      expect(fetched.otherPartyName, 'Ahmet Yilmaz');
    });

    test('Tum case listesini sirali getirmelidir', () async {
      final case1 = CaseModel(
        id: 'case_1',
        title: 'Ilk Daire',
        address: 'Adres 1',
        myRole: 'tenant',
        otherPartyName: 'Ev Sahibi 1',
        leaseStart: DateTime.utc(2026, 1, 1),
        createdAt: DateTime.utc(2026, 1, 1, 10, 0),
      );
      final case2 = CaseModel(
        id: 'case_2',
        title: 'Ikinci Daire',
        address: 'Adres 2',
        myRole: 'landlord',
        otherPartyName: 'Kiraci 2',
        leaseStart: DateTime.utc(2026, 2, 1),
        createdAt: DateTime.utc(2026, 2, 1, 10, 0),
      );

      await caseRepository.insert(case1);
      await caseRepository.insert(case2);

      final list = await caseRepository.getAll();
      expect(list.length, 2);
      expect(list.first.id, 'case_2'); // created_at DESC siralamasi
    });
  });

  group('RecordRepository Tests (Append-Only)', () {
    setUp(() async {
      // Once bagli bir case olustur
      await caseRepository.insert(
        CaseModel(
          id: 'case_parent',
          title: 'Test Dosyasi',
          address: 'Test Adresi',
          myRole: 'tenant',
          otherPartyName: 'Ev Sahibi',
          leaseStart: DateTime.utc(2026, 1, 1),
          createdAt: DateTime.utc(2026, 1, 1),
        ),
      );
    });

    test('Kayit ekleme ve sorgulama dogru calismalidir', () async {
      final record = RecordModel(
        id: 'rec_1',
        caseId: 'case_parent',
        type: 'document',
        title: 'Kira Sozlesmesi Taramasi',
        note: 'Islak imzali sozlesme',
        filePath: 'records/case_parent/sozlesme.pdf',
        contentHash: 'hash_abc_123',
        prevChainHash: 'GENESIS',
        chainHash: 'chain_hash_1',
        recordedAt: DateTime.utc(2026, 1, 1, 12, 0),
      );

      await recordRepository.insert(record);

      final fetched = await recordRepository.getById('rec_1');
      expect(fetched, isNotNull);
      expect(fetched!.title, 'Kira Sozlesmesi Taramasi');
      expect(fetched.prevChainHash, 'GENESIS');
      expect(fetched.clockAnomaly, isFalse);
    });

    test('getLast en son eklenen kaydi getirmelidir', () async {
      final rec1 = RecordModel(
        id: 'rec_1',
        caseId: 'case_parent',
        type: 'photo',
        title: 'Ilk Foto',
        contentHash: 'hash_1',
        prevChainHash: 'GENESIS',
        chainHash: 'chain_1',
        recordedAt: DateTime.utc(2026, 1, 1, 10, 0),
      );

      final rec2 = RecordModel(
        id: 'rec_2',
        caseId: 'case_parent',
        type: 'photo',
        title: 'Ikinci Foto',
        contentHash: 'hash_2',
        prevChainHash: 'chain_1',
        chainHash: 'chain_2',
        recordedAt: DateTime.utc(2026, 1, 1, 11, 0),
      );

      await recordRepository.insert(rec1);
      await recordRepository.insert(rec2);

      final last = await recordRepository.getLast('case_parent');
      expect(last, isNotNull);
      expect(last!.id, 'rec_2');
      expect(last.chainHash, 'chain_2');

      final count = await recordRepository.countByCase('case_parent');
      expect(count, 2);
    });

    test('Saat anomalisi (clock_anomaly) olan kayit dogru kaydedilmelidir', () async {
      final anomalyRecord = RecordModel(
        id: 'rec_anomaly',
        caseId: 'case_parent',
        type: 'chat_proof',
        title: 'WhatsApp Mesaj Gorseli',
        contentHash: 'hash_anomaly',
        prevChainHash: 'chain_prev',
        chainHash: 'chain_anomaly',
        recordedAt: DateTime.utc(2025, 12, 1, 10, 0), // Saat geriye alinmis
        clockAnomaly: true,
      );

      await recordRepository.insert(anomalyRecord);
      final fetched = await recordRepository.getById('rec_anomaly');

      expect(fetched, isNotNull);
      expect(fetched!.clockAnomaly, isTrue);
    });

    test('Yabanci anahtar kisiti (Foreign Key) gecersiz case_id eklenmesini engellemelidir', () async {
      final invalidRecord = RecordModel(
        id: 'rec_invalid',
        caseId: 'olmayan_case_id',
        type: 'document',
        title: 'Gecersiz Kayit',
        contentHash: 'hash_x',
        prevChainHash: 'GENESIS',
        chainHash: 'chain_x',
        recordedAt: DateTime.utc(2026, 1, 1),
      );

      expect(
        () async => recordRepository.insert(invalidRecord),
        throwsA(isA<DatabaseException>()),
      );
    });
  });
}
