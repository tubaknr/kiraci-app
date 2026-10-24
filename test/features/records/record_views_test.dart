import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/features/records/models/record_model.dart';
import 'package:saferenthouse/features/records/view/record_detail_view.dart';

void main() {
  group('RecordDetailView Widget Tests (Sümeyye - T12)', () {
    testWidgets('RecordDetailView displays record fields, hashes, and copy icons',
        (WidgetTester tester) async {
      final RecordModel testRecord = RecordModel(
        id: 'rec_123456789',
        caseId: 'case_1',
        type: 'document',
        title: 'Kira Sözleşmesi Taranmış Belge',
        note: 'Noter tasdikli suret.',
        contentHash: 'aaaa1111bbbb2222cccc3333dddd4444',
        prevChainHash: 'GENESIS',
        chainHash: 'eeee5555ffff6666aaaa7777bbbb8888',
        filePath: 'records/case_1/sozlesme.pdf',
        recordedAt: DateTime.utc(2026, 1, 1, 10, 0),
        clockAnomaly: false,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RecordDetailView(record: testRecord),
        ),
      );

      expect(find.text('Delil Kayıt Detayı'), findsOneWidget);
      expect(find.text('Kira Sözleşmesi Taranmış Belge'), findsOneWidget);
      expect(find.text('Noter tasdikli suret.'), findsOneWidget);
      expect(find.text('aaaa1111bbbb2222cccc3333dddd4444'), findsOneWidget);
      expect(find.text('GENESIS'), findsOneWidget);
      expect(find.text('eeee5555ffff6666aaaa7777bbbb8888'), findsOneWidget);
      expect(find.text('Bu Kayda Düzeltme / Revizyon Ekle'), findsOneWidget);
    });

    testWidgets('RecordDetailView shows clock anomaly and correction banners when present',
        (WidgetTester tester) async {
      final RecordModel testRecord = RecordModel(
        id: 'rec_anomaly_1',
        caseId: 'case_1',
        type: 'photo',
        title: 'Tavan Boyası',
        contentHash: 'hash1',
        prevChainHash: 'prev1',
        chainHash: 'chain1',
        recordedAt: DateTime.utc(2026, 1, 1, 10, 0),
        clockAnomaly: true,
        correctsRecordId: 'rec_old_001',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: RecordDetailView(record: testRecord),
        ),
      );

      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.textContaining('Saat Anomalisi:'), findsOneWidget);
      expect(find.textContaining('düzeltmesidir'), findsOneWidget);
    });
  });
}
