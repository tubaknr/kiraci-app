import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Karşılama ekranı logo ve açıklayıcı metin bileşeni (Sümeyye - SOLID SRP)
class WelcomeHeroLogo extends StatelessWidget {
  const WelcomeHeroLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLogoShield(context),
        const SizedBox(height: 20),
        _buildAppTitle(context),
        const SizedBox(height: 10),
        _buildExplanationText(context),
      ],
    );
  }

  Widget _buildLogoShield(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF1E3A8A), Color(0xFF0F766E)]
              : const [Color(0xFFDBEAFE), Color(0xFFCCFBF1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : AppColors.primary).withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: isDark ? const Color(0xFF3B82F6).withValues(alpha: 0.3) : Colors.white,
          width: 2,
        ),
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Icons.shield_rounded,
              size: 54,
              color: isDark ? AppColors.primaryLight : AppColors.primary,
            ),
            const Icon(
              Icons.home_work_rounded,
              size: 26,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppTitle(BuildContext context) {
    return Text(
      'SafeRentHouse',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
        color: AppColors.textMain(context),
      ),
    );
  }

  Widget _buildExplanationText(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const Text(
            'Kriptografik Güvenlikli Çevrimdışı Kira Kasası',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Kira sözleşmeleri, teslim tutanakları, ayıp bildirimleri ve ödeme kayıtlarını tarafsız SHA-256 zinciriyle cihazınızda güvenle koruyun.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.45,
              color: AppColors.textMuted(context),
            ),
          ),
        ],
      ),
    );
  }
}
