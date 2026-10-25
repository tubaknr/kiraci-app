import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// 3 sütunlu kasa ve delil istatistik paneli (Sümeyye - T07 - Stitch UI)
class CasesMetricsOverview extends StatelessWidget {
  final int activeCases;
  final int totalEvidence;

  const CasesMetricsOverview({
    super.key,
    required this.activeCases,
    this.totalEvidence = 24,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: _MetricCard(
              icon: Icons.folder_outlined,
              iconColor: AppColors.primaryLight,
              title: 'Aktif Dosyalar',
              value: '$activeCases',
              subtitle: 'dosya',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _MetricCard(
              icon: Icons.description_outlined,
              iconColor: AppColors.primaryLight,
              title: 'Deliller',
              value: '$totalEvidence',
              subtitle: 'güvence altında',
            ),
          ),
          const SizedBox(width: 8),
          const Expanded(
            child: _MetricCard(
              icon: Icons.shield_outlined,
              iconColor: AppColors.success,
              title: 'Özet Doğrulaması',
              value: '%100',
              valueColor: AppColors.success,
              subtitle: 'geçerli',
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;
  final Color? valueColor;

  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderCol(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 16, color: iconColor),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: valueColor ?? AppColors.textMain(context),
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 9,
                    color: AppColors.textMuted(context),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
