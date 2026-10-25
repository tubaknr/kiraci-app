import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Kayıt detayı eylem butonları (Sümeyye - T12 - Stitch UI)
class RecordDetailActions extends StatelessWidget {
  final VoidCallback onExportPdf;
  final VoidCallback onOpenCorrection;
  final VoidCallback onVerifyAgain;
  final VoidCallback onShareChain;

  const RecordDetailActions({
    super.key,
    required this.onExportPdf,
    required this.onOpenCorrection,
    required this.onVerifyAgain,
    required this.onShareChain,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildPrimaryPdfButton(),
        const SizedBox(height: 10),
        _buildCorrectionButton(),
        const SizedBox(height: 10),
        _buildSecondaryActionRow(),
      ],
    );
  }

  Widget _buildPrimaryPdfButton() {
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
            Icon(Icons.picture_as_pdf_outlined, size: 18),
            SizedBox(width: 8),
            Text(
              'Mahkemeye Uygun Delil PDF\'i Olarak Aktar',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorrectionButton() {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: onOpenCorrection,
        icon: const Icon(Icons.edit_note, size: 20),
        label: const Text(
          'Bu Kayda Düzeltme / Revizyon Ekle',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSecondaryActionRow() {
    return Row(
      children: [
        Expanded(
          child: _SecondaryButton(
            icon: Icons.verified_outlined,
            label: 'Özeti Tekrar Doğrula',
            onTap: onVerifyAgain,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SecondaryButton(
            icon: Icons.share_outlined,
            label: 'Zincire İlet',
            onTap: onShareChain,
          ),
        ),
      ],
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: AppColors.cardBg(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderCol(context)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: AppColors.textMain(context)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textMain(context),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
