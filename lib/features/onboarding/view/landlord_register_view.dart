import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widget/auth_role_badge.dart';
import '../widget/auth_submit_button.dart';
import '../widget/auth_switch_prompt.dart';
import '../widget/auth_text_field.dart';
import 'landlord_login_view.dart';

/// Kiraya Veren (Ev Sahibi) Hesap Açma Ekranı (Sümeyye - SOLID SRP)
class LandlordRegisterView extends StatefulWidget {
  final Function(String role, String name) onAuthenticated;

  const LandlordRegisterView({
    super.key,
    required this.onAuthenticated,
  });

  @override
  State<LandlordRegisterView> createState() => _LandlordRegisterViewState();
}

class _LandlordRegisterViewState extends State<LandlordRegisterView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _propertyController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _pinConfirmController = TextEditingController();
  final bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _contactController.dispose();
    _propertyController.dispose();
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
    widget.onAuthenticated('landlord', name.isNotEmpty ? name : 'Ev Sahibi');
    if (mounted) {
      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Kiraya veren hesabı oluşturuldu. Hoş geldiniz, ${name.isNotEmpty ? name : "Ev Sahibi"}!'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _openLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => LandlordLoginView(
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
        title: const Text('Kiraya Veren Hesabı Aç'),
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
                  label: 'Ev Sahibi Hesabını Başlat',
                  icon: Icons.add_home_work_rounded,
                  backgroundColor: AppColors.secondary,
                  isLoading: _isLoading,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 18),
                AuthSwitchPrompt(
                  promptText: 'Zaten bir ev sahibi hesabınız var mı?',
                  actionText: 'Giriş Yapın',
                  actionColor: AppColors.secondary,
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
          roleName: 'Kiraya Veren Kayıt',
          icon: Icons.apartment_rounded,
          isTenant: false,
        ),
        const SizedBox(height: 12),
        const Text(
          'Mülk Sahibi Profili',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Kiraya verdiğiniz taşınmazların hukuki güvencesini tarafsız kriptografik defterle başlatın.',
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
          hintText: 'Örn: Mehmet Özkan',
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
          hintText: 'ornek@posta.com veya 0555 987 65 43',
          prefixIcon: Icons.contact_mail_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        AuthTextField(
          controller: _propertyController,
          label: 'İlk Taşınmaz / Daire Adı (İsteğe Bağlı)',
          hintText: 'Örn: Kadıköy Dairesi 2+1 veya Beşiktaş Konutu',
          prefixIcon: Icons.home_work_outlined,
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
