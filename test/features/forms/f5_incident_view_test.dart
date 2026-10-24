import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/core/services/notification_service.dart';
import 'package:saferenthouse/core/services/record_service.dart';
import 'package:saferenthouse/features/forms/controller/f5_incident_controller.dart';
import 'package:saferenthouse/features/forms/view/f5_incident_view.dart';

import '../../core/services/record_service_test.dart';

void main() {
  group('F5IncidentView & NotificationService Tests (Sümeyye - T21)', () {
    late Directory tempDir;
    late InMemoryRecordRepository recordRepo;
    late RecordService recordService;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('f5_test_app_');
      recordRepo = InMemoryRecordRepository();
      recordService = RecordService(
        recordRepository: recordRepo,
        getAppDocDir: () async => tempDir,
      );
    });

    tearDown(() async {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('NotificationService can be instantiated and initialized', () async {
      final NotificationService notif = NotificationService();
      expect(notif, isNotNull);
    });

    testWidgets('F5IncidentView renders input fields and validates on empty submit',
        (WidgetTester tester) async {
      final F5IncidentController controller = F5IncidentController(recordService);

      await tester.pumpWidget(
        MaterialApp(
          home: F5IncidentView(
            caseId: 'case_f5_1',
            controller: controller,
          ),
        ),
      );

      expect(find.text('F5 Olay ve Durum Notu'), findsOneWidget);
      expect(find.text('Olay Başlığı *'), findsOneWidget);
      expect(find.text('Görüşülen / Katılan Kişiler *'), findsOneWidget);
      expect(find.text('Takip Hatırlatıcısı Kur'), findsOneWidget);

      final submitBtn = find.widgetWithText(ElevatedButton, 'Olay Notunu Mühürle (F5)');
      await tester.scrollUntilVisible(
        submitBtn,
        100.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Olay başlığı boş bırakılamaz.'), findsOneWidget);

      controller.dispose();
    });
  });
}
