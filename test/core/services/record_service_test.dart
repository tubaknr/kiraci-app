import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/core/constants/view_status.dart';
import 'package:saferenthouse/core/db/record_repository.dart';
import 'package:saferenthouse/core/integrity/hash_utils.dart';
import 'package:saferenthouse/core/services/record_service.dart';
import 'package:saferenthouse/features/records/controller/record_add_controller.dart';
import 'package:saferenthouse/features/records/models/record_model.dart';
import 'package:sqflite/sqflite.dart';

class InMemoryRecordRepository implements RecordRepository {
  final List<RecordModel> storage = [];

  @override
  Future<RecordModel> insert(RecordModel record, {Transaction? txn}) async {
    storage.add(record);
    return record;
  }

  @override
  Future<List<RecordModel>> getByCase(String caseId) async {
    return storage.where((r) => r.caseId == caseId).toList();
  }

  @override
  Future<RecordModel?> getById(String id) async {
    try {
      return storage.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<RecordModel?> getLast(String caseId, {Transaction? txn}) async {
    final list = storage.where((r) => r.caseId == caseId).toList();
    if (list.isEmpty) return null;
    return list.last;
  }

  @override
  Future<int> countByCase(String caseId) async {
    return storage.where((r) => r.caseId == caseId).length;
  }
}

void main() {
  late Directory tempAppDir;
  late Directory tempSourceDir;
  late InMemoryRecordRepository recordRepo;

  setUp(() async {
    tempAppDir = await Directory.systemTemp.createTemp('saferent_app_');
    tempSourceDir = await Directory.systemTemp.createTemp('saferent_src_');
    recordRepo = InMemoryRecordRepository();
  });

  tearDown(() async {
    if (await tempAppDir.exists()) {
      await tempAppDir.delete(recursive: true);
    }
    if (await tempSourceDir.exists()) {
      await tempSourceDir.delete(recursive: true);
    }
  });

  group('RecordService Tests', () {
    test('Ilk dosya kaydi eklendiginde GENESIS zinciri ve hashler dogru olusturulmalidir', () async {
      final sourceFile = File('${tempSourceDir.path}/kira_sozlesmesi.pdf');
      await sourceFile.writeAsString('Ornek PDF sozlesme baytlari');

      final service = RecordService(
        recordRepository: recordRepo,
        getAppDocDir: () async => tempAppDir,
        clock: () => DateTime.utc(2026, 1, 1, 10, 0, 0),
      );

      final record = await service.addFileRecord(
        caseId: 'case_1',
        type: 'document',
        title: 'Kira Sozlesmesi',
        sourceFile: sourceFile,
      );

      expect(record.caseId, 'case_1');
      expect(record.prevChainHash, HashUtils.genesisHash);
      expect(record.clockAnomaly, isFalse);
      expect(record.filePath, startsWith('records/case_1/'));

      // Dosyanin uygulama dizinine kopyalandigini dogrula
      final savedFile = await service.getAbsoluteFile(record.filePath);
      expect(savedFile, isNotNull);
      expect(await savedFile!.exists(), isTrue);
      expect(await savedFile.readAsString(), 'Ornek PDF sozlesme baytlari');

      // Hash zincirinin saglamligini dogrula
      final expectedContentHash = HashUtils.sha256Hex(utf8.encode('Ornek PDF sozlesme baytlari'));
      expect(record.contentHash, expectedContentHash);

      final expectedChain = HashUtils.chainHash(
        HashUtils.genesisHash,
        expectedContentHash,
        DateTime.utc(2026, 1, 1, 10, 0, 0),
      );
      expect(record.chainHash, expectedChain);
    });

    test('Ikinci kayit eklendiginde birincinin chain_hashine baglanmalidir', () async {
      final file1 = File('${tempSourceDir.path}/foto1.jpg');
      await file1.writeAsString('Foto 1 icerigi');
      final file2 = File('${tempSourceDir.path}/foto2.jpg');
      await file2.writeAsString('Foto 2 icerigi');

      var currentTime = DateTime.utc(2026, 1, 1, 10, 0, 0);
      final service = RecordService(
        recordRepository: recordRepo,
        getAppDocDir: () async => tempAppDir,
        clock: () => currentTime,
      );

      final rec1 = await service.addFileRecord(
        caseId: 'case_1',
        type: 'photo',
        title: 'Banyo Hasari 1',
        sourceFile: file1,
      );

      currentTime = DateTime.utc(2026, 1, 1, 11, 0, 0); // 1 saat sonra
      final rec2 = await service.addFileRecord(
        caseId: 'case_1',
        type: 'photo',
        title: 'Banyo Hasari 2',
        sourceFile: file2,
      );

      expect(rec2.prevChainHash, rec1.chainHash);
      expect(rec2.clockAnomaly, isFalse);

      final expectedRec2Chain = HashUtils.chainHash(
        rec1.chainHash,
        rec2.contentHash,
        currentTime,
      );
      expect(rec2.chainHash, expectedRec2Chain);
    });

    test('Saat geriye alindiginda clock_anomaly true olarak isaretlenmelidir', () async {
      final file1 = File('${tempSourceDir.path}/doc1.pdf');
      await file1.writeAsString('Icerik 1');
      final file2 = File('${tempSourceDir.path}/doc2.pdf');
      await file2.writeAsString('Icerik 2');

      var currentTime = DateTime.utc(2026, 1, 5, 12, 0, 0);
      final service = RecordService(
        recordRepository: recordRepo,
        getAppDocDir: () async => tempAppDir,
        clock: () => currentTime,
      );

      await service.addFileRecord(
        caseId: 'case_1',
        type: 'document',
        title: 'Ilk Belge',
        sourceFile: file1,
      );

      // Cihaz saati 2 gun geriye aliniyor
      currentTime = DateTime.utc(2026, 1, 3, 12, 0, 0);

      final rec2 = await service.addFileRecord(
        caseId: 'case_1',
        type: 'document',
        title: 'Geriye Alinmis Saatli Belge',
        sourceFile: file2,
      );

      expect(rec2.clockAnomaly, isTrue);
    });

    test('addFormRecord kanonik JSON dosyasini kaydetmeli ve zincire baglamalidir', () async {
      final service = RecordService(
        recordRepository: recordRepo,
        getAppDocDir: () async => tempAppDir,
        clock: () => DateTime.utc(2026, 2, 1, 10, 0, 0),
      );

      final formData = {
        'tutar': 15000,
        'kira_ayi': 'Subat 2026',
        'aciklama': 'Banka havalesi ile odendi',
      };

      final record = await service.addFormRecord(
        caseId: 'case_1',
        formType: 'F4',
        title: 'Kira Odeme Bildirimi',
        formData: formData,
      );

      expect(record.type, 'form');
      expect(record.formType, 'F4');
      expect(record.contentHash, HashUtils.canonicalJsonHash(formData));

      final savedFile = await service.getAbsoluteFile(record.filePath);
      expect(savedFile, isNotNull);
      expect(await savedFile!.exists(), isTrue);

      final readContent = await savedFile.readAsString();
      expect(readContent, HashUtils.canonicalJson(formData));
    });
  });

  group('RecordAddController Tests', () {
    test('Gecerli dosya ile addFileRecord basarili olmalidir', () async {
      final file = File('${tempSourceDir.path}/test_file.txt');
      await file.writeAsString('test data');

      final service = RecordService(
        recordRepository: recordRepo,
        getAppDocDir: () async => tempAppDir,
      );
      final controller = RecordAddController(service);

      final success = await controller.addFileRecord(
        caseId: 'case_test',
        type: 'document',
        title: 'Test Kaydi',
        file: file,
      );

      expect(success, isTrue);
      expect(controller.status.value, ViewStatus.success);
      expect(controller.createdRecord.value, isNotNull);
      expect(controller.errorMessage.value, isNull);

      controller.dispose();
    });

    test('Bos baslik verilirse dogrulama hatasi set edilmelidir', () async {
      final file = File('${tempSourceDir.path}/test_file.txt');
      await file.writeAsString('test data');

      final service = RecordService(
        recordRepository: recordRepo,
        getAppDocDir: () async => tempAppDir,
      );
      final controller = RecordAddController(service);

      final success = await controller.addFileRecord(
        caseId: 'case_test',
        type: 'document',
        title: '   ',
        file: file,
      );

      expect(success, isFalse);
      expect(controller.status.value, ViewStatus.error);
      expect(controller.errorMessage.value, 'Kayıt başlığı boş bırakılamaz.');

      controller.dispose();
    });
  });
}
