import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/core/constants/view_status.dart';
import 'package:saferenthouse/core/services/export_service.dart';
import 'package:saferenthouse/core/services/integrity_service.dart';
import 'package:saferenthouse/core/services/record_service.dart';
import 'package:saferenthouse/features/export/controller/export_controller.dart';

import 'record_service_test.dart';

void main() {
  late Directory tempAppDir;
  late Directory tempSrcDir;
  late InMemoryRecordRepository recordRepo;
  late RecordService recordService;
  late IntegrityService integrityService;
  late ExportService exportService;

  setUp(() async {
    tempAppDir = await Directory.systemTemp.createTemp('export_app_');
    tempSrcDir = await Directory.systemTemp.createTemp('export_src_');
    recordRepo = InMemoryRecordRepository();

    recordService = RecordService(
      recordRepository: recordRepo,
      getAppDocDir: () async => tempAppDir,
    );
    integrityService = IntegrityService(
      recordRepository: recordRepo,
      getAppDocDir: () async => tempAppDir,
    );
    exportService = ExportService(
      recordRepository: recordRepo,
      integrityService: integrityService,
      getAppDocDir: () async => tempAppDir,
    );
  });

  tearDown(() async {
    if (await tempAppDir.exists()) await tempAppDir.delete(recursive: true);
    if (await tempSrcDir.exists()) await tempSrcDir.delete(recursive: true);
  });

  group('ExportService Tests', () {
    test('createEvidenceZipPackage manifest.json ve dosyalari iceren zip uretmelidir', () async {
      final f1 = File('${tempSrcDir.path}/delil.pdf')..writeAsStringSync('Delil belgesi verisi');

      final rec1 = await recordService.addFileRecord(
        caseId: 'case_zip_test',
        type: 'document',
        title: 'Banka Dekontu',
        sourceFile: f1,
      );

      final rec2 = await recordService.addFormRecord(
        caseId: 'case_zip_test',
        formType: 'F1',
        title: 'Kira Sozlesmesi',
        formData: {'kira': 20000, 'kiraci': 'Ali'},
      );

      final zipFile = await exportService.createEvidenceZipPackage('case_zip_test');
      expect(await zipFile.exists(), isTrue);

      // ZIP dosyasini cozelim ve icerigini dogrulayalim
      final zipBytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(zipBytes);

      final manifestEntry = archive.findFile('manifest.json');
      expect(manifestEntry, isNotNull);

      final manifestString = utf8.decode(manifestEntry!.content as List<int>);
      final manifestMap = jsonDecode(manifestString) as Map<String, dynamic>;

      expect(manifestMap['case_id'], 'case_zip_test');
      expect(manifestMap['record_count'], 2);
      expect(manifestMap['is_chain_valid'], isTrue);
      expect(manifestMap['last_chain_hash'], rec2.chainHash);

      final recordsInManifest = manifestMap['records'] as List<dynamic>;
      expect(recordsInManifest.length, 2);
      expect(recordsInManifest.first['id'], rec1.id);
      expect(recordsInManifest.last['id'], rec2.id);

      // Dosyalarin zip icinde var oldugunu kontrol edelim
      final pdfEntryName = 'records/${rec1.filePath!.split('/').last}';
      final pdfInZip = archive.findFile(pdfEntryName);
      expect(pdfInZip, isNotNull);
      expect(utf8.decode(pdfInZip!.content as List<int>), 'Delil belgesi verisi');
    });

    test('generateSealCodeMessage gecerli muhur mesaji dondurmelidir', () async {
      final f1 = File('${tempSrcDir.path}/doc.pdf')..writeAsStringSync('test');
      final rec = await recordService.addFileRecord(
        caseId: 'case_seal',
        type: 'document',
        title: 'Belge',
        sourceFile: f1,
      );

      final message = await exportService.generateSealCodeMessage('case_seal');
      expect(message, isNotNull);
      expect(message, contains('[SafeRentHouse Delil Mühür Kodu]'));
      expect(message, contains(rec.chainHash));
      expect(message, contains('case_seal'));
    });
  });

  group('ExportController Tests', () {
    test('exportZip ve generateSealCode controller tarafindan basariyla calistirilmalidir', () async {
      final f1 = File('${tempSrcDir.path}/doc.pdf')..writeAsStringSync('test');
      await recordService.addFileRecord(
        caseId: 'case_ctrl',
        type: 'document',
        title: 'Belge',
        sourceFile: f1,
      );

      final controller = ExportController(exportService);

      final zip = await controller.exportZip('case_ctrl');
      expect(zip, isNotNull);
      expect(controller.status.value, ViewStatus.success);
      expect(controller.createdZipFile.value, isNotNull);

      final msg = await controller.generateSealCode('case_ctrl');
      expect(msg, isNotNull);
      expect(controller.sealCodeMessage.value, isNotNull);

      controller.dispose();
    });
  });
}
