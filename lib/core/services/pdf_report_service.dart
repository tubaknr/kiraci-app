import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../features/cases/models/case_model.dart';
import '../../features/records/models/record_model.dart';
import 'integrity_service.dart';

/// PDF Delil Raporu Oluşturucu Servisi (Sümeyye - T16)
class PdfReportService {
  const PdfReportService();

  static String _clean(String text) {
    return text
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'I')
        .replaceAll('ş', 's')
        .replaceAll('Ş', 'S')
        .replaceAll('ğ', 'g')
        .replaceAll('Ğ', 'G')
        .replaceAll('ü', 'u')
        .replaceAll('Ü', 'U')
        .replaceAll('ö', 'o')
        .replaceAll('Ö', 'O')
        .replaceAll('ç', 'c')
        .replaceAll('Ç', 'C')
        .replaceAll('•', '-');
  }

  Future<Uint8List> generateReportPdf({
    required CaseModel caseModel,
    required List<RecordModel> records,
    required ChainVerificationResult verification,
  }) async {
    final pw.Document pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            _buildHeader(),
            pw.SizedBox(height: 12),
            _buildCaseInfoBox(caseModel),
            pw.SizedBox(height: 12),
            _buildVerificationSummary(verification, records.length),
            pw.SizedBox(height: 12),
            _buildLegalDisclaimer(),
            pw.SizedBox(height: 16),
            _buildRecordsTable(records),
          ];
        },
        footer: (pw.Context context) {
          return _buildFooter(context, verification);
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          'SafeRentHouse - Dogrulanabilir Delil ve Kayit Raporu',
          style: const pw.TextStyle(
            fontSize: 16,
            color: PdfColors.blue900,
          ),
        ),
        pw.SizedBox(height: 2),
        pw.Text(
          'Kriptografik SHA-256 Hash Zinciri ve Zaman Cizelgesi Ozeti',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
        pw.Divider(thickness: 1.5, color: PdfColors.blue900),
      ],
    );
  }

  pw.Widget _buildCaseInfoBox(CaseModel caseModel) {
    final String startDate = caseModel.leaseStart.toIso8601String().substring(0, 10);
    final String roleStr = caseModel.myRole == 'tenant' ? 'Kiraci' : 'Ev Sahibi';

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Dosya Basligi: ${_clean(caseModel.title)}',
              style: const pw.TextStyle(fontSize: 11)),
          pw.SizedBox(height: 2),
          pw.Text('Tasinmaz Adresi: ${_clean(caseModel.address)}', style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 2),
          pw.Text('Kullanici Rolu: $roleStr  |  Karsi Taraf: ${_clean(caseModel.otherPartyName)}',
              style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(height: 2),
          pw.Text('Kira Baslangic Tarihi: $startDate',
              style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  pw.Widget _buildVerificationSummary(ChainVerificationResult verification, int count) {
    final bool isValid = verification.isValid;
    final PdfColor color = isValid ? PdfColors.green800 : PdfColors.red800;
    final String title = isValid
        ? 'Zincir Butunlugu: DOGRULANDI (Tahrifat Yok)'
        : 'Zincir Butunlugu: BOZULMA TESPIT EDILDI';
    final String details = isValid
        ? 'Toplam $count kayit matematiksel olarak zincirlenmistir. Son Muhur: ${verification.lastChainHash ?? "GENESIS"}'
        : 'Hata: ${_clean(verification.failureReason ?? "Veri tahrifati algilandi!")}';

    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: isValid ? PdfColors.green50 : PdfColors.red50,
        border: pw.Border.all(color: color),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 11, color: color)),
          pw.SizedBox(height: 2),
          pw.Text(details, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
        ],
      ),
    );
  }

  pw.Widget _buildLegalDisclaimer() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        color: PdfColors.amber50,
        border: pw.Border.all(color: PdfColors.amber700),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Text(
        'ONEMLI BILGILENDIRME: Bu rapor sunucusuz yerel veri tabani uzerinden uretilmistir. Kayit zaman damgalari cihaz saatini referans alir. Saat anomalisi tespit edilen kayitlar asagidaki tabloda isaretlenmistir. Kayitlarin delil gecerliligi mahkemenin takdirindedir.',
        style: const pw.TextStyle(fontSize: 8, color: PdfColors.brown900),
      ),
    );
  }

  pw.Widget _buildRecordsTable(List<RecordModel> records) {
    if (records.isEmpty) {
      return pw.Center(
        child: pw.Text('Bu dosyada henuz kayitli delil bulunmamaktadir.',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
      );
    }

    final headers = ['No', 'Tarih (UTC)', 'Tur / Baslik', 'Saat', 'Icerik SHA-256', 'Zincir Hash'];

    final data = records.asMap().entries.map((entry) {
      final index = entry.key + 1;
      final r = entry.value;
      final dateStr = r.recordedAt.toIso8601String().substring(0, 16);
      final clockStr = r.clockAnomaly ? 'ANOMALI' : 'Normal';
      final contentShort = r.contentHash.length >= 10 ? '${r.contentHash.substring(0, 10)}...' : r.contentHash;
      final chainShort = r.chainHash.length >= 10 ? '${r.chainHash.substring(0, 10)}...' : r.chainHash;

      return [
        index.toString(),
        dateStr,
        '${r.type}\n${_clean(r.title)}',
        clockStr,
        contentShort,
        chainShort,
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: const pw.TextStyle(fontSize: 8, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.blue900),
      cellStyle: const pw.TextStyle(fontSize: 8),
      cellHeight: 24,
      cellAlignments: {
        0: pw.Alignment.center,
        1: pw.Alignment.centerLeft,
        2: pw.Alignment.centerLeft,
        3: pw.Alignment.center,
        4: pw.Alignment.centerLeft,
        5: pw.Alignment.centerLeft,
      },
    );
  }

  pw.Widget _buildFooter(pw.Context context, ChainVerificationResult verification) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 0.5, color: PdfColors.grey400),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'SafeRentHouse | Muhur Kodu: ${verification.lastChainHash?.substring(0, 16) ?? "GENESIS"}...',
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
            ),
            pw.Text(
              'Sayfa ${context.pageNumber} / ${context.pagesCount}',
              style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey600),
            ),
          ],
        ),
      ],
    );
  }
}
