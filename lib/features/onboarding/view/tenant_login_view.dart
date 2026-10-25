import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widget/auth_role_badge.dart';
import '../widget/auth_submit_button.dart';
import '../widget/auth_switch_prompt.dart';
import '../widget/auth_text_field.dart';
import 'tenant_register_view.dart';

/// Kiracı Giriş Ekranı (Sümeyye - SOLID SRP)
class TenantLoginView extends StatefulWidget {
  final Function(String role, String name) onAuthenticated;

  const TenantLoginView({
    super.key,
    required this.onAuthenticated,
  });

  @override
  State<TenantLoginView> createState() => _TenantLoginViewState();
}

class _TenantLoginViewState extends State<TenantLoginView> {
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
    widget.onAuthenticated('tenant', displayName.isNotEmpty ? displayName : 'Kiracı');
    if (mounted) {
      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Giriş başarılı. Hoş geldiniz, ${displayName.isNotEmpty ? displayName : "Kiracı"}!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _handleQuickEntry() {
    widget.onAuthenticated('tenant', 'Kiracı');
    if (mounted) {
      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giriş başarılı. Kiracı kasasına hoş geldiniz!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _openRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => TenantRegisterView(
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
        title: const Text('Kiracı Portalı'),
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
                  label: 'Kiracı Girişi Yap',
                  icon: Icons.login_rounded,
                  backgroundColor: AppColors.primary,
                  isLoading: _isLoading,
                  onPressed: _handleLogin,
                ),
                const SizedBox(height: 10),
                Center(
                  child: TextButton.icon(
                    onPressed: _handleQuickEntry,
                    icon: const Icon(Icons.flash_on_rounded, size: 16),
                    label: const Text('Hızlı Giriş Yap (Demo)'),
                  ),
                ),
                const SizedBox(height: 10),
                AuthSwitchPrompt(
                  promptText: 'Henüz kiracı hesabınız yok mu?',
                  actionText: 'Hesap Açın',
                  actionColor: AppColors.primary,
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
          roleName: 'Kiracı Modu',
          icon: Icons.key_rounded,
          isTenant: true,
        ),
        const SizedBox(height: 12),
        const Text(
          'Hoş Geldiniz',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Kiraladığınız konuta ait delil defterinize ve zaman çizelgenize erişmek için giriş yapın.',
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
          hintText: 'ornek@posta.com / 0555 123 45 67',
          prefixIcon: Icons.alternate_email_rounded,
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
        color: AppColors.badgeBlueBg.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shield_outlined, size: 20, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Çevrimdışı Güvence: Giriş bilgileriniz asla ağa gönderilmez; yalnızca bu cihazda doğrulanır.',
              style: TextStyle(fontSize: 11, color: AppColors.textMuted(context), height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
