import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/core/services/integrity_service.dart';
import 'package:saferenthouse/core/services/record_service.dart';

import 'record_service_test.dart';

void main() {
  late Directory tempAppDir;
  late Directory tempSrcDir;
  late InMemoryRecordRepository recordRepo;
  late RecordService recordService;
  late IntegrityService integrityService;

  setUp(() async {
    tempAppDir = await Directory.systemTemp.createTemp('integrity_app_');
    tempSrcDir = await Directory.systemTemp.createTemp('integrity_src_');
    recordRepo = InMemoryRecordRepository();

    recordService = RecordService(
      recordRepository: recordRepo,
      getAppDocDir: () async => tempAppDir,
    );

    integrityService = IntegrityService(
      recordRepository: recordRepo,
      getAppDocDir: () async => tempAppDir,
    );
  });

  tearDown(() async {
    if (await tempAppDir.exists()) await tempAppDir.delete(recursive: true);
    if (await tempSrcDir.exists()) await tempSrcDir.delete(recursive: true);
  });

  group('IntegrityService - verifyChain Tests', () {
    test('Hic kayit olmayan dosya icin sonuc gecerli olmalidir', () async {
      final result = await integrityService.verifyChain('empty_case');
      expect(result.isValid, isTrue);
      expect(result.totalRecords, 0);
      expect(result.lastChainHash, isNull);
    });

    test('Bozulmamis kayit zinciri basariyla dogrulanmalidir', () async {
      final f1 = File('${tempSrcDir.path}/doc1.pdf')..writeAsStringSync('Belge 1');
      final f2 = File('${tempSrcDir.path}/doc2.pdf')..writeAsStringSync('Belge 2');

      await recordService.addFileRecord(
        caseId: 'case_clean',
        type: 'document',
        title: 'Ilk Belge',
        sourceFile: f1,
      );

      final rec2 = await recordService.addFileRecord(
        caseId: 'case_clean',
        type: 'document',
        title: 'Ikinci Belge',
        sourceFile: f2,
      );

      final result = await integrityService.verifyChain('case_clean');
      expect(result.isValid, isTrue);
      expect(result.totalRecords, 2);
      expect(result.lastChainHash, rec2.chainHash);
      expect(result.brokenRecordId, isNull);

      final sealCode = await integrityService.getSealCode('case_clean');
      expect(sealCode, rec2.chainHash);
    });

    test('Diskteki dosya elle degistirilirse bozulma yakalanmalidir', () async {
      final f1 = File('${tempSrcDir.path}/delil.pdf')..writeAsStringSync('Orijinal Kanit Metni');

      final rec = await recordService.addFileRecord(
        caseId: 'case_tampered',
        type: 'document',
        title: 'Kanit Dosyasi',
        sourceFile: f1,
      );

      // Diskteki dosyayi sahtesiyle degistirelim (tahrifat simulasyonu)
      final savedPhysicalFile = await recordService.getAbsoluteFile(rec.filePath);
      expect(savedPhysicalFile, isNotNull);
      await savedPhysicalFile!.writeAsString('Tahrif Edilmis Sahte Metin');

      final result = await integrityService.verifyChain('case_tampered');
      expect(result.isValid, isFalse);
      expect(result.brokenRecordId, rec.id);
      expect(result.failureReason, contains('Dosya içeriği sonradan değiştirilmiş'));
    });

    test('Veritabanindaki chain_hash tahrif edilirse zincir kirilmasi yakalanmalidir', () async {
      final f1 = File('${tempSrcDir.path}/f1.pdf')..writeAsStringSync('Veri 1');
      final rec = await recordService.addFileRecord(
        caseId: 'case_db_tampered',
        type: 'document',
        title: 'Belge',
        sourceFile: f1,
      );

      // Veritabanindaki satiri sahte chainHash ile guncelleyelim
      final index = recordRepo.storage.indexWhere((r) => r.id == rec.id);
      recordRepo.storage[index] = rec.copyWith(chainHash: 'sahte_chain_hash_1234567890');

      final result = await integrityService.verifyChain('case_db_tampered');
      expect(result.isValid, isFalse);
      expect(result.brokenRecordId, rec.id);
      expect(result.failureReason, contains('Kayıt zincir özet değeri geçersiz'));
    });

    test('Dosya diskten silinirse eksik dosya hatasi yakalanmalidir', () async {
      final f1 = File('${tempSrcDir.path}/silinecek.pdf')..writeAsStringSync('Silinecek');
      final rec = await recordService.addFileRecord(
        caseId: 'case_deleted_file',
        type: 'document',
        title: 'Silinen Dosya',
        sourceFile: f1,
      );

      final savedFile = await recordService.getAbsoluteFile(rec.filePath);
      await savedFile!.delete();

      final result = await integrityService.verifyChain('case_deleted_file');
      expect(result.isValid, isFalse);
      expect(result.brokenRecordId, rec.id);
      expect(result.failureReason, contains('Kayıtlı delil dosyası diskte bulunamadı'));
    });
  });
}
