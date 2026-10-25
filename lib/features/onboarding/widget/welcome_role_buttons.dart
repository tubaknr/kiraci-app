import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

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
              accentColor: AppColors.primary,
              onTap: onTenantSelected,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: _RoleButton(
              title: 'Kiraya Veren Girişi',
              subtitle: 'Ev Sahibi Portalı',
              icon: Icons.apartment_rounded,
              accentColor: AppColors.secondary,
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
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppColors.textMain(context),
      ),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    return Text(
      subtitle,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 10,
        color: AppColors.textMuted(context),
      ),
    );
  }
}
