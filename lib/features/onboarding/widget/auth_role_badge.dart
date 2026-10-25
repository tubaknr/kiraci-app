import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Giriş/Kayıt ekranlarında aktif rolü gösteren rozet (Sümeyye - SOLID SRP)
class AuthRoleBadge extends StatelessWidget {
  final String roleName;
  final IconData icon;
  final bool isTenant;

  const AuthRoleBadge({
    super.key,
    required this.roleName,
    required this.icon,
    required this.isTenant,
  });

  @override
  Widget build(BuildContext context) {
    final Color badgeBg = isTenant ? AppColors.badgeBlueBg : AppColors.badgeGreenBg;
    final Color badgeColor = isTenant ? AppColors.primary : AppColors.secondary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            roleName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}
