import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Onboarding üst başlık ve uyumluluk rozeti (Sümeyye - T04)
class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildLogoAndTitle(),
          _buildComplianceBadge(),
        ],
      ),
    );
  }

  Widget _buildLogoAndTitle() {
    return const Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.badgeBlueBg,
          child: Icon(Icons.shield_outlined, size: 18, color: AppColors.primary),
        ),
        SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SafeRentHouse',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'HUKUKİ DELİL MOTORU',
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextSecondary,
                letterSpacing: 0.6,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildComplianceBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.badgeGreenBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.badgeGreenText.withValues(alpha: 0.2)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, size: 14, color: AppColors.badgeGreenText),
          SizedBox(width: 4),
          Text(
            'eIDAS & HMK Uyumlu',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.badgeGreenText,
            ),
          ),
        ],
      ),
    );
  }
}
