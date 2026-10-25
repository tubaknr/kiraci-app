import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../models/record_model.dart';

/// Delil teknik özellikleri ve SHA-256 hash kutusu (Sümeyye - T12 - Stitch UI)
class RecordTechnicalSpecsCard extends StatelessWidget {
  final RecordModel record;

  const RecordTechnicalSpecsCard({super.key, required this.record});

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$label panoya kopyalandı')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderCol(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardHeader(),
          const SizedBox(height: 12),
          _buildSubjectBox(context),
          const SizedBox(height: 10),
          _buildTwoByTwoGrid(),
          const SizedBox(height: 12),
          _buildSha256Box(context),
        ],
      ),
    );
  }

  Widget _buildCardHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.receipt_long_outlined, size: 18, color: AppColors.primary),
            SizedBox(width: 6),
            Text(
              'Delil Teknik Özellikleri',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        _ExifPill(),
      ],
    );
  }

  Widget _buildSubjectBox(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.badgeBlueBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'KAYIT KONUSU',
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted(context)),
          ),
          const SizedBox(height: 2),
          Text(
            record.title,
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain(context)),
          ),
          const SizedBox(height: 2),
          Text(
            'Tür: ${_getTypeLabel(record.type)}',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted(context)),
          ),
        ],
      ),
    );
  }

  Widget _buildTwoByTwoGrid() {
    final String dateStr = record.recordedAt.toLocal().toString().substring(0, 19);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SpecTile(
                title: 'Kayıt Zamanı (Yerel)',
                value: dateStr,
                subtitle: 'TSİ',
              ),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: _SpecTile(
                title: 'Donanım Saati',
                value: '✓ Cihaz Saati',
                subtitle: 'Müdahalesiz',
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _SpecTile(
                title: 'Sıra / Bağlam',
                value: '#${record.id.substring(0, 6).toUpperCase()}',
                subtitle: 'Kasa #${record.caseId}',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _SpecTile(
                title: 'Dosya / Tür',
                value: record.type.toUpperCase(),
                subtitle: record.filePath ?? 'Doğrulanabilir Form',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSha256Box(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.badgeBlueBg.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '# SHA-256 KAYIT ÖZETİ (HASH)',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              GestureDetector(
                onTap: () => _copyToClipboard(context, record.contentHash, 'İçerik özeti'),
                child: const Row(
                  children: [
                    Icon(Icons.copy, size: 12, color: AppColors.primary),
                    SizedBox(width: 3),
                    Text('Kopyala', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SelectableText(
            record.contentHash,
            style: TextStyle(fontFamily: 'monospace', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMain(context)),
          ),
          const Divider(height: 16),
          _buildHashSnippet(context, 'Önceki Blok:', record.prevChainHash),
          const SizedBox(height: 4),
          _buildHashSnippet(context, 'Mevcut Düğüm:', record.chainHash),
        ],
      ),
    );
  }

  Widget _buildHashSnippet(BuildContext context, String label, String hash) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: AppColors.textMuted(context))),
        const SizedBox(width: 6),
        Expanded(
          child: SelectableText(
            hash,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 10, color: AppColors.primary),
          ),
        ),
      ],
    );
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

class _ExifPill extends StatelessWidget {
  const _ExifPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.badgeBlueBg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'Orijinal Ham Exif',
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.badgeBlueText),
      ),
    );
  }
}

class _SpecTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;

  const _SpecTile({required this.title, required this.value, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.cardBg(context),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.borderCol(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 9, color: AppColors.textMuted(context))),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMain(context)), maxLines: 1, overflow: TextOverflow.ellipsis),
          Text(subtitle, style: TextStyle(fontSize: 9, color: AppColors.textMuted(context)), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
