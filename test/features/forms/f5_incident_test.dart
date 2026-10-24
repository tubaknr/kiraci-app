import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/core/constants/view_status.dart';
import 'package:saferenthouse/core/services/record_service.dart';
import 'package:saferenthouse/features/forms/controller/f5_incident_controller.dart';
import 'package:saferenthouse/features/forms/models/f5_incident_data.dart';

import '../../core/services/record_service_test.dart';

void main() {
  late Directory tempAppDir;
  late InMemoryRecordRepository recordRepo;
  late RecordService recordService;
  late F5IncidentController controller;

  setUp(() async {
    tempAppDir = await Directory.systemTemp.createTemp('f5_test_');
    recordRepo = InMemoryRecordRepository();
    recordService = RecordService(
      recordRepository: recordRepo,
      getAppDocDir: () async => tempAppDir,
    );
    controller = F5IncidentController(recordService);
  });

  tearDown(() async {
    controller.dispose();
    if (await tempAppDir.exists()) {
      await tempAppDir.delete(recursive: true);
    }
  });

  group('F5Incident Tests (Model & Controller)', () {
    test('Eksik alanlarda F5 dogrulama hatasi vermelidir', () {
      final invalid = F5IncidentData(
        incidentTitle: '',
        incidentDate: DateTime.now(),
        partiesInvolved: '  ',
        summary: '',
      );

      final errors = F5IncidentData.validate(invalid);
      expect(errors['incident_title'], isNotNull);
      expect(errors['parties_involved'], isNotNull);
      expect(errors['summary'], isNotNull);
    });

    test('Gecerli F5 verisi submit edildiginde kayit zincire eklenmelidir', () async {
      final valid = F5IncidentData(
        incidentTitle: 'Aidat Artışı Hakkında Sözlü Görüşme',
        incidentDate: DateTime.now(),
        partiesInvolved: 'Apartman Yöneticisi Hasan Bey',
        location: 'Bina Girişi',
        summary: 'Yönetici aidatın 2000 TL olduğunu belirtti, yazılı karar istendi.',
      );

      final success = await controller.submit(
        caseId: 'case_f5',
        data: valid,
      );

      expect(success, isTrue);
      expect(controller.status.value, ViewStatus.success);
      expect(controller.createdRecord.value, isNotNull);
      expect(controller.createdRecord.value!.formType, 'F5');
      expect(controller.createdRecord.value!.type, 'form');
      expect(recordRepo.storage.length, 1);
    });
  });
}
