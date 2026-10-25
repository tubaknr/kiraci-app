import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Zaman tüneli kayıt ekleme ve filtre çipleri barı (Sümeyye - T10 - Stitch UI)
class TimelineActionBar extends StatelessWidget {
  final int totalCount;
  final int selectedFilter;
  final VoidCallback onAddRecord;
  final VoidCallback onToggleSort;
  final ValueChanged<int> onFilterChanged;

  const TimelineActionBar({
    super.key,
    required this.totalCount,
    required this.selectedFilter,
    required this.onAddRecord,
    required this.onToggleSort,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: Column(
        children: [
          _buildActionButtonsRow(context),
          const SizedBox(height: 10),
          _buildFilterChipsRow(context),
        ],
      ),
    );
  }

  Widget _buildActionButtonsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryCol(context),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              onPressed: onAddRecord,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text(
                'Kayıt Ekle',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: onToggleSort,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.badgeBlueBgColor(context),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.2)),
            ),
            child: Icon(Icons.tune, color: AppColors.primaryCol(context), size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChipsRow(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(context, 0, 'Tümü', '$totalCount'),
          const SizedBox(width: 8),
          _buildChip(context, 1, 'Sözleşmeler', null),
          const SizedBox(width: 8),
          _buildChip(context, 2, 'Ödemeler', null),
          const SizedBox(width: 8),
          _buildChip(context, 3, 'Tadilat & Foto', null),
          const SizedBox(width: 8),
          _buildChip(context, 4, 'Yazışmalar', null),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, int index, String label, String? countBadge) {
    final bool isSelected = selectedFilter == index;

    return GestureDetector(
      onTap: () => onFilterChanged(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryCol(context) : AppColors.cardBg(context),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryCol(context) : AppColors.borderCol(context),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.textMain(context),
              ),
            ),
            if (countBadge != null) ...[
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : AppColors.badgeBlueBgColor(context),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  countBadge,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.primaryCol(context) : AppColors.primaryLight,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
