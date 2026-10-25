import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Onboarding alt onay kutusu, devam butonu ve gizlilik protokolü bağlantısı (Sümeyye - T04)
class OnboardingBottomBar extends StatelessWidget {
  final ValueNotifier<bool> consentNotifier;
  final VoidCallback onContinue;
  final VoidCallback onOpenPolicy;

  const OnboardingBottomBar({
    super.key,
    required this.consentNotifier,
    required this.onContinue,
    required this.onOpenPolicy,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        children: [
          _buildConsentCheckbox(),
          const SizedBox(height: 14),
          _buildSubmitButton(),
          const SizedBox(height: 12),
          _buildPolicyLink(context),
        ],
      ),
    );
  }

  Widget _buildConsentCheckbox() {
    return ValueListenableBuilder<bool>(
      valueListenable: consentNotifier,
      builder: (BuildContext context, bool isConsented, _) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: isConsented,
              activeColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              side: BorderSide(color: AppColors.borderCol(context), width: 1.5),
              onChanged: (bool? val) => consentNotifier.value = val ?? false,
            ),
            Expanded(
              child: Text(
                'Kriptografik anahtarların bu cihazda tutulduğunu anlıyorum',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMain(context),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return ValueListenableBuilder<bool>(
      valueListenable: consentNotifier,
      builder: (BuildContext context, bool isConsented, _) {
        return SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isConsented ? AppColors.primary : AppColors.borderCol(context),
              foregroundColor: Colors.white,
              elevation: isConsented ? 2 : 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: isConsented ? onContinue : null,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Şartları Kabul Et ve Devam Et',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 18),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPolicyLink(BuildContext context) {
    return GestureDetector(
      onTap: onOpenPolicy,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Delil Güvenlik Protokolü & Gizlilik Politikasını Oku',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted(context),
              decoration: TextDecoration.underline,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.open_in_new_rounded,
            size: 12,
            color: AppColors.textMuted(context),
          ),
        ],
      ),
    );
  }
}
