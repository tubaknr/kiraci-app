import 'package:flutter/material.dart';
import 'core/db/case_repository.dart';
import 'core/theme/app_theme.dart';
import 'features/cases/controller/case_list_controller.dart';
import 'features/cases/models/case_model.dart';
import 'features/cases/view/cases_view.dart';
import 'features/forms/view/forms_menu_view.dart';
import 'features/onboarding/view/onboarding_view.dart';
import 'features/records/view/timeline_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SafeRentHouseApp());
}

/// Uygulama Ana Girişi (Mock Navigasyon - Sümeyye T02 & T04'te nihai haline getirecek)
class SafeRentHouseApp extends StatefulWidget {
  const SafeRentHouseApp({super.key});

  @override
  State<SafeRentHouseApp> createState() => _SafeRentHouseAppState();
}

class _SafeRentHouseAppState extends State<SafeRentHouseApp> {
  bool _hasSeenOnboarding = true; // Geliştirme kolaylığı için varsayılan true
  int _currentIndex = 0;
  String _activeCaseId = 'varsayilan_case_1';

  late final CaseListController _caseListController;

  @override
  void initState() {
    super.initState();
    _caseListController = CaseListController(SqliteCaseRepository());
  }

  @override
  void dispose() {
    _caseListController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeRentHouse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: !_hasSeenOnboarding
          ? OnboardingView(
              onCompleted: () => setState(() => _hasSeenOnboarding = true),
            )
          : Scaffold(
              body: IndexedStack(
                index: _currentIndex,
                children: [
                  CasesView(
                    controller: _caseListController,
                    onSelectCase: (CaseModel selected) {
                      setState(() {
                        _activeCaseId = selected.id;
                        _currentIndex = 1; // Zaman çizelgesine geç
                      });
                    },
                  ),
                  TimelineView(caseId: _activeCaseId),
                  FormsMenuView(currentCaseId: _activeCaseId),
                  _buildAboutView(),
                ],
              ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) => setState(() => _currentIndex = index),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.folder_outlined),
                    selectedIcon: Icon(Icons.folder),
                    label: 'Dosyalarım',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.timeline_outlined),
                    selectedIcon: Icon(Icons.timeline),
                    label: 'Zaman Çizelgesi',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.description_outlined),
                    selectedIcon: Icon(Icons.description),
                    label: 'Formlar',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.info_outline),
                    selectedIcon: Icon(Icons.info),
                    label: 'Bilgi & KVKK',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAboutView() {
    return Scaffold(
      appBar: AppBar(title: const Text('Hakkında & Geliştirme Durumu')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SafeRentHouse Geliştirme Ortamı',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tuba tarafından veri, SQLite şeması, hash zinciri, SHA-256 bütünlüğü ve F1 form motoru tamamlanmıştır.',
                      style: TextStyle(color: Colors.blueGrey),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Sümeyye arayüz ve tema görevlerini tamamlayana kadar bu ekranlar Tuba\'nın yazdığı mantığı test edebilmeniz için mock olarak sunulmaktadır.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => setState(() => _hasSeenOnboarding = false),
              child: const Text('Onboarding & KVKK Ekranını Yeniden Göster'),
            ),
          ],
        ),
      ),
    );
  }
}
