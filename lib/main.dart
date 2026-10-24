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
                      _buildSettingsAndAboutView(currentThemeMode),
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

  Widget _buildSettingsAndAboutView(ThemeMode currentThemeMode) {
    final bool isDark = currentThemeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ayarlar & Bilgi'),
        actions: [
          IconButton(
            tooltip: isDark ? 'Açık Temaya Geç' : 'Koyu Temaya Geç',
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: AppTheme.toggleTheme,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: ListTile(
              leading: Icon(
                isDark ? Icons.dark_mode : Icons.light_mode,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Uygulama Teması'),
              subtitle: Text(
                currentThemeMode == ThemeMode.system
                    ? 'Sistem Varsayılanı'
                    : (isDark ? 'Koyu Tema' : 'Açık Tema'),
              ),
              trailing: DropdownButton<ThemeMode>(
                value: currentThemeMode,
                underline: const SizedBox.shrink(),
                items: const [
                  DropdownMenuItem(
                    value: ThemeMode.system,
                    child: Text('Sistem'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.light,
                    child: Text('Açık'),
                  ),
                  DropdownMenuItem(
                    value: ThemeMode.dark,
                    child: Text('Koyu'),
                  ),
                ],
                onChanged: (ThemeMode? newMode) {
                  if (newMode != null) {
                    AppTheme.setThemeMode(newMode);
                  }
                },
              ),
            ),
          ),
          const SizedBox(height: 12),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SafeRentHouse',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Kiracı ve ev sahipleri için çevrimdışı, SHA-256 hash zinciri destekli doğrulanabilir delil ve kayıt defteri.',
                    style: TextStyle(color: Colors.blueGrey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Tüm veriler yerel SQLite üzerinde tutulur ve üçüncü taraf sunuculara iletilmez.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            icon: const Icon(Icons.replay),
            label: const Text('Onboarding & KVKK Ekranını Göster'),
            onPressed: () => setState(() => _hasSeenOnboarding = false),
          ),
        ],
      ),
    );
  }
}
