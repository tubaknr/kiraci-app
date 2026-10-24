import 'package:flutter/material.dart';
import 'core/db/case_repository.dart';
import 'core/theme/app_theme.dart';
import 'features/cases/controller/case_list_controller.dart';
import 'features/cases/models/case_model.dart';
import 'features/cases/view/cases_view.dart';
import 'features/forms/view/forms_menu_view.dart';
import 'features/onboarding/view/onboarding_view.dart';
import 'features/records/view/timeline_view.dart';
import 'features/settings/view/settings_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const SafeRentHouseApp());
}

/// Uygulama Ana Girişi (Sümeyye - T02: Tema ve `ValueNotifier<ThemeMode>` entegrasyonu)
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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppTheme.themeModeNotifier,
      builder: (BuildContext context, ThemeMode currentThemeMode, _) {
        return MaterialApp(
          title: 'SafeRentHouse',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,
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
                      SettingsView(
                        onShowOnboarding: () => setState(() => _hasSeenOnboarding = false),
                      ),
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
                        icon: Icon(Icons.settings_outlined),
                        selectedIcon: Icon(Icons.settings),
                        label: 'Ayarlar & Bilgi',
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
