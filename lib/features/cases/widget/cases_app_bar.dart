import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Stitch stili özel AppBar bileşeni (Sümeyye - T07)
class CasesAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onRefresh;

  const CasesAppBar({super.key, required this.onRefresh});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      title: _buildTitle(),
      actions: _buildActions(),
    );
  }

  Widget _buildTitle() {
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
                color: AppColors.lightTextPrimary,
              ),
            ),
            Text(
              'Dosyalarım',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildActions() {
    return [
      IconButton(
        tooltip: 'Yenile',
        icon: const Icon(Icons.verified_user_outlined, size: 20, color: AppColors.success),
        onPressed: onRefresh,
      ),
      Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            tooltip: 'Bildirimler',
            icon: const Icon(Icons.notifications_none_rounded, size: 22),
            onPressed: () {},
          ),
          const Positioned(
            top: 12,
            right: 12,
            child: CircleAvatar(
              radius: 4,
              backgroundColor: AppColors.error,
            ),
          ),
        ],
      ),
      const Padding(
        padding: EdgeInsets.only(right: 14.0, left: 4.0),
        child: CircleAvatar(
          radius: 15,
          backgroundColor: AppColors.badgeIndigoBg,
          child: Icon(Icons.person, size: 18, color: AppColors.primary),
        ),
      ),
    ];
  }
}
