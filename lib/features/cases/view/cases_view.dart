import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/view_status.dart';
import '../../../core/db/case_repository.dart';
import '../controller/case_create_controller.dart';
import '../controller/case_list_controller.dart';
import '../models/case_model.dart';
import 'case_create_view.dart';

/// Dosyalarım Ekranı (Sümeyye - T07)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kira Dosyalarım'),
        actions: [
          IconButton(
            tooltip: 'Yenile',
            icon: const Icon(Icons.refresh),
            onPressed: () => widget.controller.loadCases(),
          ),
        ],
      ),
      body: ValueListenableBuilder<ViewStatus>(
        valueListenable: widget.controller.status,
        builder: (BuildContext context, ViewStatus status, _) {
          if (status == ViewStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return _buildCaseList();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateCase,
        icon: const Icon(Icons.add),
        label: const Text('Yeni Dosya'),
      ),
    );
  }

  Widget _buildCaseList() {
    return ValueListenableBuilder<List<CaseModel>>(
      valueListenable: widget.controller.cases,
      builder: (BuildContext context, List<CaseModel> cases, _) {
        if (cases.isEmpty) {
          return _buildEmptyState();
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
          itemCount: cases.length,
          itemBuilder: (BuildContext context, int index) {
            return _buildCaseCard(cases[index]);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
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
              onPressed: _openCreateCase,
              icon: const Icon(Icons.add),
              label: const Text('İlk Dosyayı Oluştur'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseCard(CaseModel item) {
    final bool isTenant = item.myRole == 'tenant';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => widget.onSelectCase?.call(item),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCardHeader(item, isTenant),
              const SizedBox(height: 8),
              _buildCardAddress(item),
              const Divider(height: 20),
              _buildCardFooter(item),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader(CaseModel item, bool isTenant) {
    return Row(
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: isTenant
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.secondary.withValues(alpha: 0.1),
          child: Icon(
            isTenant ? Icons.person_outline : Icons.home_work_outlined,
            color: isTenant ? AppColors.primary : AppColors.secondary,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 2),
              Text(
                'Karşı Taraf: ${item.otherPartyName}',
                style: const TextStyle(fontSize: 13, color: AppColors.lightTextSecondary),
              ),
            ],
          ),
        ),
        _buildRoleBadge(isTenant),
      ],
    );
  }

  Widget _buildRoleBadge(bool isTenant) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isTenant
            ? AppColors.primary.withValues(alpha: 0.1)
            : AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isTenant ? AppColors.primary : AppColors.secondary,
          width: 0.8,
        ),
      ),
      child: Text(
        isTenant ? 'Kiracı' : 'Ev Sahibi',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isTenant ? AppColors.primary : AppColors.secondary,
        ),
      ),
    );
  }

  Widget _buildCardAddress(CaseModel item) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.location_on_outlined, size: 16, color: AppColors.lightTextSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            item.address,
            style: const TextStyle(fontSize: 13, color: AppColors.lightTextSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCardFooter(CaseModel item) {
    final String dateStr = item.leaseStart.toIso8601String().substring(0, 10);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Başlangıç: $dateStr',
          style: const TextStyle(fontSize: 12, color: AppColors.lightTextHint),
        ),
        const Row(
          children: [
            Text(
              'Delilleri Gör',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            Icon(Icons.chevron_right, size: 16, color: AppColors.primary),
          ],
        ),
      ],
    );
  }
}
