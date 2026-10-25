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
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.badgeBlueBgColor(context),
          child: Icon(Icons.shield_outlined, size: 18, color: AppColors.primaryCol(context)),
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
            icon: Icon(Icons.notifications_none_rounded, size: 22, color: AppColors.textMain(context)),
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
          child: CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.badgeIndigoBgColor(context),
            child: Icon(Icons.person, size: 18, color: AppColors.primaryCol(context)),
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
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.badgeGreenBgColor(context),
                  child: const Icon(Icons.check, color: AppColors.success),
                ),
                title: Text('Kriptografik Defter Doğrulandı', style: TextStyle(color: AppColors.textMain(context))),
                subtitle: Text(
                  'Tüm SHA-256 kayıtları yerel defter ile tam eşleşmektedir.',
                  style: TextStyle(color: AppColors.textMuted(context)),
                ),
                dense: true,
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.badgeBlueBgColor(context),
                  child: Icon(Icons.security, color: AppColors.primaryCol(context)),
                ),
                title: Text('Güvenlik Uyarısı', style: TextStyle(color: AppColors.textMain(context))),
                subtitle: Text(
                  'Düzenli yedek alarak delillerinizi güvence altında tutun.',
                  style: TextStyle(color: AppColors.textMuted(context)),
                ),
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
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primaryCol(context),
                child: const Icon(Icons.person, size: 36, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                'Kullanıcı Profili',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain(context)),
              ),
              Text(
                'Çevrimdışı Yerel Kasa Kullanıcısı',
                style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
              ),
              const SizedBox(height: 16),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.verified_outlined, color: AppColors.success),
                title: Text('Kriptografik Anahtarlar', style: TextStyle(color: AppColors.textMain(context))),
                subtitle: Text(
                  'Bu cihazda yerel olarak saklanmaktadır.',
                  style: TextStyle(color: AppColors.textMuted(context)),
                ),
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
