import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widget/auth_form_widgets.dart';
import 'auth_login_view.dart';

/// Parametrik Kimlik Doğrulama Hesap Açma Ekranı (Sümeyye - SOLID SRP & OCP)
class AuthRegisterView extends StatefulWidget {
  final AuthRole role;
  final Function(String role, String name) onAuthenticated;

  const AuthRegisterView({
    super.key,
    required this.role,
    required this.onAuthenticated,
  });

  @override
  State<AuthRegisterView> createState() => _AuthRegisterViewState();
}

class _AuthRegisterViewState extends State<AuthRegisterView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _identityController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _pinConfirmController = TextEditingController();

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
    final String displayName = name.isNotEmpty ? name : widget.role.defaultDisplayName;
    widget.onAuthenticated(widget.role.key, displayName);

    if (mounted) {
      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${widget.role.defaultDisplayName} hesabı oluşturuldu. Hoş geldiniz, $displayName!',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _openLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => AuthLoginView(
          role: widget.role,
          onAuthenticated: widget.onAuthenticated,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Color actionColor = widget.role.isTenant
        ? AppColors.primaryCol(context)
        : AppColors.secondaryCol(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(widget.role.isTenant ? 'Kiracı Hesabı Aç' : 'Kiraya Veren Hesabı Aç'),
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
                _buildHeader(context),
                const SizedBox(height: 20),
                _buildFormFields(),
                const SizedBox(height: 24),
                AuthSubmitButton(
                  label: widget.role.isTenant ? 'Kiracı Hesabını Başlat' : 'Ev Sahibi Hesabını Başlat',
                  icon: Icons.person_add_rounded,
                  backgroundColor: actionColor,
                  onPressed: _handleRegister,
                ),
                const SizedBox(height: 14),
                AuthSwitchPrompt(
                  promptText: widget.role.isTenant
                      ? 'Zaten bir kiracı hesabınız var mı?'
                      : 'Zaten bir ev sahibi hesabınız var mı?',
                  actionText: 'Giriş Yapın',
                  actionColor: actionColor,
                  onTap: _openLogin,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AuthRoleBadge(
          roleName: widget.role.isTenant ? 'Yeni Kiracı Profili' : 'Mülk Sahibi Profili',
          icon: widget.role.roleIcon,
          isTenant: widget.role.isTenant,
        ),
        const SizedBox(height: 12),
        const Text(
          'Profilinizi Oluşturun',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          'Delil kayıtlarınız bu cihazda güvenle saklanacak ve kriptografik mühür alacaktır.',
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
          hintText: widget.role.isTenant ? 'Örn: Ahmet Yılmaz' : 'Örn: Mehmet Öz',
          prefixIcon: Icons.person_outline_rounded,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Lütfen adınızı ve soyadınızı girin';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        AuthTextField(
          controller: _contactController,
          label: 'E-posta veya Telefon',
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
        const SizedBox(height: 12),
        AuthTextField(
          controller: _identityController,
          label: 'T.C. Kimlik No (Opsiyonel - Yerel Doğrulama)',
          hintText: '11 haneli T.C. Kimlik Numarası',
          prefixIcon: Icons.badge_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        AuthTextField(
          controller: _pinController,
          label: 'Cihaz İçi Güvenlik PIN Kodu',
          hintText: '4-8 haneli PIN kodu belirleyin',
          prefixIcon: Icons.lock_outline_rounded,
          isPassword: true,
          keyboardType: TextInputType.number,
          validator: (val) {
            if (val == null || val.trim().length < 4) {
              return 'En az 4 haneli PIN kodu belirleyin';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        AuthTextField(
          controller: _pinConfirmController,
          label: 'PIN Kodunu Tekrar Girin',
          hintText: 'Belirlediğiniz PIN kodunu doğrulayın',
          prefixIcon: Icons.lock_reset_rounded,
          isPassword: true,
          keyboardType: TextInputType.number,
          validator: (val) {
            if (val == null || val.trim().isEmpty) {
              return 'Lütfen PIN kodunuzu doğrulayın';
            }
            return null;
          },
        ),
      ],
    );
  }
}

/// Kiracı Hesap Açma Ekranı (AuthRegisterView için tip korumalı sarmalayıcı)
class TenantRegisterView extends StatelessWidget {
  final Function(String role, String name) onAuthenticated;

  const TenantRegisterView({super.key, required this.onAuthenticated});

  @override
  Widget build(BuildContext context) {
    return AuthRegisterView(role: AuthRole.tenant, onAuthenticated: onAuthenticated);
  }
}

/// Ev Sahibi Hesap Açma Ekranı (AuthRegisterView için tip korumalı sarmalayıcı)
class LandlordRegisterView extends StatelessWidget {
  final Function(String role, String name) onAuthenticated;

  const LandlordRegisterView({super.key, required this.onAuthenticated});

  @override
  Widget build(BuildContext context) {
    return AuthRegisterView(role: AuthRole.landlord, onAuthenticated: onAuthenticated);
  }
}
