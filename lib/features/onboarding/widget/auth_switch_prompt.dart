import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

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
