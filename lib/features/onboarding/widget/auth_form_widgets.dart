import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Temaya duyarlı, şifre gizleme özellikli kimlik giriş alanı (Sümeyye - SOLID SRP)
class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hintText;
  final IconData prefixIcon;
  final bool isPassword;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hintText,
    required this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context),
        const SizedBox(height: 6),
        _buildTextFormField(context),
      ],
    );
  }

  Widget _buildLabel(BuildContext context) {
    return Text(
      widget.label,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textMain(context),
      ),
    );
  }

  Widget _buildTextFormField(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword && _obscured,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      style: TextStyle(fontSize: 14, color: AppColors.textMain(context)),
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: TextStyle(fontSize: 13, color: AppColors.textMuted(context)),
        prefixIcon: Icon(widget.prefixIcon, size: 20, color: AppColors.textMuted(context)),
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.textMuted(context),
                ),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
        filled: true,
        fillColor: AppColors.cardBg(context),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderCol(context)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.borderCol(context)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryCol(context), width: 1.8),
        ),
      ),
    );
  }
}

/// Giriş/Kayıt ekranlarında aktif rolü gösteren rozet (Sümeyye - SOLID SRP)
class AuthRoleBadge extends StatelessWidget {
  final String roleName;
  final IconData icon;
  final bool isTenant;

  const AuthRoleBadge({
    super.key,
    required this.roleName,
    required this.icon,
    required this.isTenant,
  });

  @override
  Widget build(BuildContext context) {
    final Color badgeBg = isTenant ? AppColors.badgeBlueBgColor(context) : AppColors.badgeGreenBgColor(context);
    final Color badgeColor = isTenant ? AppColors.primaryCol(context) : AppColors.secondaryCol(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: badgeColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: badgeColor),
          const SizedBox(width: 6),
          Text(
            roleName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// Giriş ve Kayıt aksiyon butonu (Sümeyye - SOLID SRP)
class AuthSubmitButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color backgroundColor;
  final bool isLoading;
  final VoidCallback onPressed;

  const AuthSubmitButton({
    super.key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    this.isLoading = false,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: Colors.white,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    label,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
      ),
    );
  }
}

/// Giriş ile Kayıt ekranları arasında geçiş sağlayan alt metin bağlantısı (Sümeyye - SOLID SRP)
class AuthSwitchPrompt extends StatelessWidget {
  final String promptText;
  final String actionText;
  final Color actionColor;
  final VoidCallback onTap;

  const AuthSwitchPrompt({
    super.key,
    required this.promptText,
    required this.actionText,
    required this.actionColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          promptText,
          style: TextStyle(fontSize: 13, color: AppColors.textMuted(context)),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onTap,
          child: Text(
            actionText,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: actionColor,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }
}
