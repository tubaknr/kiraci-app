import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/core/services/record_service.dart';
import 'package:saferenthouse/features/records/controller/record_add_controller.dart';
import 'package:saferenthouse/features/records/view/record_add_view.dart';

import '../../core/services/record_service_test.dart';

void main() {
  group('RecordAddView Widget Tests (Sümeyye - T09)', () {
    late Directory tempAppDir;
    late InMemoryRecordRepository recordRepo;
    late RecordService recordService;
    late RecordAddController controller;

    setUp(() async {
      tempAppDir = await Directory.systemTemp.createTemp('saferent_test_app_');
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

    testWidgets('RecordAddView renders all input elements and type chips',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RecordAddView(
            caseId: 'case_1',
            controller: controller,
          ),
        ),
      );

      expect(find.text('Yeni Delil / Belge Ekle'), findsOneWidget);
      expect(find.text('Kayıt Türü'), findsOneWidget);
      expect(find.text('Belge'), findsOneWidget);
      expect(find.text('Fotoğraf'), findsOneWidget);
      expect(find.text('Foto Çek'), findsOneWidget);
      expect(find.text('Kayıt Başlığı *'), findsOneWidget);
      expect(find.text('Delil Zincirine Mühürle'), findsOneWidget);
    });

    testWidgets('Submitting without a file triggers snackbar warning',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: RecordAddView(
            caseId: 'case_1',
            controller: controller,
          ),
        ),
      );

      final submitFinder = find.widgetWithText(ElevatedButton, 'Delil Zincirine Mühürle');
      await tester.scrollUntilVisible(
        submitFinder,
        100.0,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();

      expect(
        find.text('Lütfen bir delil/belge dosyası seçin veya foto çekin.'),
        findsOneWidget,
      );
    });
  });
}
