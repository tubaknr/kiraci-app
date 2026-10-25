import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Boş kasa ekranı durumu (Sümeyye - T07)
class CasesEmptyState extends StatelessWidget {
  final VoidCallback onCreateCase;

  const CasesEmptyState({super.key, required this.onCreateCase});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = AppColors.primaryCol(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: primaryColor.withValues(alpha: 0.15),
              child: Icon(Icons.folder_open, size: 40, color: primaryColor),
            ),
            const SizedBox(height: 20),
            Text(
              'Kayıtlı Kira Dosyası Bulunamadı',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textMain(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tüm delil zinciri, formlar ve tutanaklar bir kira dosyası altında toplanır. Başlamak için yeni bir dosya oluşturun.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted(context), height: 1.4),
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
