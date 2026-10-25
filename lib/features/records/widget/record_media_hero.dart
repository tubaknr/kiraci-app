import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/record_model.dart';

/// Delil medya önizleme ve metadata bindirme bileşeni (Sümeyye - T12 - Stitch UI)
class RecordMediaHero extends StatelessWidget {
  final RecordModel record;

  const RecordMediaHero({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRegisterHeaderTag(),
        const SizedBox(height: 10),
        _buildHeroPreview(context),
      ],
    );
  }

  Widget _buildRegisterHeaderTag() {
    final String seqNumber = record.id.length >= 6
        ? record.id.substring(0, 6).toUpperCase()
        : record.id.toUpperCase();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.hub_outlined, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'KAYIT DEFTERİ #$seqNumber',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: AppColors.lightTextPrimary,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.badgeBlueBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'Dosya: #${record.caseId}',
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.badgeBlueText,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroPreview(BuildContext context) {
    final String dateStr = record.recordedAt.toLocal().toString().substring(0, 19);

    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          _buildBackgroundPlaceholder(),
          _buildTopBadges(),
          _buildBottomOverlay(dateStr),
        ],
      ),
    );
  }

  Widget _buildBackgroundPlaceholder() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFF334155), Color(0xFF0F172A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Icon(
            _getIconForType(record.type),
            size: 64,
            color: Colors.white.withValues(alpha: 0.15),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBadges() {
    return Positioned(
      top: 12,
      left: 12,
      right: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(radius: 3, backgroundColor: AppColors.success),
                const SizedBox(width: 5),
                Text(
                  'HAM KAYIT • ${record.type.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.zoom_in, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'İncele',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomOverlay(String dateStr) {
    return Positioned(
      bottom: 12,
      left: 14,
      right: 14,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Delil No: PL-${record.id.substring(0, 8).toUpperCase()}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Cihaz Zaman Damgası: $dateStr',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.location_on, size: 10, color: Colors.white),
                    SizedBox(width: 3),
                    Text(
                      'Güvenli Delil',
                      style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static IconData _getIconForType(String type) {
    switch (type) {
      case 'photo':
        return Icons.camera_alt_outlined;
      case 'video':
        return Icons.videocam_outlined;
      case 'audio':
        return Icons.mic_outlined;
      case 'chat':
        return Icons.chat_bubble_outline;
      default:
        return Icons.description_outlined;
    }
  }
}
