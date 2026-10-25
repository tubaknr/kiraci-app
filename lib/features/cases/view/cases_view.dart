import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/view_status.dart';
import '../../../core/db/case_repository.dart';
import '../controller/case_create_controller.dart';
import '../controller/case_list_controller.dart';
import '../models/case_model.dart';
import '../widget/case_item_card.dart';
import '../widget/cases_app_bar.dart';
import '../widget/cases_empty_state.dart';
import '../widget/cases_filter_bar.dart';
import '../widget/cases_integrity_banner.dart';
import '../widget/cases_metrics_overview.dart';
import 'case_create_view.dart';

/// Dosyalarım & Kiralık Mülk Delil Kasaları Ekranı (Sümeyye - T07 - Stitch UI)
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
  String _searchQuery = '';
  int _selectedFilter = 0; // 0: Tüm, 1: Kiracı, 2: Ev Sahibi/Çözülen

  @override
  void initState() {
    super.initState();
    widget.controller.loadCases();
  }

  void _openCreateCase() {
    final CaseCreateController createController =
        CaseCreateController(SqliteCaseRepository());
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => CaseCreateView(
          controller: createController,
          onSuccess: () {
            createController.dispose();
            widget.controller.loadCases();
          },
        ),
      ),
    );
  }

  List<CaseModel> _filterCases(List<CaseModel> items) {
    return items.where((item) {
      if (_selectedFilter == 1 && item.myRole != 'tenant') return false;
      if (_selectedFilter == 2 && item.myRole != 'landlord') return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matches = item.title.toLowerCase().contains(q) ||
            item.address.toLowerCase().contains(q) ||
            item.otherPartyName.toLowerCase().contains(q);
        if (!matches) return false;
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CasesAppBar(onRefresh: () => widget.controller.loadCases()),
      body: ValueListenableBuilder<ViewStatus>(
        valueListenable: widget.controller.status,
        builder: (BuildContext context, ViewStatus status, _) {
          if (status == ViewStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildBody();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: _openCreateCase,
        icon: const Icon(Icons.add, size: 20),
        label: const Text('Yeni Dosya', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildBody() {
    return ValueListenableBuilder<List<CaseModel>>(
      valueListenable: widget.controller.cases,
      builder: (BuildContext context, List<CaseModel> cases, _) {
        if (cases.isEmpty) {
          return CasesEmptyState(onCreateCase: _openCreateCase);
        }

        final filtered = _filterCases(cases);

        return ListView(
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 90),
          children: [
            CasesIntegrityBanner(totalRecords: cases.length * 8),
            CasesMetricsOverview(
              activeCases: cases.length,
              totalEvidence: cases.length * 8,
            ),
            CasesFilterBar(
              totalCount: cases.length,
              selectedFilter: _selectedFilter,
              onSearchChanged: (q) => setState(() => _searchQuery = q.trim()),
              onFilterSelected: (idx) => setState(() => _selectedFilter = idx),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: filtered.map((c) {
                  return CaseItemCard(
                    item: c,
                    onTap: () => widget.onSelectCase?.call(c),
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }
}
