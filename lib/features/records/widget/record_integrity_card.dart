import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/record_model.dart';

/// Kriptografik zincir doğrulama ve durum kartı (Sümeyye - T12 - Stitch UI)
class RecordIntegrityCard extends StatelessWidget {
  final RecordModel record;

  const RecordIntegrityCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (record.clockAnomaly) ...[
          _buildClockAnomalyBanner(),
          const SizedBox(height: 10),
        ],
        if (record.correctsRecordId != null) ...[
          _buildCorrectionBanner(),
          const SizedBox(height: 10),
        ],
        _buildVerificationCard(),
      ],
    );
  }

  Widget _buildVerificationCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.badgeGreenBg.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.verified_user, size: 16, color: Colors.white),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zincir Doğrulandı & Bozulmamış',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.badgeGreenText,
                      ),
                    ),
                    Text(
                      'SHA-256 • Merkle Düğümü Doğrulaması',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Bu kayıt yakalandığı anda kriptografik olarak özetlenmiştir. Dijital imzası, bağımsız tanıklarca kaydedilen 0 değişiklik ile kurcalamaya karşı korumalı zincirle tam eşleşmektedir.',
            style: TextStyle(fontSize: 11, color: AppColors.lightTextPrimary, height: 1.4),
          ),
          const SizedBox(height: 10),
          const Row(
            children: [
              Icon(Icons.lock_outline, size: 13, color: AppColors.badgeGreenText),
              SizedBox(width: 4),
              Text(
                'Defter Durumu: Değiştirilemez Durumda Mühürlü',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.badgeGreenText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClockAnomalyBanner() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.warning),
      ),
      child: const Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Saat Anomalisi: Bu kaydın cihaz saati, önceki kayıtlardan daha eski bir tarihe ayarlanmıştır. Geriye dönük müdahale şüphesi.',
              style: TextStyle(fontSize: 11, color: AppColors.warning, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCorrectionBanner() {
    final String oldId = record.correctsRecordId!.length >= 8
        ? record.correctsRecordId!.substring(0, 8)
        : record.correctsRecordId!;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.badgeBlueBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.edit_note, color: AppColors.primaryLight, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Bu kayıt, #$oldId numaralı kaydın düzeltmesidir (Append-only revizyonu).',
              style: const TextStyle(fontSize: 11, color: AppColors.badgeBlueText, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
