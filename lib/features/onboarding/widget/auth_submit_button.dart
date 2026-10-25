import 'package:flutter/material.dart';

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
