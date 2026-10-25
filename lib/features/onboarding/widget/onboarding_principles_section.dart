import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import 'onboarding_principle_card.dart';

/// Temel mimari ilkeler bölümü (Sümeyye - T04)
class OnboardingPrinciplesSection extends StatelessWidget {
  const OnboardingPrinciplesSection({super.key});

  static const List<OnboardingPrincipleItem> _items = [
    OnboardingPrincipleItem(
      icon: Icons.phone_android_rounded,
      iconColor: AppColors.primaryLight,
      iconBgColor: AppColors.badgeBlueBg,
      title: '100% Yerel ve Gizli Depolama',
      badgeText: 'Çevrimdışı',
      badgeBgColor: AppColors.badgeBlueBg,
      badgeTextColor: AppColors.badgeBlueText,
      description:
          'Tüm belgeler, fotoğraflar ve ses/video kayıtları yalnızca cihazınızda saklanır. Açık izniniz olmadan buluta hiçbir veri aktarılmaz.',
    ),
    OnboardingPrincipleItem(
      icon: Icons.hub_outlined,
      iconColor: AppColors.secondary,
      iconBgColor: AppColors.badgeGreenBg,
      title: 'SHA-256 Kriptografik Özet Zinciri',
      badgeText: 'Değiştirilemez',
      badgeBgColor: AppColors.badgeGreenBg,
      badgeTextColor: AppColors.badgeGreenText,
      badgeIcon: Icons.link,
      description:
          'Eklenen her fotoğraf, sözleşme ve dekont oluşturulduğu anda değiştirilemez kriptografik parmak izi alır; sonradan tahrif edilemez.',
    ),
    OnboardingPrincipleItem(
      icon: Icons.verified_outlined,
      iconColor: AppColors.warning,
      iconBgColor: AppColors.badgeAmberBg,
      title: 'Cihaz Saati & Konum Damgası',
      badgeText: 'NTP Doğrulamalı',
      badgeBgColor: AppColors.badgeBlueBg,
      badgeTextColor: AppColors.badgeBlueText,
      description:
          'Gömülü müdahale korumalı meta veriler, her kaydı gerçek çekim zamanı ve konumuyla mühürleyerek tartışmasız delil değeri kazandırır.',
    ),
    OnboardingPrincipleItem(
      icon: Icons.account_balance_outlined,
      iconColor: AppColors.primary,
      iconBgColor: AppColors.badgeIndigoBg,
      title: 'MAHKEME VE ARABULUCULUK GEÇERLİLİĞİ',
      badgeText: '',
      badgeBgColor: Colors.transparent,
      badgeTextColor: Colors.transparent,
      isFeatured: true,
      description:
          'HMK Madde 199 elektronik delil standartları ve uluslararası eIDAS yönergeleriyle tam uyumlu. Oluşturulan denetim dosyaları tam özet doğrulama belgeleri ve zincir makbuzları içerir.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader(),
          const SizedBox(height: 12),
          ..._items.map((item) => OnboardingPrincipleCard(item: item)),
        ],
      ),
    );
  }

  Widget _buildSectionHeader() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'TEMEL MİMARİ İLKELER',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.lightTextSecondary,
          ),
        ),
        Row(
          children: [
            Icon(Icons.verified_outlined, size: 14, color: AppColors.primaryLight),
            SizedBox(width: 4),
            Text(
              'Sıfır Güven Modeli',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryLight,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
