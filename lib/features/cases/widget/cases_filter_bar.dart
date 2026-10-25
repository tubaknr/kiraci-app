import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Arama çubuğu ve dosya filtre çipleri (Sümeyye - T07 - Stitch UI)
class CasesFilterBar extends StatelessWidget {
  final int totalCount;
  final int selectedFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<int> onFilterSelected;

  const CasesFilterBar({
    super.key,
    required this.totalCount,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onFilterSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          _buildSearchField(),
          const SizedBox(height: 10),
          _buildFilterChips(),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: const InputDecoration(
          hintText: 'Adres, yıl veya duruma göre ara...',
          hintStyle: TextStyle(fontSize: 12, color: AppColors.lightTextHint),
          prefixIcon: Icon(Icons.search, size: 20, color: AppColors.lightTextSecondary),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(0, 'Tüm Dosyalar ($totalCount)'),
          const SizedBox(width: 8),
          _buildChip(1, 'Kiracı Dosyaları'),
          const SizedBox(width: 8),
          _buildChip(2, 'Çözülen İhtilaflar'),
        ],
      ),
    );
  }

  Widget _buildChip(int index, String label) {
    final bool isSelected = selectedFilter == index;

    return GestureDetector(
      onTap: () => onFilterSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
      ),
    );
  }
}
