import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/core/constants/view_status.dart';
import 'package:saferenthouse/core/services/record_service.dart';
import 'package:saferenthouse/features/forms/controller/f2_handover_controller.dart';
import 'package:saferenthouse/features/forms/models/f2_handover_data.dart';
import 'package:saferenthouse/features/forms/view/f2_handover_view.dart';

import '../../core/services/record_service_test.dart';

void main() {
  late Directory tempAppDir;
  late InMemoryRecordRepository recordRepo;
  late RecordService recordService;
  late F2HandoverController controller;

  setUp(() async {
    tempAppDir = await Directory.systemTemp.createTemp('f2_test_');
    recordRepo = InMemoryRecordRepository();
    recordService = RecordService(
      recordRepository: recordRepo,
      getAppDocDir: () async => tempAppDir,
    );
    controller = F2HandoverController(recordService);
  });

  tearDown(() async {
    controller.dispose();
    if (await tempAppDir.exists()) {
      await tempAppDir.delete(recursive: true);
    }
  });

  group('F2HandoverData Model & Validation Tests', () {
    test('Eksik alanlar icin dogrulama hatalari donmelidir', () {
      final invalid = F2HandoverData(
        handoverType: 'entry',
        handoverDate: DateTime.now(),
        inspectorName: '',
        electricityMeter: '   ',
        waterMeter: '',
        gasMeter: '',
        keyCount: -1,
        rooms: const [],
      );

      final errors = F2HandoverData.validate(invalid);
      expect(errors['inspector_name'], isNotNull);
      expect(errors['electricity_meter'], isNotNull);
      expect(errors['water_meter'], isNotNull);
      expect(errors['gas_meter'], isNotNull);
      expect(errors['key_count'], isNotNull);
      expect(errors['rooms'], isNotNull);
    });

    test('Gecerli veriler icin hata donmemelidir', () {
      final valid = F2HandoverData(
        handoverType: 'entry',
        handoverDate: DateTime.now(),
        inspectorName: 'Ahmet Bilirkişi',
        electricityMeter: '12450.5',
        waterMeter: '450',
        gasMeter: '890.2',
        keyCount: 2,
        rooms: const [
          RoomCondition(roomName: 'Salon', conditionNote: 'Temiz'),
        ],
      );

      final errors = F2HandoverData.validate(valid);
      expect(errors, isEmpty);
    });
  });

  group('F2HandoverController Tests', () {
    test('Gecerli F2 verisi submit edildiginde kayit F2 olarak zincire eklenmelidir', () async {
      final valid = F2HandoverData(
        handoverType: 'entry',
        handoverDate: DateTime.now(),
        inspectorName: 'Ahmet Bilirkişi',
        electricityMeter: '12450.5',
        waterMeter: '450',
        gasMeter: '890.2',
        keyCount: 2,
        rooms: const [
          RoomCondition(roomName: 'Salon', conditionNote: 'Parkeler iyi'),
        ],
      );

      final success = await controller.submit(
        caseId: 'case_f2',
        data: valid,
      );

      expect(success, isTrue);
      expect(controller.status.value, ViewStatus.success);
      expect(controller.createdRecord.value, isNotNull);
      expect(controller.createdRecord.value!.formType, 'F2');
      expect(controller.createdRecord.value!.title, 'F2 Teslim Alma Tespit Formu');
      expect(recordRepo.storage.length, 1);
    });

    test('Tahliye tipi secildiginde baslik Tahliye olarak uretilmelidir', () async {
      final exitData = F2HandoverData(
        handoverType: 'exit',
        handoverDate: DateTime.now(),
        inspectorName: 'Emlakçı',
        electricityMeter: '15000',
        waterMeter: '600',
        gasMeter: '1000',
        keyCount: 2,
        rooms: const [
          RoomCondition(roomName: 'Salon', conditionNote: 'Duvarlar temizlendi'),
        ],
      );

      final success = await controller.submit(
        caseId: 'case_f2_exit',
        data: exitData,
      );

      expect(success, isTrue);
      expect(controller.createdRecord.value!.title, 'F2 Tahliye Teslim Formu');
    });
  });

  group('F2HandoverView Widget Tests', () {
    testWidgets('F2 formu ekranda dogru render edilmelidir', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: F2HandoverView(
            caseId: 'case_f2_widget',
            controller: controller,
          ),
        ),
      );

      expect(find.text('F2 Teslim / Tahliye Formu'), findsOneWidget);
      expect(find.text('Teslim Alma (Giriş)'), findsOneWidget);
      expect(find.text('Tahliye (Çıkış)'), findsOneWidget);
      expect(find.text('Sayaç Endeksleri'), findsOneWidget);
      expect(find.text('Tutanağı Doğrula ve Kayda Geçir'), findsOneWidget);
    });
  });
}
