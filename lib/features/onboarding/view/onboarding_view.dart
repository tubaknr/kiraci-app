import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

/// Onboarding ve KVKK / Aydınlatma Ekranı (Sümeyye - T04)
class OnboardingView extends StatefulWidget {
  final VoidCallback onCompleted;

  const OnboardingView({super.key, required this.onCompleted});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  final ValueNotifier<int> _currentPageNotifier = ValueNotifier<int>(0);
  final ValueNotifier<bool> _consentNotifier = ValueNotifier<bool>(false);

  final List<_OnboardingItem> _pages = const [
    _OnboardingItem(
      icon: Icons.shield_outlined,
      title: 'Çevrimdışı & Yerel Depolama',
      description:
          'Kira ilişkisine dair tüm belgeleriniz, fotoğraflarınız ve formlarınız yalnızca sizin cihazınızda yerel SQLite veritabanında saklanır. Hiçbir sunucuya veri aktarılmaz.',
      highlight: 'Tamamen cihazınızda güvenle saklanır.',
    ),
    _OnboardingItem(
      icon: Icons.link,
      title: 'Kriptografik SHA-256 Hash Zinciri',
      description:
          'Eklenen her delil parçası kendinden önceki kaydın özetiyle zincirlenir. Geriye dönük tahrifat, veri silme veya değiştirme denemeleri matematiksel olarak anında tespit edilir.',
      highlight: 'Append-only mimari ile tahrifat koruması.',
    ),
    _OnboardingItem(
      icon: Icons.gavel_outlined,
      title: 'Dürüst Sınırlar & Aydınlatma Metni',
      description:
          'Zaman damgaları cihaz saatine dayanır. Saat geri alınırsa sistem bunu anomali olarak işaretler. Kayıtların delil niteliği mahkemenin takdirindedir.',
      highlight: 'Doğrulanabilir kayıt, şeffaf sınırlar.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _currentPageNotifier.dispose();
    _consentNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () => _pageController.jumpToPage(_pages.length - 1),
                child: const Text('Atla'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (int index) => _currentPageNotifier.value = index,
                itemBuilder: (BuildContext context, int index) {
                  return _buildPageCard(_pages[index]);
                },
              ),
            ),
            _buildPageIndicator(),
            _buildConsentSection(),
            _buildBottomButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildPageCard(_OnboardingItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 12.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 48,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            child: Icon(item.icon, size: 48, color: AppColors.primary),
          ),
          const SizedBox(height: 24),
          Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.lightTextSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.secondary.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              item.highlight,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return ValueListenableBuilder<int>(
      valueListenable: _currentPageNotifier,
      builder: (BuildContext context, int activeIndex, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _pages.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 8,
              width: activeIndex == index ? 24 : 8,
              decoration: BoxDecoration(
                color: activeIndex == index ? AppColors.primary : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildConsentSection() {
    return ValueListenableBuilder<bool>(
      valueListenable: _consentNotifier,
      builder: (BuildContext context, bool isConsented, _) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isConsented ? AppColors.secondary : AppColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: isConsented,
                  onChanged: (bool? val) => _consentNotifier.value = val ?? false,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _consentNotifier.value = !_consentNotifier.value,
                    child: const Text(
                      'KVKK aydınlatma metnini, cihaz saati sınırlamalarını ve kullanım koşullarını okudum, anladım.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _showKvkkModal,
                  child: const Text('Oku', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomButtons() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 20),
      child: ValueListenableBuilder<bool>(
        valueListenable: _consentNotifier,
        builder: (BuildContext context, bool isConsented, _) {
          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isConsented ? widget.onCompleted : null,
              child: const Text('Uygulamaya Başla'),
            ),
          );
        },
      ),
    );
  }

  void _showKvkkModal() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return _buildKvkkModalContent(scrollController);
          },
        );
      },
    );
  }

  Widget _buildKvkkModalContent(ScrollController scrollController) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: ListView(
        controller: scrollController,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Aydınlatma & Dürüst Sınırlar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const Divider(),
          const SizedBox(height: 12),
          _buildInfoParagraph(
            '1. Zaman Damgası Güvenilirliği',
            'SafeRentHouse bağımsız ve çevrimdışı çalıştığından zaman damgaları cihaz saatini referans alır. Hash zinciri ve saat gerilemesi (clock anomaly) tespiti geriye dönük manipülasyonu görünür kılar ancak cihaz saatinin doğruluğunu mutlak olarak garanti etmez. Dış çapa (mühür kodunu e-posta ile iletmek) zaman kanıtını güçlendirir.',
          ),
          _buildInfoParagraph(
            '2. Delil Niteliği ve Hukuki Danışmanlık',
            'Bu uygulama hukuki danışmanlık hizmeti sunmaz. Uygulama "doğrulanabilir kayıt" üretir. Herhangi bir uyuşmazlıkta delillerin kabulü ve değerlendirilmesi münhasıran yetkili mahkemenin ve hâkimin takdirindedir.',
          ),
          _buildInfoParagraph(
            '3. Kişisel Veriler ve Gizlilik (KVKK)',
            'Girdiğiniz kiracı, ev sahibi, kira tutarları ve yüklenen fotoğraflar yalnızca cihazınızın yerel depolama alanında saklanır. Hiçbir harici bulut sunucusuna iletilmez. Yedekleme ve paylaşım sorumluluğu kullanıcıya aittir.',
          ),
          _buildInfoParagraph(
            '4. Ses ve Görüşme Kayıtları Uyarısı',
            'Karşı tarafın rızası veya haberi olmaksızın alınan ses ve iletişim kayıtları Türk Ceza Kanunu ve KVKK kapsamında hukuki ve cezai sorumluluk doğurabilir.',
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _consentNotifier.value = true;
              Navigator.of(context).pop();
            },
            child: const Text('Anladım ve Onaylıyorum'),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoParagraph(String title, String body) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.lightTextSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingItem {
  final IconData icon;
  final String title;
  final String description;
  final String highlight;

  const _OnboardingItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.highlight,
  });
}
