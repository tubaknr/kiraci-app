import 'package:flutter/material.dart';
import '../widget/onboarding_bottom_bar.dart';
import '../widget/onboarding_header.dart';
import '../widget/onboarding_hero_graphic.dart';
import '../widget/onboarding_mini_feature_cards.dart';
import '../widget/onboarding_policy_modal.dart';
import '../widget/onboarding_principles_section.dart';

/// Onboarding ve Hukuki Güvence Ekranı (Sümeyye - T04)
/// Google Stitch tasarımına ve projenin dürüst mimari ilkelerine uygun olarak inşa edilmiştir.
class OnboardingView extends StatefulWidget {
  final VoidCallback onCompleted;

  const OnboardingView({super.key, required this.onCompleted});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final ValueNotifier<bool> _consentNotifier = ValueNotifier<bool>(false);

  @override
  void dispose() {
    _consentNotifier.dispose();
    super.dispose();
  }

  void _openPolicy() {
    OnboardingPolicyModal.show(
      context,
      onAccept: () => _consentNotifier.value = true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  children: [
                    OnboardingHeader(),
                    OnboardingHeroGraphic(),
                    OnboardingPrinciplesSection(),
                    SizedBox(height: 12),
                    OnboardingMiniFeatureCards(),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            OnboardingBottomBar(
              consentNotifier: _consentNotifier,
              onContinue: widget.onCompleted,
              onOpenPolicy: _openPolicy,
            ),
          ],
        ),
      ),
    );
  }
}
