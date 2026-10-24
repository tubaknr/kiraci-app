import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/core/services/record_service.dart';
import 'package:saferenthouse/features/forms/controller/f3_defect_controller.dart';
import 'package:saferenthouse/features/forms/controller/f4_payment_controller.dart';
import 'package:saferenthouse/features/forms/view/f3_defect_view.dart';
import 'package:saferenthouse/features/forms/view/f4_payment_view.dart';
import 'package:saferenthouse/features/forms/view/forms_menu_view.dart';

import '../../core/services/record_service_test.dart';

void main() {
  group('FormsMenuView, F3DefectView & F4PaymentView Widget Tests (Sümeyye - T18)', () {
    late Directory tempDir;
    late InMemoryRecordRepository recordRepo;
    late RecordService recordService;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('forms_test_app_');
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

    testWidgets('FormsMenuView displays list of all 5 structured forms',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: FormsMenuView(currentCaseId: 'case_f_1'),
        ),
      );

      expect(find.text('Yapılandırılmış Formlar'), findsOneWidget);
      expect(find.text('Sözleşme Bilgi Formu'), findsOneWidget);
      expect(find.text('Teslim / Tahliye Tespit Formu'), findsOneWidget);
      expect(find.text('Arıza / Sorun Bildirim Formu'), findsOneWidget);
      expect(find.text('Kira & Ödeme Bildirim Formu'), findsOneWidget);
      expect(find.text('Olay ve Durum Notu Formu'), findsOneWidget);
    });

    testWidgets('F3DefectView renders categories and validates empty submit',
        (WidgetTester tester) async {
      final F3DefectController controller = F3DefectController(recordService);

      await tester.pumpWidget(
        MaterialApp(
          home: F3DefectView(
            caseId: 'case_f_1',
            controller: controller,
          ),
        ),
      );

      expect(find.text('F3 Arıza / Sorun Bildirimi'), findsOneWidget);
      expect(find.text('Arıza Kategorisi *'), findsOneWidget);
      expect(find.text('Arıza Başlığı *'), findsOneWidget);

      final submitBtn = find.widgetWithText(ElevatedButton, 'Arıza Bildirimini Mühürle (F3)');
      await tester.scrollUntilVisible(
        submitBtn,
        100.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Arıza başlığı boş bırakılamaz.'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('F4PaymentView renders payment fields and validates empty submit',
        (WidgetTester tester) async {
      final F4PaymentController controller = F4PaymentController(recordService);

      await tester.pumpWidget(
        MaterialApp(
          home: F4PaymentView(
            caseId: 'case_f_1',
            controller: controller,
          ),
        ),
      );

      expect(find.text('F4 Kira & Ödeme Kaydı'), findsOneWidget);
      expect(find.text('Ödeme Türü *'), findsOneWidget);
      expect(find.text('Tutar (TL) *'), findsOneWidget);

      final submitBtn = find.widgetWithText(ElevatedButton, 'Ödeme Kaydını Zincire Ekle (F4)');
      await tester.scrollUntilVisible(
        submitBtn,
        100.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Ödeme tutarı 0\'dan büyük olmalıdır.'), findsOneWidget);

      controller.dispose();
    });
  });
}
