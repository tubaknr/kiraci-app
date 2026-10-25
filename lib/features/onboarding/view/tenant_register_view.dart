import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widget/auth_role_badge.dart';
import '../widget/auth_submit_button.dart';
import '../widget/auth_switch_prompt.dart';
import '../widget/auth_text_field.dart';
import 'tenant_login_view.dart';

/// Kiracı Hesap Açma Ekranı (Sümeyye - SOLID SRP)
class TenantRegisterView extends StatefulWidget {
  final Function(String role, String name) onAuthenticated;

  const TenantRegisterView({
    super.key,
    required this.onAuthenticated,
  });

  @override
  State<TenantRegisterView> createState() => _TenantRegisterViewState();
}

class _TenantRegisterViewState extends State<TenantRegisterView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _identityController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _pinConfirmController = TextEditingController();
  final bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _identityController.dispose();
    _pinController.dispose();
    _pinConfirmController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (!_formKey.currentState!.validate()) return;

    if (_pinController.text.trim() != _pinConfirmController.text.trim()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN kodları birbiriyle eşleşmiyor.')),
      );
      return;
    }

    final String name = _nameController.text.trim();
    widget.onAuthenticated('tenant', name.isNotEmpty ? name : 'Kiracı');
    if (mounted) {
      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kiracı hesabı oluşturuldu. Hoş geldiniz, ${name.isNotEmpty ? name : "Kiracı"}!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _openLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => TenantLoginView(
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
        title: const Text('Kiracı Hesabı Aç'),
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
                const SizedBox(height: 20),
                _buildFormFields(),
                const SizedBox(height: 24),
                AuthSubmitButton(
                  label: 'Kiracı Hesabını Başlat',
                  icon: Icons.person_add_rounded,
                  backgroundColor: AppColors.primaryCol(context),
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 18),
                AuthSwitchPrompt(
                  promptText: 'Zaten bir kiracı hesabınız var mı?',
                  actionText: 'Giriş Yapın',
                  actionColor: AppColors.primaryCol(context),
                  onTap: _openLogin,
                ),
                const SizedBox(height: 24),
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
          roleName: 'Kiracı Kayıt',
          icon: Icons.vpn_key_rounded,
          isTenant: true,
        ),
        const SizedBox(height: 12),
        const Text(
          'Yeni Kiracı Profili',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Ev kiralama sürecinizi tarafsız delil zinciriyle koruma altına alın.',
          style: TextStyle(fontSize: 13, color: AppColors.textMuted(context), height: 1.4),
        ),
      ],
    );
  }

  Widget _buildFormFields() {
    return Column(
      children: [
        AuthTextField(
          controller: _nameController,
          label: 'Ad Soyad',
          hintText: 'Örn: Ahmet Yılmaz',
          prefixIcon: Icons.badge_outlined,
          validator: (val) {
            if (val == null || val.trim().isEmpty) return 'Lütfen adınızı girin';
            return null;
          },
        ),
        const SizedBox(height: 12),
        AuthTextField(
          controller: _contactController,
          label: 'E-posta veya Telefon Numarası (İsteğe Bağlı)',
          hintText: 'ornek@posta.com veya 0555 123 45 67',
          prefixIcon: Icons.contact_mail_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        AuthTextField(
          controller: _identityController,
          label: 'T.C. Kimlik No veya Rumuz (İsteğe Bağlı)',
          hintText: 'Raporlarda görünmesi için (isteğe bağlı)',
          prefixIcon: Icons.fingerprint_rounded,
        ),
        const SizedBox(height: 12),
        AuthTextField(
          controller: _pinController,
          label: 'Cihaz Güvenlik PIN Kodu Belirleyin',
          hintText: 'En az 4 haneli PIN',
          prefixIcon: Icons.lock_outline_rounded,
          isPassword: true,
          keyboardType: TextInputType.number,
          validator: (val) {
            if (val == null || val.trim().length < 4) return 'PIN en az 4 haneli olmalıdır';
            return null;
          },
        ),
        const SizedBox(height: 12),
        AuthTextField(
          controller: _pinConfirmController,
          label: 'PIN Kodunu Tekrar Girin',
          hintText: 'PIN tekrarı',
          prefixIcon: Icons.lock_reset_rounded,
          isPassword: true,
          keyboardType: TextInputType.number,
          validator: (val) {
            if (val == null || val.trim().isEmpty) return 'PIN tekrarı gereklidir';
            return null;
          },
        ),
      ],
    );
  }
}
