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
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? AppColors.cardBg(context),
      elevation: 0,
      scrolledUnderElevation: 1,
      title: _buildTitle(context),
      actions: _buildActions(context),
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.badgeBlueBg,
          child: Icon(Icons.shield_outlined, size: 18, color: AppColors.primary),
        ),
        const SizedBox(width: 8),
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
                color: AppColors.textMain(context),
              ),
            ),
            Text(
              'Dosyalarım',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
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
            onPressed: () => _showNotificationSheet(context),
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
      Padding(
        padding: const EdgeInsets.only(right: 14.0, left: 4.0),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: () => _showProfileSheet(context),
          child: const CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.badgeIndigoBg,
            child: Icon(Icons.person, size: 18, color: AppColors.primary),
          ),
        ),
      ),
    ];
  }

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Bildirimler', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              const ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.badgeGreenBg, child: Icon(Icons.check, color: AppColors.success)),
                title: Text('Kriptografik Defter Doğrulandı'),
                subtitle: Text('Tüm SHA-256 kayıtları yerel defter ile tam eşleşmektedir.'),
                dense: true,
              ),
              const ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.badgeBlueBg, child: Icon(Icons.security, color: AppColors.primary)),
                title: Text('Güvenlik Uyarısı'),
                subtitle: Text('Düzenli yedek alarak delillerinizi güvence altında tutun.'),
                dense: true,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, size: 36, color: Colors.white),
              ),
              const SizedBox(height: 12),
              const Text('Kullanıcı Profili', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Text('Çevrimdışı Yerel Kasa Kullanıcısı', style: TextStyle(fontSize: 12, color: AppColors.lightTextSecondary)),
              const SizedBox(height: 16),
              const Divider(),
              const ListTile(
                leading: Icon(Icons.verified_outlined, color: AppColors.success),
                title: Text('Kriptografik Anahtarlar'),
                subtitle: Text('Bu cihazda yerel olarak saklanmaktadır.'),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Kapat'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
