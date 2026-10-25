import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../widget/onboarding_policy_modal.dart';
import '../widget/welcome_hero_logo.dart';
import '../widget/welcome_role_buttons.dart';
import 'landlord_login_view.dart';
import 'tenant_login_view.dart';

/// Uygulama Karşılama ve Rol Seçim Ekranı (Sümeyye - SOLID SRP)
/// Kullanıcı isteğine göre: Logo + Altında Açıklayıcı Metin + Yan yana iki giriş butonu
class WelcomeRoleView extends StatelessWidget {
  final Function(String role, String name) onAuthenticated;

  const WelcomeRoleView({
    super.key,
    required this.onAuthenticated,
  });

  void _navigateToTenant(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => TenantLoginView(onAuthenticated: onAuthenticated),
      ),
    );
  }

  void _navigateToLandlord(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => LandlordLoginView(onAuthenticated: onAuthenticated),
      ),
    );
  }

  void _showPolicyModal(BuildContext context) {
    OnboardingPolicyModal.show(context, onAccept: () {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              const WelcomeHeroLogo(),
              const SizedBox(height: 32),
              WelcomeRoleButtons(
                onTenantSelected: () => _navigateToTenant(context),
                onLandlordSelected: () => _navigateToLandlord(context),
              ),
              const SizedBox(height: 24),
              _buildDirectAccessLink(context),
              const SizedBox(height: 12),
              _buildPolicyLink(context),
              const SizedBox(height: 20),
              _buildTrustFooter(context),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        ValueListenableBuilder<ThemeMode>(
          valueListenable: AppTheme.themeModeNotifier,
          builder: (BuildContext context, ThemeMode mode, _) {
            final bool isDark = mode == ThemeMode.dark;
            return IconButton(
              tooltip: isDark ? 'Açık Temaya Geç' : 'Koyu Temaya Geç',
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: AppColors.primaryLight,
              ),
              onPressed: AppTheme.toggleTheme,
            );
          },
        ),
      ],
    );
  }

  Widget _buildDirectAccessLink(BuildContext context) {
    return TextButton.icon(
      onPressed: () => onAuthenticated('tenant', 'Kiracı'),
      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
      label: const Text(
        'Giriş Yapmadan Doğrudan Kasaya Geç',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryLight,
        ),
      ),
    );
  }

  Widget _buildPolicyLink(BuildContext context) {
    return TextButton.icon(
      onPressed: () => _showPolicyModal(context),
      icon: const Icon(Icons.description_outlined, size: 16),
      label: const Text(
        'Aydınlatma & KVKK Metnini İncele',
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildTrustFooter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardBg(context),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderCol(context)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_clock_outlined, size: 16, color: AppColors.secondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Çevrimdışı Kriptografik Mimari • Verileriniz Yalnızca Bu Cihazda',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: AppColors.textMuted(context)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
