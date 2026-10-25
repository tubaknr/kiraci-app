import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Kasalar başlığı ve kriptografik defter doğrulama paneli (Sümeyye - T07 - Stitch UI)
class CasesIntegrityBanner extends StatelessWidget {
  final int totalRecords;

  const CasesIntegrityBanner({
    super.key,
    this.totalRecords = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        children: [
          _buildLiveVaultBadge(context),
          const SizedBox(height: 10),
          _buildVerificationCard(context),
        ],
      ),
    );
  }

  Widget _buildLiveVaultBadge(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.shield_outlined, size: 15, color: AppColors.primaryCol(context)),
            const SizedBox(width: 6),
            Text(
              'Belgelenmiş Kiralık Mülkler & Delil Kasalar',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted(context),
              ),
            ),
          ],
        ),
        const _LivePill(),
      ],
    );
  }

  Widget _buildVerificationCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderCol(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.badgeGreenBgColor(context),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.verified,
              size: 20,
              color: AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Kriptografik Defter Doğrulandı',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textMain(context),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.badgeGreenBgColor(context),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Eşitlendi',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.badgeGreenTextColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Bütünlük kontrolü başarılı: $totalRecords adet SHA-256 özeti müdahale edilemez defter ile eşleşiyor.',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted(context),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LivePill extends StatelessWidget {
  const _LivePill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.badgeGreenBgColor(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(radius: 3, backgroundColor: AppColors.success),
          const SizedBox(width: 4),
          Text(
            'Kasa Canlı',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.badgeGreenTextColor(context),
            ),
          ),
        ],
      ),
    );
  }
}
