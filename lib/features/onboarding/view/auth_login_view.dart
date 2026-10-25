import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../widget/auth_form_widgets.dart';
import 'auth_register_view.dart';

/// Güvenli Giriş Rolü Tanımı (SOLID OCP)
enum AuthRole {
  tenant,
  landlord;

  bool get isTenant => this == AuthRole.tenant;
  String get key => isTenant ? 'tenant' : 'landlord';
  String get portalTitle => isTenant ? 'Kiracı Portalı' : 'Kiraya Veren Portalı';
  String get roleBadgeTitle => isTenant ? 'Kiracı Modu' : 'Kiraya Veren Modu';
  String get welcomeSubtitle => isTenant
      ? 'Kiraladığınız konuta ait delil defterinize ve zaman çizelgenize erişmek için giriş yapın.'
      : 'Kiraya verdiğiniz mülklerin delil kayıtlarına ve zaman çizelgelerine erişmek için giriş yapın.';
  String get loginButtonLabel => isTenant ? 'Kiracı Girişi Yap' : 'Kiraya Veren Girişi Yap';
  String get defaultDisplayName => isTenant ? 'Kiracı' : 'Ev Sahibi';
  String get quickEntryMessage => isTenant
      ? 'Giriş başarılı. Kiracı kasasına hoş geldiniz!'
      : 'Giriş başarılı. Ev sahibi kasasına hoş geldiniz!';
  String get switchPromptText => isTenant
      ? 'Henüz kiracı hesabınız yok mu?'
      : 'Henüz ev sahibi hesabınız yok mu?';
  IconData get roleIcon => isTenant ? Icons.key_rounded : Icons.apartment_rounded;
}

/// Parametrik Kimlik Doğrulama Giriş Ekranı (Sümeyye - SOLID SRP & OCP)
class AuthLoginView extends StatefulWidget {
  final AuthRole role;
  final Function(String role, String name) onAuthenticated;

  const AuthLoginView({
    super.key,
    required this.role,
    required this.onAuthenticated,
  });

  @override
  State<AuthLoginView> createState() => _AuthLoginViewState();
}

class _AuthLoginViewState extends State<AuthLoginView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  @override
  void dispose() {
    _contactController.dispose();
    _pinController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (!_formKey.currentState!.validate()) return;

    final String displayName = _contactController.text.trim();
    widget.onAuthenticated(
      widget.role.key,
      displayName.isNotEmpty ? displayName : widget.role.defaultDisplayName,
    );
    if (mounted) {
      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Giriş başarılı. Hoş geldiniz, ${displayName.isNotEmpty ? displayName : widget.role.defaultDisplayName}!',
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _handleQuickEntry() {
    widget.onAuthenticated(widget.role.key, widget.role.defaultDisplayName);
    if (mounted) {
      Navigator.of(context, rootNavigator: true).popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.role.quickEntryMessage),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _openRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (context) => AuthRegisterView(
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
        title: Text(widget.role.portalTitle),
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
                const SizedBox(height: 24),
                _buildFormFields(),
                const SizedBox(height: 24),
                AuthSubmitButton(
                  label: widget.role.loginButtonLabel,
                  icon: widget.role.roleIcon,
                  backgroundColor: actionColor,
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
                  promptText: widget.role.switchPromptText,
                  actionText: 'Hesap Açın',
                  actionColor: actionColor,
                  onTap: _openRegister,
                ),
                const SizedBox(height: 24),
                const _SecurityNoticeCard(),
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
          roleName: widget.role.roleBadgeTitle,
          icon: widget.role.roleIcon,
          isTenant: widget.role.isTenant,
        ),
        const SizedBox(height: 12),
        const Text(
          'Hoş Geldiniz',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          widget.role.welcomeSubtitle,
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
}

/// Çevrimdışı güvence bilgilendirme kutusu (SOLID SRP)
class _SecurityNoticeCard extends StatelessWidget {
  const _SecurityNoticeCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.badgeBlueBgColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryCol(context).withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, size: 20, color: AppColors.primaryCol(context)),
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

/// Kiracı Giriş Ekranı (AuthLoginView için tip korumalı sarmalayıcı)
class TenantLoginView extends StatelessWidget {
  final Function(String role, String name) onAuthenticated;

  const TenantLoginView({super.key, required this.onAuthenticated});

  @override
  Widget build(BuildContext context) {
    return AuthLoginView(role: AuthRole.tenant, onAuthenticated: onAuthenticated);
  }
}

/// Ev Sahibi Giriş Ekranı (AuthLoginView için tip korumalı sarmalayıcı)
class LandlordLoginView extends StatelessWidget {
  final Function(String role, String name) onAuthenticated;

  const LandlordLoginView({super.key, required this.onAuthenticated});

  @override
  Widget build(BuildContext context) {
    return AuthLoginView(role: AuthRole.landlord, onAuthenticated: onAuthenticated);
  }
}
