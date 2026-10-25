import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widget/auth_role_badge.dart';
import '../widget/auth_submit_button.dart';
import '../widget/auth_switch_prompt.dart';
import '../widget/auth_text_field.dart';
import 'landlord_register_view.dart';

/// Kiraya Veren (Ev Sahibi) Giriş Ekranı (Sümeyye - SOLID SRP)
class LandlordLoginView extends StatefulWidget {
  final Function(String role, String name) onAuthenticated;

  const LandlordLoginView({
    super.key,
    required this.onAuthenticated,
  });

  @override
  State<LandlordLoginView> createState() => _LandlordLoginViewState();
}

class _LandlordLoginViewState extends State<LandlordLoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final bool _isLoading = false;

  @override
  void dispose() {
    _contactController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    final String displayName = _contactController.text.trim();
    widget.onAuthenticated('landlord', displayName.isNotEmpty ? displayName : 'Ev Sahibi');
    if (mounted) {
      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Giriş başarılı. Hoş geldiniz, ${displayName.isNotEmpty ? displayName : "Ev Sahibi"}!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _handleQuickEntry() {
    widget.onAuthenticated('landlord', 'Ev Sahibi');
    if (mounted) {
      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giriş başarılı. Ev sahibi kasasına hoş geldiniz!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _openRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => LandlordRegisterView(
          onAuthenticated: widget.onAuthenticated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Kiraya Veren Portalı'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),
                _buildFormFields(),
                const SizedBox(height: 24),
                AuthSubmitButton(
                  label: 'Kiraya Veren Girişi Yap',
                  icon: Icons.apartment_rounded,
                  backgroundColor: AppColors.secondaryCol(context),
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton.icon(
                    onPressed: _handleQuickEntry,
                    icon: Icon(Icons.flash_on_rounded, size: 16, color: AppColors.secondaryCol(context)),
                    label: Text('Hızlı Giriş Yap (Demo)', style: TextStyle(color: AppColors.secondaryCol(context))),
                  ),
                ),
                const SizedBox(height: 10),
                AuthSwitchPrompt(
                  promptText: 'Ev sahibi hesabınız yok mu?',
                  actionText: 'Hesap Açın',
                  actionColor: AppColors.secondaryCol(context),
                  onTap: _openRegister,
                ),
                const SizedBox(height: 24),
                _buildSecurityNotice(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AuthRoleBadge(
          roleName: 'Kiraya Veren Modu',
          icon: Icons.apartment_rounded,
          isTenant: false,
        ),
        const SizedBox(height: 12),
        const Text(
          'Mülk Sahibi Girişi',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Kiraladığınız mülklere ait demirbaş tutanaklarına ve kira tahsilat delillerine erişin.',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted(context), height: 1.4),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        AuthTextField(
          controller: _contactController,
          label: 'E-posta veya Telefon Numarası',
          hintText: 'ornek@posta.com / 0555 987 65 43',
          prefixIcon: Icons.contact_phone_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Lütfen iletişim bilginizi girin';
            }
            return null;
          },
        ),
        const SizedBox(height: 14),
        AuthTextField(
          controller: _pinController,
          label: 'Cihaz İçi Güvenlik PIN Kodu',
          hintText: '4-8 haneli PIN kodu',
          prefixIcon: Icons.lock_outline_rounded,
          isPassword: true,
          keyboardType: TextInputType.number,
          validator: (val) {
            if (val == null || val.trim().length < 4) {
              return 'En az 4 haneli PIN kodu girin';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildSecurityNotice(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.badgeGreenBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.secondary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, size: 20, color: AppColors.secondary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Bağımsız Defter: Tüm kayıtlar cihazınızda SHA-256 zinciriyle saklanır; hiçbir bulut sunucusuna aktarılmaz.',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted(context), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
