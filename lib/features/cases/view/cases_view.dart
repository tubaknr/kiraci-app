import 'package:flutter/material.dart';
import '../../../core/constants/view_status.dart';
import '../../../core/db/case_repository.dart';
import '../controller/case_create_controller.dart';
import '../controller/case_list_controller.dart';
import '../models/case_model.dart';
import 'case_create_view.dart';

/// Mock Dosyalarım Ekranı (Sümeyye T07'de güncelleyecek)
class CasesView extends StatefulWidget {
  final CaseListController controller;
  final Function(CaseModel)? onSelectCase;

  const CasesView({
    super.key,
    required this.controller,
    this.onSelectCase,
  });

  @override
  State<CasesView> createState() => _CasesViewState();
}

class _CasesViewState extends State<CasesView> {
  @override
  void initState() {
    super.initState();
    widget.controller.loadCases();
  }

  void _openCreateCase() {
    final createController = CaseCreateController(SqliteCaseRepository());
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CaseCreateView(
          controller: createController,
          onSuccess: () {
            createController.dispose();
            widget.controller.loadCases();
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dosyalarım'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => widget.controller.loadCases(),
          ),
        ],
      ),
      body: ValueListenableBuilder<ViewStatus>(
        valueListenable: widget.controller.status,
        builder: (context, status, _) {
          if (status == ViewStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return ValueListenableBuilder<List<CaseModel>>(
            valueListenable: widget.controller.cases,
            builder: (context, cases, _) {
              if (cases.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.folder_open, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text(
                        'Henüz bir kira dosyası oluşturulmadı.',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _openCreateCase,
                        icon: const Icon(Icons.add),
                        label: const Text('Yeni Dosya Aç'),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: cases.length,
                itemBuilder: (context, index) {
                  final item = cases[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Icon(item.myRole == 'tenant' ? Icons.person : Icons.home_work),
                      ),
                      title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${item.address}\nKarşı Taraf: ${item.otherPartyName}'),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => widget.onSelectCase?.call(item),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateCase,
        child: const Icon(Icons.add),
      ),
    );
  }
}
