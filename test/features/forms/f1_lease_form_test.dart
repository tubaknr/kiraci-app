import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/core/constants/view_status.dart';
import 'package:saferenthouse/core/services/record_service.dart';
import 'package:saferenthouse/features/forms/controller/f1_lease_controller.dart';
import 'package:saferenthouse/features/forms/models/f1_lease_data.dart';
import 'package:saferenthouse/features/forms/view/f1_lease_view.dart';

import '../../core/services/record_service_test.dart';

void main() {
  late Directory tempAppDir;
  late InMemoryRecordRepository recordRepo;
  late RecordService recordService;
  late F1LeaseController controller;

  setUp(() async {
    tempAppDir = await Directory.systemTemp.createTemp('f1_test_');
    recordRepo = InMemoryRecordRepository();
    recordService = RecordService(
      recordRepository: recordRepo,
      getAppDocDir: () async => tempAppDir,
    );
    controller = F1LeaseController(recordService);
  });

  tearDown(() async {
    controller.dispose();
    if (await tempAppDir.exists()) {
      await tempAppDir.delete(recursive: true);
    }
  });

  group('F1LeaseData Model & Validation Tests', () {
    test('Eksik alanlar icin dogrulama hatalari donmelidir', () {
      final invalidData = F1LeaseData(
        tenantName: '',
        landlordName: '   ',
        address: '',
        monthlyRent: 0,
        depositAmount: -50,
        startDate: DateTime.utc(2026, 5, 1),
        endDate: DateTime.utc(2026, 4, 1),
      );

      final errors = F1LeaseData.validate(invalidData);

      expect(errors['tenant_name'], isNotNull);
      expect(errors['landlord_name'], isNotNull);
      expect(errors['address'], isNotNull);
      expect(errors['monthly_rent'], isNotNull);
      expect(errors['deposit_amount'], isNotNull);
      expect(errors['end_date'], isNotNull);
    });

    test('Gecerli veriler icin hata donmemelidir', () {
      final validData = F1LeaseData(
        tenantName: 'Ahmet Kiraci',
        landlordName: 'Mehmet Evsahibi',
        address: 'Kadikoy / Istanbul',
        monthlyRent: 20000,
        depositAmount: 40000,
        startDate: DateTime.utc(2026, 1, 1),
        endDate: DateTime.utc(2027, 1, 1),
      );

      final errors = F1LeaseData.validate(validData);
      expect(errors, isEmpty);
    });
  });

  group('F1LeaseController Tests', () {
    test('Gecerli form submit edildiginde kayit olusturulmali ve zincire eklenmelidir', () async {
      final validData = F1LeaseData(
        tenantName: 'Ahmet Kiraci',
        landlordName: 'Mehmet Evsahibi',
        address: 'Kadikoy / Istanbul',
        monthlyRent: 20000,
        startDate: DateTime.utc(2026, 1, 1),
      );

      final success = await controller.submit(
        caseId: 'case_f1',
        data: validData,
      );

      expect(success, isTrue);
      expect(controller.status.value, ViewStatus.success);
      expect(controller.createdRecord.value, isNotNull);
      expect(controller.createdRecord.value!.formType, 'F1');
      expect(recordRepo.storage.length, 1);
    });

    test('Gecersiz veride controller error donmeli ve fieldErrors doldurulmalidir', () async {
      final invalidData = F1LeaseData(
        tenantName: '',
        landlordName: '',
        address: '',
        monthlyRent: -10,
        startDate: DateTime.utc(2026, 1, 1),
      );

      final success = await controller.submit(
        caseId: 'case_f1',
        data: invalidData,
      );

      expect(success, isFalse);
      expect(controller.status.value, ViewStatus.error);
      expect(controller.fieldErrors.value.isNotEmpty, isTrue);
      expect(recordRepo.storage, isEmpty);
    });
  });

  group('F1LeaseView Widget Tests', () {
    testWidgets('F1 formu alanlari ekranda dogru render edilmelidir', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: F1LeaseView(
            caseId: 'case_view_test',
            controller: controller,
          ),
        ),
      );

      expect(find.text('F1 Sözleşme Bilgi Formu'), findsOneWidget);
      expect(find.text('Kiracı Adı Soyadı *'), findsOneWidget);
      expect(find.text('Ev Sahibi Adı Soyadı *'), findsOneWidget);
      expect(find.text('Doğrula ve Kayda Geçir'), findsOneWidget);
    });
  });
}
