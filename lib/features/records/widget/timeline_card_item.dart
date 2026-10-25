import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/record_model.dart';

/// Zaman tüneli kronolojik delil kartı ve sol bağlantı çizgisi (Sümeyye - T10 - Stitch UI)
class TimelineCardItem extends StatelessWidget {
  final RecordModel record;
  final int index;
  final int totalCount;
  final VoidCallback onTap;

  const TimelineCardItem({
    super.key,
    required this.record,
    required this.index,
    required this.totalCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTimelineIndicator(context),
          const SizedBox(width: 10),
          Expanded(child: _buildCardContent(context)),
        ],
      ),
    );
  }

  Widget _buildTimelineIndicator(BuildContext context) {
    final bool isLast = index == totalCount - 1;
    final bool isAnomaly = record.clockAnomaly;

    return SizedBox(
      width: 24,
      child: Column(
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardBg(context),
              border: Border.all(
                color: isAnomaly ? AppColors.warning : AppColors.secondary,
                width: 3,
              ),
            ),
          ),
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                color: AppColors.borderCol(context),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCardContent(BuildContext context) {
    final String dateStr = record.recordedAt.toLocal().toString().substring(0, 16);
    final String blockNum = (totalCount - index).toString().padLeft(2, '0');
    final bool isGenesis = index == totalCount - 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderCol(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardHeader(context, dateStr, blockNum, isGenesis),
                const SizedBox(height: 10),
                _buildCardTitleAndCategory(context),
                const SizedBox(height: 6),
                _buildDescriptionText(context),
                const SizedBox(height: 10),
                _buildSpecializedPreview(context),
                const SizedBox(height: 10),
                _buildIntegrityFooter(context, isGenesis),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context, String dateStr, String blockNum, bool isGenesis) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.access_time_rounded, size: 12, color: AppColors.textMuted(context)),
            const SizedBox(width: 4),
            Text(
              dateStr,
              style: TextStyle(fontSize: 11, color: AppColors.textMuted(context)),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: isGenesis ? AppColors.badgeIndigoBgColor(context) : AppColors.badgeBlueBgColor(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            isGenesis ? 'İlk Blok Kayıt #01' : 'Zincirde #$blockNum',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isGenesis ? AppColors.badgeIndigoTextColor(context) : AppColors.badgeBlueTextColor(context),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardTitleAndCategory(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.badgeBlueBgColor(context),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(_getIconForType(record.type), size: 16, color: AppColors.primaryCol(context)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getCategoryLabel(record.type),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: AppColors.primaryCol(context),
                ),
              ),
              Text(
                record.title,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain(context)),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionText(BuildContext context) {
    final String text = record.note != null && record.note!.isNotEmpty
        ? record.note!
        : 'Doğrulanmış ${record.type} kaydı oluşturuldu ve SHA-256 zincirine eklendi.';

    return Text(
      text,
      style: TextStyle(fontSize: 12, color: AppColors.textMuted(context), height: 1.4),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSpecializedPreview(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.badgeBlueBgColor(context),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.attach_file, size: 14, color: AppColors.primaryCol(context)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              record.filePath ?? 'Doğrulanabilir Kriptografik Veri',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMain(context)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.chevron_right, size: 14, color: AppColors.textMuted(context)),
        ],
      ),
    );
  }

  Widget _buildIntegrityFooter(BuildContext context, bool isGenesis) {
    final String hashShort = record.chainHash.length >= 10
        ? '${record.chainHash.substring(0, 4)}...${record.chainHash.substring(record.chainHash.length - 4)}'
        : record.chainHash;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.badgeGreenBgColor(context),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 12, color: AppColors.badgeGreenTextColor(context)),
          const SizedBox(width: 4),
          Text(
            isGenesis
                ? 'Zincir Doğrulandı (İlk Blok Kayıt #01)'
                : 'Zincir Doğrulandı (SHA-256: $hashShort)',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.badgeGreenTextColor(context)),
          ),
        ],
      ),
    );
  }

  static IconData _getIconForType(String type) {
    switch (type) {
      case 'f4_payment':
        return Icons.account_balance_outlined;
      case 'photo':
        return Icons.camera_alt_outlined;
      case 'chat':
        return Icons.chat_bubble_outline;
      case 'f1_lease':
      case 'f2_handover':
        return Icons.description_outlined;
      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  static String _getCategoryLabel(String type) {
    switch (type) {
      case 'f4_payment':
        return 'BANKA HAVALE / KİRA DEKONTU';
      case 'photo':
        return 'TADİLAT / HASAR FOTOĞRAFI';
      case 'chat':
        return 'YAZIŞMA KANITI';
      case 'f1_lease':
        return 'KİRA SÖZLEŞMESİ';
      default:
        return 'DELİL BELGESİ';
    }
  }
}
