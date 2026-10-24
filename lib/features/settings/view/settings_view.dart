import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/lock_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../lock/controller/lock_controller.dart';

/// Ayarlar, Tema ve Uygulama Kilidi Ekranı (Sümeyye - T23)
class SettingsView extends StatefulWidget {
  final LockController? lockController;
  final VoidCallback? onShowOnboarding;

  const SettingsView({
    super.key,
    this.lockController,
    this.onShowOnboarding,
  });

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late final LockController _lockController;
  final NotificationService _notificationService = NotificationService();
  final TextEditingController _pinController = TextEditingController();

  bool _enableBiometrics = false;
  bool _backupReminderEnabled = true;

  @override
  void initState() {
    super.initState();
    _lockController = widget.lockController ?? LockController(LockService());
    _lockController.checkLockState();
  }

  @override
  void dispose() {
    if (widget.lockController == null) {
      _lockController.dispose();
    }
    _pinController.dispose();
    super.dispose();
  }

  void _showSetPinDialog() {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Yeni PIN Belirle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('4-8 basamaklı bir sayısal PIN kodu girin:'),
              const SizedBox(height: 12),
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 8,
                decoration: const InputDecoration(
                  hintText: 'PIN Kodu',
                  counterText: '',
                ),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Biyometriğe de izin ver'),
                value: _enableBiometrics,
                onChanged: (bool? v) => setState(() => _enableBiometrics = v ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final NavigatorState nav = Navigator.of(context);
                final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
                final bool success = await _lockController.setupLock(
                  pin: _pinController.text,
                  enableBiometrics: _enableBiometrics,
                );
                if (success && mounted) {
                  _pinController.clear();
                  nav.pop();
                  messenger.showSnackBar(
                    const SnackBar(content: Text('Uygulama kilidi başarıyla aktifleştirildi.')),
                  );
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar & Güvenlik'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildThemeCard(),
          const SizedBox(height: 12),
          _buildLockCard(),
          const SizedBox(height: 12),
          _buildBackupReminderCard(),
          const SizedBox(height: 12),
          _buildDisclaimerCard(),
          const SizedBox(height: 16),
          _buildOnboardingButton(),
        ],
      ),
    );
  }

  Widget _buildThemeCard() {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeModeNotifier,
      builder: (BuildContext context, ThemeMode currentMode, _) {
        final bool isDark = currentMode == ThemeMode.dark;

        return Card(
          child: ListTile(
            leading: Icon(
              isDark ? Icons.dark_mode : Icons.light_mode,
              color: AppColors.primary,
            ),
            title: const Text('Görünüm Teması'),
            subtitle: Text(
              currentMode == ThemeMode.system
                  ? 'Sistem Varsayılanı'
                  : (isDark ? 'Koyu Tema' : 'Açık Tema'),
            ),
            trailing: DropdownButton<ThemeMode>(
              value: currentMode,
              underline: const SizedBox.shrink(),
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('Sistem')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Açık')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Koyu')),
              ],
              onChanged: (ThemeMode? newMode) {
                if (newMode != null) AppTheme.setThemeMode(newMode);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildLockCard() {
    return ValueListenableBuilder<bool>(
      valueListenable: _lockController.isConfigured,
      builder: (BuildContext context, bool isConfigured, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isConfigured ? Icons.lock : Icons.lock_open,
                      color: isConfigured ? AppColors.secondary : AppColors.lightTextSecondary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Uygulama Kilidi & PIN',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                          Text(
                            isConfigured
                                ? 'PIN kilidi devrede (SHA-256 tuzlu özet)'
                                : 'Kilit aktif değil',
                            style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _showSetPinDialog,
                    icon: const Icon(Icons.password),
                    label: Text(isConfigured ? 'PIN Kodunu Değiştir' : 'PIN Kilidi Oluştur'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBackupReminderCard() {
    return Card(
      child: SwitchListTile(
        title: const Text('Düzenli Yedek Hatırlatması'),
        subtitle: const Text('Cihaz kaybına karşı haftalık ZIP delil paketi yedek uyarısı'),
        value: _backupReminderEnabled,
        onChanged: (bool val) async {
          setState(() => _backupReminderEnabled = val);
          if (val) {
            await _notificationService.showNotification(
              id: 9999,
              title: 'SafeRentHouse Yedekleme Uyarısı',
              body: 'Düzenli delil güvenliğiniz için ZIP paketinizi dışa aktarıp yedekleyin.',
            );
          }
        },
      ),
    );
  }

  Widget _buildDisclaimerCard() {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dürüst Sınırlar & Güvenlik Politikası',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '• Sunucusuz Çevrimdışı: Verileriniz yalnızca bu cihazdaki SQLite tablosunda saklanır.\n'
              '• Saat Güvenilirliği: Zaman damgaları cihaz saatini referans alır. Saat geriye alma tespit edilir.\n'
              '• Delil Kabulü: Üretilen kayıtlar doğrulanabilir delildir; hukuki bağlayıcılık mahkeme takdirindedir.',
              style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.lightTextSecondary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnboardingButton() {
    return ElevatedButton.icon(
      onPressed: widget.onShowOnboarding,
      icon: const Icon(Icons.info_outline),
      label: const Text('Aydınlatma & KVKK Metnini Yeniden Aç'),
    );
  }
}
