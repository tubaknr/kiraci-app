import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/core/constants/view_status.dart';
import 'package:saferenthouse/core/services/record_service.dart';
import 'package:saferenthouse/features/forms/controller/f3_defect_controller.dart';
import 'package:saferenthouse/features/forms/controller/f4_payment_controller.dart';
import 'package:saferenthouse/features/forms/models/f3_defect_data.dart';
import 'package:saferenthouse/features/forms/models/f4_payment_data.dart';

import '../../core/services/record_service_test.dart';

void main() {
  late Directory tempAppDir;
  late InMemoryRecordRepository recordRepo;
  late RecordService recordService;
  late F3DefectController f3Controller;
  late F4PaymentController f4Controller;

  setUp(() async {
    tempAppDir = await Directory.systemTemp.createTemp('f3_f4_test_');
    recordRepo = InMemoryRecordRepository();
    recordService = RecordService(
      recordRepository: recordRepo,
      getAppDocDir: () async => tempAppDir,
    );
    f3Controller = F3DefectController(recordService);
    f4Controller = F4PaymentController(recordService);
  });

  tearDown(() async {
    f3Controller.dispose();
    f4Controller.dispose();
    if (await tempAppDir.exists()) {
      await tempAppDir.delete(recursive: true);
    }
  });

  group('F3Defect Tests (Model & Controller)', () {
    test('Eksik alanlarda F3 dogrulama hatasi vermeli', () {
      final invalid = F3DefectData(
        defectType: '',
        title: '   ',
        description: '',
        reportedDate: DateTime.now(),
        estimatedCost: -20,
      );

      final errors = F3DefectData.validate(invalid);
      expect(errors['title'], isNotNull);
      expect(errors['description'], isNotNull);
      expect(errors['defect_type'], isNotNull);
      expect(errors['estimated_cost'], isNotNull);
    });

    test('Gecerli F3 verisi basariyla submit edilip zincire eklenmeli', () async {
      final valid = F3DefectData(
        defectType: 'su_tesisati',
        title: 'Mutfak Musluk Sızıntısı',
        description: 'Mutfak evye altındaki musluk su damlatıyor, alt dolap şişmeye başladı.',
        urgency: 'high',
        reportedDate: DateTime.now(),
        estimatedCost: 750,
      );

      final success = await f3Controller.submit(
        caseId: 'case_f3',
        data: valid,
      );

      expect(success, isTrue);
      expect(f3Controller.status.value, ViewStatus.success);
      expect(f3Controller.createdRecord.value, isNotNull);
      expect(f3Controller.createdRecord.value!.formType, 'F3');
      expect(f3Controller.createdRecord.value!.type, 'form');
      expect(recordRepo.storage.length, 1);
    });
  });

  group('F4Payment Tests (Model & Controller)', () {
    test('Eksik alanlarda F4 dogrulama hatasi vermeli', () {
      final invalid = F4PaymentData(
        paymentType: 'rent',
        amount: 0,
        period: '',
        paidAt: DateTime.now(),
        payerName: '  ',
        receiverName: '',
      );

      final errors = F4PaymentData.validate(invalid);
      expect(errors['amount'], isNotNull);
      expect(errors['period'], isNotNull);
      expect(errors['payer_name'], isNotNull);
      expect(errors['receiver_name'], isNotNull);
    });

    test('Gecerli F4 verisi basariyla submit edilip zincire eklenmeli', () async {
      final valid = F4PaymentData(
        paymentType: 'rent',
        amount: 25000,
        period: 'Kasım 2026',
        paidAt: DateTime.now(),
        payerName: 'Tuba Aydın',
        receiverName: 'Ev Sahibi Adı',
        receiptNumber: 'DEC2026110199',
      );

      final success = await f4Controller.submit(
        caseId: 'case_f4',
        data: valid,
      );

      expect(success, isTrue);
      expect(f4Controller.status.value, ViewStatus.success);
      expect(f4Controller.createdRecord.value, isNotNull);
      expect(f4Controller.createdRecord.value!.formType, 'F4');
      expect(recordRepo.storage.length, 1);
    });
  });
}
