import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/core/services/record_service.dart';
import 'package:saferenthouse/features/records/controller/record_add_controller.dart';
import 'package:saferenthouse/features/records/view/chat_proof_view.dart';

import '../../core/services/record_service_test.dart';

void main() {
  group('ChatProofView Widget Tests (Sümeyye - T14)', () {
    late Directory tempAppDir;
    late InMemoryRecordRepository recordRepo;
    late RecordService recordService;
    late RecordAddController controller;

    setUp(() async {
      tempAppDir = await Directory.systemTemp.createTemp('chat_proof_app_');
      recordRepo = InMemoryRecordRepository();
      recordService = RecordService(
        recordRepository: recordRepo,
        getAppDocDir: () async => tempAppDir,
      );
      controller = RecordAddController(recordService);
    });

    tearDown(() async {
      controller.dispose();
      if (await tempAppDir.exists()) {
        await tempAppDir.delete(recursive: true);
      }
    });

    testWidgets('ChatProofView displays legal warning banner and platform chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChatProofView(
            caseId: 'case_chat_1',
            controller: controller,
          ),
        ),
      );

      expect(find.text('Yazışma / İletişim Kanıtı'), findsOneWidget);
      expect(find.text('Hukuki Uyarı & Kişisel Veriler (KVKK)'), findsOneWidget);
      expect(find.text('WhatsApp'), findsOneWidget);
      expect(find.text('SMS'), findsOneWidget);
      expect(find.text('E-Posta'), findsOneWidget);
      expect(find.text('Galeriden Seç'), findsOneWidget);
    });

    testWidgets('Submitting without a screenshot triggers snackbar warning',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ChatProofView(
            caseId: 'case_chat_1',
            controller: controller,
          ),
        ),
      );

      final submitBtn = find.widgetWithText(ElevatedButton, 'Konuşma Kanıtını Zincire Ekle');
      await tester.scrollUntilVisible(
        submitBtn,
        100.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(find.text('Lütfen bir yazışma ekran görüntüsü seçin.'), findsOneWidget);
    });
  });
}
