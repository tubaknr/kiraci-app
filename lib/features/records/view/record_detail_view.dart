import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/record_service.dart';
import '../controller/record_add_controller.dart';
import '../models/record_model.dart';
import 'record_add_view.dart';

/// Kayıt Detayı ve Zincir Doğrulama Rozeti Ekranı (Sümeyye - T12)
class RecordDetailView extends StatelessWidget {
  final RecordModel record;

  const RecordDetailView({super.key, required this.record});

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label panoya kopyalandı')),
    );
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delil Kayıt Detayı'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 12),
            if (record.correctsRecordId != null) ...[
              _buildCorrectionBanner(),
              const SizedBox(height: 12),
            ],
            if (record.clockAnomaly) ...[
              _buildClockAnomalyBanner(),
              const SizedBox(height: 12),
            ],
            _buildCryptographicCard(context),
            const SizedBox(height: 12),
            _buildMetadataCard(),
            const SizedBox(height: 16),
            _buildCorrectionButton(context),
            const SizedBox(height: 12),
            _buildHonestNotice(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildTypeAvatar(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.title,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tür: ${_getTypeLabel(record.type)} • ID: #${record.id.substring(0, 8)}',
                        style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (record.note != null && record.note!.isNotEmpty) ...[
              const Divider(height: 24),
              const Text(
                'Açıklama / Not:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                record.note!,
                style: const TextStyle(fontSize: 13, height: 1.4),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeAvatar() {
    return CircleAvatar(
      radius: 22,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: Icon(
        _getIconForType(record.type),
        color: AppColors.primary,
        size: 24,
      ),
    );
  }

  Widget _buildCorrectionBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.info),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_note, color: AppColors.info),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Bu kayıt, #${record.correctsRecordId!.substring(0, 8)} numaralı kaydın düzeltmesidir (Append-only revizyonu).',
              style: const TextStyle(fontSize: 12, color: AppColors.info),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClockAnomalyBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Saat Anomalisi: Bu kaydın cihaz saati, önceki kayıtlardan daha eski bir tarihe ayarlanmıştır. Geriye dönük müdahale şüphesi.',
              style: TextStyle(fontSize: 12, color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCryptographicCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.shield_outlined, color: AppColors.secondary, size: 20),
                SizedBox(width: 8),
                Text(
                  'Kriptografik Bütünlük (SHA-256)',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const Divider(height: 20),
            _buildHashRow(context, 'İçerik Özeti (content_hash)', record.contentHash),
            _buildHashRow(context, 'Önceki Düğüm Özeti (prev_chain_hash)', record.prevChainHash),
            _buildHashRow(context, 'Mevcut Düğüm Özeti (chain_hash)', record.chainHash),
          ],
        ),
      ),
    );
  }

  Widget _buildHashRow(BuildContext context, String label, String hash) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary)),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: SelectableText(
                  hash,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy, size: 16),
                tooltip: 'Kopyala',
                onPressed: () => _copyToClipboard(context, hash, label),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetadataCard() {
    final String dateLocal = record.recordedAt.toLocal().toString().substring(0, 19);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Dosya ve Zaman Bilgileri',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const Divider(height: 20),
            _buildMetaRow('Kayıt Zamanı (Cihaz)', dateLocal),
            if (record.filePath != null) _buildMetaRow('Uygulama İçi Dosya', record.filePath!),
            _buildMetaRow('Saat Güvenilirliği', record.clockAnomaly ? 'Şüpheli (Anomali)' : 'Normal'),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrectionButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _openCorrection(context),
      icon: const Icon(Icons.edit_note),
      label: const Text('Bu Kayda Düzeltme / Revizyon Ekle'),
    );
  }

  Widget _buildHonestNotice() {
    return const Center(
      child: Text(
        'Append-only ilkesi gereği kayıtlar silinemez veya değiştirilemez.\nDüzeltmeler yeni bir zincir halkası olarak eklenir.',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11, color: AppColors.lightTextHint),
      ),
    );
  }

  static IconData _getIconForType(String type) {
    switch (type) {
      case 'f1_lease':
      case 'f2_handover':
      case 'f3_defect':
      case 'f4_payment':
      case 'f5_incident':
        return Icons.assignment_outlined;
      case 'photo':
        return Icons.photo_camera_outlined;
      case 'video':
        return Icons.videocam_outlined;
      case 'audio':
        return Icons.mic_outlined;
      case 'chat':
        return Icons.chat_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  static String _getTypeLabel(String type) {
    switch (type) {
      case 'f1_lease':
        return 'F1 Kira Sözleşmesi';
      case 'f2_handover':
        return 'F2 Teslim/Tahliye Formu';
      case 'f3_defect':
        return 'F3 Arıza/Onarım Formu';
      case 'f4_payment':
        return 'F4 Kira/Depozito Ödeme Formu';
      case 'f5_incident':
        return 'F5 Olay ve Durum Notu';
      case 'photo':
        return 'Fotoğraf Kanıtı';
      case 'video':
        return 'Video Kanıtı';
      case 'audio':
        return 'Ses Kaydı';
      case 'chat':
        return 'Yazışma Kanıtı';
      default:
        return 'Belge Delili';
    }
  }
}
