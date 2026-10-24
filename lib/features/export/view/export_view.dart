import 'dart:io';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/view_status.dart';
import '../../../core/db/case_repository.dart';
import '../../../core/db/record_repository.dart';
import '../../../core/services/export_service.dart';
import '../../../core/services/integrity_service.dart';
import '../../../core/services/pdf_report_service.dart';
import '../../cases/models/case_model.dart';
import '../../records/models/record_model.dart';
import '../controller/export_controller.dart';

/// Dışa Aktar Ekranı: PDF Raporu & ZIP Paketi & Mühür Kodu (Sümeyye - T16)
class ExportView extends StatefulWidget {
  final String caseId;
  final ExportController? controller;

  const ExportView({
    super.key,
    required this.caseId,
    this.controller,
  });

  @override
  State<ExportView> createState() => _ExportViewState();
}

class _ExportViewState extends State<ExportView> {
  late final ExportController _controller;
  final PdfReportService _pdfService = const PdfReportService();
  final CaseRepository _caseRepo = SqliteCaseRepository();
  final RecordRepository _recordRepo = SqliteRecordRepository();
  final IntegrityService _integrityService = IntegrityService();

  bool _isGeneratingPdf = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ExportController(ExportService());
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _exportPdf() async {
    setState(() => _isGeneratingPdf = true);
    try {
      final CaseModel? caseModel = await _caseRepo.getById(widget.caseId);
      final List<RecordModel> records = await _recordRepo.getByCase(widget.caseId);
      final ChainVerificationResult verification =
          await _integrityService.verifyChain(widget.caseId);

      final CaseModel effectiveCase = caseModel ??
          CaseModel(
            id: widget.caseId,
            title: 'Kira Dosyası',
            address: 'Belirtilmedi',
            myRole: 'tenant',
            otherPartyName: 'Karşı Taraf',
            leaseStart: DateTime.now(),
            createdAt: DateTime.now(),
          );

      final pdfBytes = await _pdfService.generateReportPdf(
        caseModel: effectiveCase,
        records: records,
        verification: verification,
      );

      await Printing.layoutPdf(
        onLayout: (_) => pdfBytes,
        name: 'SafeRentHouse_Delil_Raporu_${widget.caseId}.pdf',
      );
    } catch (e) {
      _showSnackbar('PDF rapor oluşturulurken bir hata oluştu.');
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _exportZip() async {
    final File? zip = await _controller.exportZip(widget.caseId);
    if (zip != null && await zip.exists()) {
      await SharePlus.instance.share(
        ShareParams(
          text: 'SafeRentHouse Delil Paketi (#${widget.caseId})',
          files: [XFile(zip.path)],
        ),
      );
    }
  }

  Future<void> _shareSealCode() async {
    final String? message = await _controller.generateSealCode(widget.caseId);
    if (message != null && message.isNotEmpty) {
      await SharePlus.instance.share(
        ShareParams(
          text: message,
          subject: 'SafeRentHouse Delil Zinciri Mühür Kodu',
        ),
      );
    }
  }

  void _showSnackbar(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapor ve Delil Paylaşımı'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildInfoBanner(),
          const SizedBox(height: 16),
          _buildPdfCard(),
          const SizedBox(height: 12),
          _buildZipCard(),
          const SizedBox(height: 12),
          _buildSealCodeCard(),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.secondary),
      ),
      child: const Row(
        children: [
          Icon(Icons.verified_outlined, color: AppColors.secondary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tüm raporlar ve delil paketleri bağımsız SHA-256 doğrulama kodlarıyla üretilir. Mahkemeye veya uzlaşma merciine sunulmaya hazırdır.',
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPdfCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.picture_as_pdf_outlined, color: Colors.red, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Resmi Delil Özeti (PDF Rapor)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Zaman çizelgesi, delil tabloları, içerik özetleri (SHA-256) ve saat güvenilirliği uyarılarını içeren yazdırılabilir rapor.',
              style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isGeneratingPdf ? null : _exportPdf,
                icon: _isGeneratingPdf
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.print_outlined),
                label: Text(_isGeneratingPdf ? 'Rapor Hazırlanıyor...' : 'PDF Oluştur ve Yazdır'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZipCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.archive_outlined, color: AppColors.primary, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tam Delil Paketi (ZIP)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Tüm fotoğraflar, belgeler, form JSON verileri ve kökünde manifest.json doğrulama dosyasını barındıran arşiv.',
              style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 12),
            ValueListenableBuilder<ViewStatus>(
              valueListenable: _controller.status,
              builder: (BuildContext context, ViewStatus status, _) {
                final bool isLoading = status == ViewStatus.loading;
                return SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : _exportZip,
                    icon: const Icon(Icons.share_outlined),
                    label: const Text('ZIP Paketini Dışa Aktar'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSealCodeCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.mark_email_read_outlined, color: AppColors.secondary, size: 28),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Mühür Kodu Gönder (Dış Çapa)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Cihaz saatine olan bağımlılığı azaltmak için mevcut mühür özetini üçüncü taraf bir adrese (örn. kendi e-postanıza) göndererek bağımsız zaman kanıtı oluşturun.',
              style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: _shareSealCode,
                icon: const Icon(Icons.send_outlined),
                label: const Text('Mühür Kodunu E-Postayla Paylaş'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
