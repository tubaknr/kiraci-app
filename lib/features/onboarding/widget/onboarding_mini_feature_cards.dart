import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// 3 sütunlu teknik güvence kartları (Sümeyye - T04)
class OnboardingMiniFeatureCards extends StatelessWidget {
  const OnboardingMiniFeatureCards({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 4.0),
      child: Row(
        children: [
          Expanded(
            child: _MiniCard(
              icon: Icons.lock_outline,
              iconColor: AppColors.primary,
              title: 'AES-256',
              subtitle: 'Cihazda Şifreli',
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _MiniCard(
              icon: Icons.visibility_off_outlined,
              iconColor: AppColors.secondary,
              title: 'Sıfır Telemetri',
              subtitle: 'Takipsiz',
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: _MiniCard(
              icon: Icons.picture_as_pdf_outlined,
              iconColor: AppColors.warning,
              title: 'Bağımsız',
              subtitle: 'Taşınabilir PDF',
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _MiniCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBg(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderCol(context)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
              color: AppColors.textMain(context),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 9,
              color: AppColors.textMuted(context),
            ),
          ),
        ],
      ),
    );
  }
}
