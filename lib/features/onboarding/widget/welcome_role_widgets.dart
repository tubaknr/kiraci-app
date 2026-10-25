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
            'Kira sözleşmeleri, depozito, teslim tutanakları ve arıza delillerinizi cihazınızda değiştirilemez SHA-256 zinciriyle güvence altına alın.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted(context),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

/// Yan yana duran Kiracı ve Kiraya Veren giriş butonları bileşeni (Sümeyye - SOLID SRP)
class WelcomeRoleButtons extends StatelessWidget {
  final VoidCallback onTenantSelected;
  final VoidCallback onLandlordSelected;

  const WelcomeRoleButtons({
    super.key,
    required this.onTenantSelected,
    required this.onLandlordSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        children: [
          Expanded(
            child: _RoleButton(
              title: 'Kiracı Girişi',
              subtitle: 'Kiracı Portalı',
              icon: Icons.key_rounded,
              accentColor: AppColors.primaryCol(context),
              onTap: onTenantSelected,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _RoleButton(
              title: 'Kiraya Veren Girişi',
              subtitle: 'Ev Sahibi Portalı',
              icon: Icons.apartment_rounded,
              accentColor: AppColors.secondaryCol(context),
              onTap: onLandlordSelected,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final VoidCallback onTap;

  const _RoleButton({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.cardBg(context),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? accentColor.withValues(alpha: 0.4) : accentColor.withValues(alpha: 0.25),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: accentColor.withValues(alpha: isDark ? 0.2 : 0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIconCircle(),
              const SizedBox(height: 10),
              _buildTitle(context),
              const SizedBox(height: 4),
              _buildSubtitle(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconCircle() {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: accentColor.withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: accentColor, size: 24),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.textMain(context),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      subtitle,
      style: TextStyle(
        fontSize: 11,
        color: AppColors.textMuted(context),
      ),
    );
  }
}
