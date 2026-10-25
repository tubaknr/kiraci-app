import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/record_model.dart';

/// Olay anlatısı ve ilgili not kartı (Sümeyye - T12 - Stitch UI)
class RecordNarrativeCard extends StatelessWidget {
  final RecordModel record;

  const RecordNarrativeCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    if (record.note == null || record.note!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 10),
          _buildNoteBubble(),
          const SizedBox(height: 10),
          _buildAttachmentTile(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return const Row(
      children: [
        Icon(Icons.notes_rounded, size: 18, color: AppColors.primary),
        SizedBox(width: 6),
        Text(
          'Olay Anlatısı & İlgili Notlar',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildNoteBubble() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.badgeBlueBg.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kullanıcı Tarafından Kaydedilen Açıklama / Not:',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            record.note!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.lightTextPrimary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentTile() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.badgeIndigoBg.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.verified_outlined, size: 14, color: AppColors.primary),
              SizedBox(width: 6),
              Text(
                'Değiştirilemez Delil Kaydı Onaylandı',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Icon(Icons.attach_file, size: 14, color: AppColors.lightTextSecondary),
        ],
      ),
    );
  }
}
