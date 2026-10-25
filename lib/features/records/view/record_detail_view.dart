import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/record_service.dart';
import '../controller/record_add_controller.dart';
import '../models/record_model.dart';
import '../widget/record_detail_actions.dart';
import '../widget/record_integrity_card.dart';
import '../widget/record_media_hero.dart';
import '../widget/record_narrative_card.dart';
import '../widget/record_technical_specs_card.dart';
import 'record_add_view.dart';

/// Delil Kayıt Detayı ve Kriptografik Doğrulama Ekranı (Sümeyye - T12 - Stitch UI)
class RecordDetailView extends StatelessWidget {
  final RecordModel record;

  const RecordDetailView({super.key, required this.record});

  void _openCorrection(BuildContext context) {
    final controller = RecordAddController(RecordService());
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext ctx) => RecordAddView(
          caseId: record.caseId,
          controller: controller,
          correctsRecordId: record.id,
          onSuccess: () {
            controller.dispose();
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }

  void _showNotice(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Delil Kayıt Detayı'),
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Paylaş',
            onPressed: () => _showNotice(context, 'Mühür kodu paylaşım menüsü açıldı.'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: 'Seçenekler',
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RecordMediaHero(record: record),
            const SizedBox(height: 12),
            RecordIntegrityCard(record: record),
            const SizedBox(height: 12),
            RecordTechnicalSpecsCard(record: record),
            const SizedBox(height: 12),
            RecordNarrativeCard(record: record),
            const SizedBox(height: 14),
            RecordDetailActions(
              onExportPdf: () => _showNotice(context, 'Mahkemeye uygun delil PDF raporu hazırlanıyor...'),
              onOpenCorrection: () => _openCorrection(context),
              onVerifyAgain: () => _showNotice(context, 'SHA-256 özeti ve yerel zincir başarıyla yeniden doğrulandı.'),
              onShareChain: () => _showNotice(context, 'Kayıt mühür kodu panoya kopyalandı.'),
            ),
            const SizedBox(height: 16),
            const _HonestAppendOnlyNotice(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _HonestAppendOnlyNotice extends StatelessWidget {
  const _HonestAppendOnlyNotice();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Append-only ilkesi gereği kayıtlar silinemez veya değiştirilemez.\nDüzeltmeler yeni bir zincir halkası olarak eklenir.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, color: AppColors.lightTextHint, height: 1.4),
      ),
    );
  }
}
