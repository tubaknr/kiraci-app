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
                        'AKTİF',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.badgeGreenTextColor(context),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Tüm bloklar geriye dönük SHA-256 zinciriyle mühürlüdür. Tahrifatsız yerel kasa.',
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.badgeBlueBgColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(radius: 3, backgroundColor: AppColors.success),
          const SizedBox(width: 4),
          Text(
            'Çevrimdışı',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryCol(context),
            ),
          ),
        ],
      ),
    );
  }
}

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
              Icon(icon, size: 14, color: iconColor),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: valueColor ?? AppColors.textMain(context),
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9,
              color: AppColors.textMuted(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

/// Boş kasa ekranı durumu (Sümeyye - T07)
class CasesEmptyState extends StatelessWidget {
  final VoidCallback onCreateCase;

  const CasesEmptyState({super.key, required this.onCreateCase});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = AppColors.primaryCol(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: primaryColor.withValues(alpha: 0.15),
              child: Icon(Icons.folder_open, size: 40, color: primaryColor),
            ),
            const SizedBox(height: 20),
            Text(
              'Kayıtlı Kira Dosyası Bulunamadı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tüm delil zinciri, formlar ve tutanaklar bir kira dosyası altında toplanır. Başlamak için yeni bir dosya oluşturun.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted(context), height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onCreateCase,
              icon: const Icon(Icons.add),
              label: const Text('İlk Dosyayı Oluştur'),
            ),
          ],
        ),
      ),
    );
  }
}
