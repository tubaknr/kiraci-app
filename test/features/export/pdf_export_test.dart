import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saferenthouse/core/services/integrity_service.dart';
import 'package:saferenthouse/core/services/pdf_report_service.dart';
import 'package:saferenthouse/features/cases/models/case_model.dart';
import 'package:saferenthouse/features/export/view/export_view.dart';
import 'package:saferenthouse/features/records/models/record_model.dart';

void main() {
  group('PdfReportService & ExportView Tests (Sümeyye - T16)', () {
    test('PdfReportService generates valid non-empty PDF bytes', () async {
      const PdfReportService service = PdfReportService();

      final CaseModel testCase = CaseModel(
        id: 'case_pdf_1',
        title: 'Kadıköy Moda Dairesi',
        address: 'Caferağa Mah. No:12',
        myRole: 'tenant',
        otherPartyName: 'Ali Demir',
        leaseStart: DateTime.utc(2026, 1, 1),
        createdAt: DateTime.utc(2026, 1, 1),
      );

      final List<RecordModel> records = [
        RecordModel(
          id: 'rec_1',
          caseId: 'case_pdf_1',
          type: 'document',
          title: 'Kira Kontratı',
          contentHash: 'hash111111111111111111111111111111',
          prevChainHash: 'GENESIS',
          chainHash: 'chain11111111111111111111111111111',
          recordedAt: DateTime.utc(2026, 1, 1, 10, 0),
          clockAnomaly: false,
        ),
      ];

      final ChainVerificationResult verification = ChainVerificationResult.valid(
        totalRecords: 1,
        lastChainHash: 'chain11111111111111111111111111111',
      );

      final Uint8List pdfBytes = await service.generateReportPdf(
        caseModel: testCase,
        records: records,
        verification: verification,
      );

      expect(pdfBytes, isNotEmpty);
      // PDF header standard magic bytes: %PDF-
      expect(String.fromCharCodes(pdfBytes.sublist(0, 5)), '%PDF-');
    });

    testWidgets('ExportView renders PDF, ZIP, and Seal Code cards',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ExportView(caseId: 'case_export_1'),
        ),
      );

      expect(find.text('Rapor ve Delil Paylaşımı'), findsOneWidget);
      expect(find.text('Resmi Delil Özeti (PDF Rapor)'), findsOneWidget);
      expect(find.text('Tam Delil Paketi (ZIP)'), findsOneWidget);
      expect(find.text('Mühür Kodu Gönder (Dış Çapa)'), findsOneWidget);
      expect(find.text('PDF Oluştur ve Yazdır'), findsOneWidget);
      expect(find.text('ZIP Paketini Dışa Aktar'), findsOneWidget);
    });
  });
}
