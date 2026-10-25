import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Güvenlik protokolü ve KVKK aydınlatma modalı (Sümeyye - T04)
class OnboardingPolicyModal extends StatelessWidget {
  final VoidCallback onAccept;

  const OnboardingPolicyModal({super.key, required this.onAccept});

  static void show(BuildContext context, {required VoidCallback onAccept}) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBg(context),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) =>
            OnboardingPolicyModal(onAccept: onAccept),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      child: Column(
        children: [
          _buildDragHandle(),
          _buildModalHeader(context),
          const Divider(height: 24),
          Expanded(child: _buildPolicyContent()),
          const SizedBox(height: 12),
          _buildConfirmButton(context),
        ],
      ),
    );
  }

  Widget _buildDragHandle() {
    return Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.lightBorder,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildModalHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Güvenlik Protokolü & Aydınlatma',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        IconButton(
          icon: const Icon(Icons.close, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Widget _buildPolicyContent() {
    return ListView(
      children: const [
        _PolicySection(
          title: '1. Zaman Damgası & Cihaz Saati Sınırları',
          body:
              'SafeRentHouse tamamen çevrimdışı çalışır. Kayıt zamanı cihaz saatine dayanır. Hash zinciri ve saat anomalisi (clock anomaly) kontrolü geriye dönük manipülasyonu tespit eder ancak bağımsız resmî zaman damgası yerine geçmez. Mühür kodunun üçüncü bir tarafa e-posta ile iletilmesi bağımsız zaman kanıtı sağlar.',
        ),
        _PolicySection(
          title: '2. Delil Niteliği ve HMK Uyum Kapsamı',
          body:
              'Uygulama HMK Madde 199 kapsamında elektronik belge ve delil başlangıcı niteliğinde doğrulanabilir kayıt tutar. Hiçbir hukuki tavsiye vermez. Kayıtların nihai delil değerlendirmesi mahkemenin ve hakimin takdirindedir.',
        ),
        _PolicySection(
          title: '3. %100 Cihazda Depolama (Sıfır Bulut)',
          body:
              'Eklenen fotoğraflar, sözleşmeler ve ödeme dekontları yalnızca telefonunuzdaki korumalı SQLite veritabanında tutulur. Sunucuya, buluta veya harici hiçbir sisteme veri gönderilmez.',
        ),
        _PolicySection(
          title: '4. İletişim ve Ses Kayıtları Uyarısı',
          body:
              'Rıza dışı ses kaydı ve özel hayatın gizliliğini ihlal edebilecek belgelerin hukuki sorumluluğu kullanıcıya aittir. Yalnızca rızalı yazışma ve açık bildirimler kaydedilmelidir.',
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          Navigator.of(context).pop();
          onAccept();
        },
        child: const Text('Okudum, Anladım ve Kabul Ediyorum'),
      ),
    );
  }
}

class _PolicySection extends StatelessWidget {
  final String title;
  final String body;

  const _PolicySection({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textMain(context),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textMuted(context),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
