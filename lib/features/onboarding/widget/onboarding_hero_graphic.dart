import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Onboarding ana görseli, başlık ve slogan bileşeni (Sümeyye - T04)
class OnboardingHeroGraphic extends StatelessWidget {
  const OnboardingHeroGraphic({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      child: Column(
        children: [
          _buildLockComposition(),
          const SizedBox(height: 16),
          _buildAuditTrailPill(),
          const SizedBox(height: 12),
          const Text(
            'Müdahale Edilemez Kira Güvencesi',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Kira sözleşmeleri, ihtilaflar, tadilatlar ve ödemeleri mahkemede ve arabuluculukta geçerli kriptografik kanıtlarla belgeleyin.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.lightTextSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockComposition() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Dış yumuşak halka
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.badgeBlueBg,
              border: Border.all(color: AppColors.lightBorder, width: 2),
            ),
          ),
          // İç kilit rozeti
          Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary,
              boxShadow: [
                BoxShadow(
                  color: Color(0x331E3A8A),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.lock_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
          // Sağ üstte yeşil doğrulama rozeti
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, size: 12, color: Colors.white),
            ),
          ),
          // Sol altta tokmak/hukuk rozeti
          Positioned(
            bottom: 8,
            left: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: AppColors.warning,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.gavel_rounded, size: 12, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuditTrailPill() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.badgeIndigoBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_user_outlined, size: 13, color: AppColors.badgeIndigoText),
          SizedBox(width: 5),
          Text(
            'Adli Düzeyde Denetim İzi',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.badgeIndigoText,
            ),
          ),
        ],
      ),
    );
  }
}
