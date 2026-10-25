import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/case_model.dart';

/// Zenginleştirilmiş Stitch kasa kartı bileşeni (Sümeyye - T07)
class CaseItemCard extends StatelessWidget {
  final CaseModel item;
  final VoidCallback onTap;

  const CaseItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isTenant = item.myRole == 'tenant';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg(context),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderCol(context)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCardHeader(context, isTenant),
                const SizedBox(height: 8),
                _buildAddressRow(context),
                const SizedBox(height: 10),
                _buildHighlightInfoBox(context),
                const SizedBox(height: 10),
                _buildRecentActivityRow(context),
                const SizedBox(height: 12),
                _buildActionButton(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(BuildContext context, bool isTenant) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildThumbnail(context, isTenant),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBadgesRow(context, isTenant),
              const SizedBox(height: 4),
              Text(
                item.title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  color: AppColors.textMain(context),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildThumbnail(BuildContext context, bool isTenant) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isTenant ? AppColors.badgeBlueBgColor(context) : AppColors.badgeGreenBgColor(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderCol(context)),
      ),
      child: Icon(
        isTenant ? Icons.apartment_rounded : Icons.home_work_rounded,
        size: 26,
        color: isTenant ? AppColors.primaryCol(context) : AppColors.secondaryCol(context),
      ),
    );
  }

  Widget _buildBadgesRow(BuildContext context, bool isTenant) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.badgeIndigoBgColor(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.location_on, size: 10, color: AppColors.badgeIndigoTextColor(context)),
              const SizedBox(width: 3),
              Text(
                isTenant ? 'Kiracı' : 'Ev Sahibi',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.badgeIndigoTextColor(context),
                ),
              ),
              Text(
                ' Dosyası',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.badgeIndigoTextColor(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.badgeGreenBgColor(context),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.check_circle_outline, size: 10, color: AppColors.badgeGreenTextColor(context)),
              const SizedBox(width: 3),
              Text(
                'Mühürlü Kayıtlar',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.badgeGreenTextColor(context),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAddressRow(BuildContext context) {
    return Row(
      children: [
        Icon(Icons.location_on_outlined, size: 14, color: AppColors.textMuted(context)),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            item.address,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted(context),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildHighlightInfoBox(BuildContext context) {
    final String startYear = item.leaseStart.year.toString();
    final String endYear = item.leaseEnd != null ? item.leaseEnd!.year.toString() : 'Süresiz';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.badgeBlueBg.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'KİRA SÜRESİ',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.textMuted(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$startYear - $endYear',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryCol(context),
                ),
              ),
            ],
          ),
          Container(height: 24, width: 1, color: AppColors.borderCol(context)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'KARŞI TARAF',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                  color: AppColors.textMuted(context),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Karşı Taraf: ${item.otherPartyName}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMain(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const CircleAvatar(radius: 3, backgroundColor: AppColors.success),
            const SizedBox(width: 6),
            Text(
              'Son kayıt: Kriptografik Tutanak / Makbuz',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted(context),
              ),
            ),
          ],
        ),
        Text(
          'Güncel',
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textMuted(context),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 42,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryCol(context),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onTap,
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Zaman Çizelgesi ve Delilleri Aç',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            SizedBox(width: 8),
            Icon(Icons.arrow_forward_rounded, size: 16),
          ],
        ),
      ),
    );
  }
}
