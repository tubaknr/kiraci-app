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
