import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Temel mimari ilke kartı modeli
class OnboardingPrincipleItem {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String badgeText;
  final Color badgeBgColor;
  final Color badgeTextColor;
  final IconData? badgeIcon;
  final String description;
  final bool isFeatured;

  const OnboardingPrincipleItem({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.badgeText,
    required this.badgeBgColor,
    required this.badgeTextColor,
    this.badgeIcon,
    required this.description,
    this.isFeatured = false,
  });
}

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

/// Mimari ilke kartı widget'ı (Sümeyye - T04)
class OnboardingPrincipleCard extends StatelessWidget {
  final OnboardingPrincipleItem item;

  const OnboardingPrincipleCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: item.isFeatured
            ? AppColors.badgeBlueBg.withValues(alpha: 0.4)
            : AppColors.cardBg(context),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isFeatured
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.borderCol(context),
          width: item.isFeatured ? 1.2 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(),
          const SizedBox(height: 8),
          _buildDescription(context),
        ],
      ),
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: item.iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(item.icon, size: 20, color: item.iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ),
        if (item.badgeText.isNotEmpty) _buildBadge(),
      ],
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: item.badgeBgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (item.badgeIcon != null) ...[
            Icon(item.badgeIcon, size: 11, color: item.badgeTextColor),
            const SizedBox(width: 3),
          ],
          Text(
            item.badgeText,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: item.badgeTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 46.0),
      child: Text(
        item.description,
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textMuted(context),
          height: 1.45,
        ),
      ),
    );
  }
}
