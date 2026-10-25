import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Zaman tüneli altındaki Hukuki Delil Dosyası ve PDF Dışa Aktarma Paneli (Sümeyye - T10 - Stitch UI)
class TimelinePdfExportFooter extends StatelessWidget {
  final VoidCallback onExportPdf;

  const TimelinePdfExportFooter({super.key, required this.onExportPdf});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.badgeBlueBg.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          _buildHeaderRow(),
          const SizedBox(height: 12),
          _buildExportButton(),
          const SizedBox(height: 10),
          _buildLegalFootnote(),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return const Row(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: AppColors.badgeGreenBg,
          child: Icon(Icons.verified_user, size: 20, color: AppColors.success),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hukuki Delil Dosyası',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
              ),
              Text(
                'Kriptografik zaman damgası doğrulaması ile derlenmiştir',
                style: TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExportButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 2,
        ),
        onPressed: onExportPdf,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.verified_outlined, size: 18),
            SizedBox(width: 8),
            Text(
              'Mahkemeye Sunulabilir Dosya (PDF) Oluştur',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalFootnote() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.gavel_rounded, size: 13, color: AppColors.lightTextHint),
        SizedBox(width: 5),
        Flexible(
          child: Text(
            'Türk Hukuk Muhakemeleri Kanunu (HMK Madde 199 elektronik delil) uyarınca geçerlidir',
            style: TextStyle(fontSize: 10, color: AppColors.lightTextSecondary),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
