import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Boş kasa ekranı durumu (Sümeyye - T07)
class CasesEmptyState extends StatelessWidget {
  final VoidCallback onCreateCase;

  const CasesEmptyState({super.key, required this.onCreateCase});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: const Icon(Icons.folder_open, size: 40, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text(
              'Kayıtlı Kira Dosyası Bulunamadı',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tüm delil zinciri, formlar ve tutanaklar bir kira dosyası altında toplanır. Başlamak için yeni bir dosya oluşturun.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.lightTextSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onCreateCase,
              icon: const Icon(Icons.add),
              label: const Text('İlk Dosyayı Oluştur'),
            ),
          ],
        ),
      ),
    );
  }
}
