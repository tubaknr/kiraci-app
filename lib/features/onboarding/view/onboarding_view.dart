import 'package:flutter/material.dart';

/// Mock Onboarding & KVKK Ekranı (Sümeyye T04'te güncelleyecek)
class OnboardingView extends StatelessWidget {
  final VoidCallback onCompleted;

  const OnboardingView({super.key, required this.onCompleted});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SafeRentHouse'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.shield_outlined,
                size: 80,
                color: Color(0xFF1E88E5),
              ),
              const SizedBox(height: 24),
              const Text(
                'Güvenli Kira & Delil Kayıt',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Bu uygulama kiracı ve ev sahipleri arasındaki süreçleri tarihli, sıralı ve değiştirilemez delil zinciriyle cihazınızda saklar. Verileriniz sunucuya aktarılmaz.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade700),
                ),
                child: const Text(
                  'Önemli Bilgilendirme: Kayıt zamanları cihaz saatine dayanır. Uygulama hukuki danışmanlık vermez; bağımsız olarak doğrulanabilir kayıt tutar.',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: onCompleted,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Kabul Et ve Başla'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
