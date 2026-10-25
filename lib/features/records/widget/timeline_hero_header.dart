import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Zaman çizelgesi kasa özet başlığı ve 3 metrik paneli (Sümeyye - T10 - Stitch UI)
class TimelineHeroHeader extends StatelessWidget {
  final String caseTitle;
  final int recordCount;
  final bool isChainValid;

  const TimelineHeroHeader({
    super.key,
    required this.caseTitle,
    required this.recordCount,
    this.isChainValid = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.badgeBlueBg.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusBadgesRow(),
          const SizedBox(height: 10),
          _buildTitleSection(),
          const SizedBox(height: 14),
          _buildMetricsRow(),
        ],
      ),
    );
  }

  Widget _buildStatusBadgesRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isChainValid ? AppColors.badgeGreenBg : AppColors.badgeAmberBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isChainValid ? Icons.lock_outline : Icons.warning_amber_rounded,
                size: 11,
                color: isChainValid ? AppColors.badgeGreenText : AppColors.badgeAmberText,
              ),
              const SizedBox(width: 4),
              Text(
                isChainValid
                    ? 'Zincir Bütünlüğü: Güvenli [Blok #0$recordCount]'
                    : 'Zincir Uyarısı!',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isChainValid ? AppColors.badgeGreenText : AppColors.badgeAmberText,
                ),
              ),
            ],
          ),
        ),
        Text(
          '$recordCount Doğrulanmış Kayıt',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          caseTitle.isNotEmpty ? caseTitle : 'Kira Dosyası Zaman Tüneli',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: AppColors.lightTextPrimary,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Değiştirilemez kiracı defteri ve kronolojik delil izi',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.lightTextSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricsRow() {
    return const Row(
      children: [
        Expanded(
          child: _HeroMetric(
            title: 'Başlangıç',
            value: 'Eyl 2024',
            valueColor: AppColors.primary,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _HeroMetric(
            title: 'Bütünlük',
            value: '%100 SHA',
            valueColor: AppColors.success,
          ),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _HeroMetric(
            title: 'Uyuşmazlık Riski',
            value: 'Korumalı',
            valueColor: AppColors.primaryLight,
          ),
        ),
      ],
    );
  }
}

class _HeroMetric extends StatelessWidget {
  final String title;
  final String value;
  final Color valueColor;

  const _HeroMetric({
    required this.title,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderCol(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 9,
              color: AppColors.textMuted(context),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
