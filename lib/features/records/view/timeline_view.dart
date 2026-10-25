import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/db/record_repository.dart';
import '../../../core/services/integrity_service.dart';
import '../../../core/services/record_service.dart';
import '../../export/view/export_view.dart';
import '../controller/record_add_controller.dart';
import '../models/record_model.dart';
import '../widget/timeline_action_bar.dart';
import '../widget/timeline_card_item.dart';
import '../widget/timeline_hero_header.dart';
import '../widget/timeline_pdf_export_footer.dart';
import 'record_add_view.dart';
import 'record_detail_view.dart';

/// Zaman Çizelgesi ve Delil Zinciri Ekranı (Sümeyye - T10 - Stitch UI)
class TimelineView extends StatefulWidget {
  final String caseId;

  const TimelineView({super.key, required this.caseId});

  @override
  State<TimelineView> createState() => _TimelineViewState();
}

class _TimelineViewState extends State<TimelineView> {
  final RecordRepository _recordRepository = SqliteRecordRepository();
  final IntegrityService _integrityService = IntegrityService();

  List<RecordModel> _records = [];
  ChainVerificationResult? _verification;
  bool _loading = true;
  bool _newestFirst = true;
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final List<RecordModel> records = await _recordRepository.getByCase(widget.caseId);
    final ChainVerificationResult verification =
        await _integrityService.verifyChain(widget.caseId);
    if (mounted) {
      setState(() {
        _records = records;
        _verification = verification;
        _loading = false;
      });
    }
  }

  void _openAddRecord() {
    final controller = RecordAddController(RecordService());
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => RecordAddView(
          caseId: widget.caseId,
          controller: controller,
          onSuccess: () {
            controller.dispose();
            _loadData();
          },
        ),
      ),
    );
  }

  void _openPdfExport() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => ExportView(caseId: widget.caseId),
      ),
    );
  }

  List<RecordModel> _getFilteredRecords() {
    final List<RecordModel> source = _newestFirst ? _records.reversed.toList() : _records;

    return source.where((rec) {
      if (_selectedFilter == 1) {
        return rec.type == 'f1_lease' || rec.type == 'f2_handover' || rec.type == 'document';
      } else if (_selectedFilter == 2) {
        return rec.type == 'f4_payment';
      } else if (_selectedFilter == 3) {
        return rec.type == 'photo' || rec.type == 'f3_defect' || rec.type == 'video';
      } else if (_selectedFilter == 4) {
        return rec.type == 'chat' || rec.type == 'f5_incident' || rec.type == 'audio';
      }
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: _buildAppBar(),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _records.isEmpty
              ? _buildEmptyState()
              : _buildTimelineContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 1,
      title: const Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.badgeBlueBg,
            child: Icon(Icons.timeline_rounded, size: 16, color: AppColors.primary),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SafeRentHouse',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.lightTextPrimary),
              ),
              Text(
                'Zaman Tüneli',
                style: TextStyle(fontSize: 10, color: AppColors.lightTextSecondary),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          tooltip: 'Yenile ve Doğrula',
          icon: const Icon(Icons.verified_user_outlined, size: 20, color: AppColors.success),
          onPressed: _loadData,
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              tooltip: 'Bildirimler',
              icon: const Icon(Icons.notifications_none_rounded, size: 22),
              onPressed: () {},
            ),
            const Positioned(
              top: 12,
              right: 12,
              child: CircleAvatar(radius: 4, backgroundColor: AppColors.error),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.only(right: 14.0, left: 4.0),
          child: CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.badgeIndigoBg,
            child: Icon(Icons.person, size: 18, color: AppColors.primary),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineContent() {
    final filtered = _getFilteredRecords();
    final bool isChainValid = _verification?.isValid ?? true;

    return ListView(
      padding: const EdgeInsets.only(bottom: 40),
      children: [
        TimelineHeroHeader(
          caseTitle: widget.caseId,
          recordCount: _records.length,
          isChainValid: isChainValid,
        ),
        TimelineActionBar(
          totalCount: _records.length,
          selectedFilter: _selectedFilter,
          onAddRecord: _openAddRecord,
          onToggleSort: () => setState(() => _newestFirst = !_newestFirst),
          onFilterChanged: (idx) => setState(() => _selectedFilter = idx),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: List.generate(filtered.length, (index) {
              final rec = filtered[index];
              return TimelineCardItem(
                record: rec,
                index: index,
                totalCount: filtered.length,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) => RecordDetailView(record: rec),
                    ),
                  );
                },
              );
            }),
          ),
        ),
        TimelinePdfExportFooter(onExportPdf: _openPdfExport),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.timeline, size: 64, color: AppColors.lightTextHint),
            const SizedBox(height: 16),
            const Text(
              'Henüz delil veya form kaydı eklenmedi.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Eklenen tüm belgeler, sözleşmeler ve tutanaklar tarih sırasıyla burada listelenir.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.lightTextSecondary, height: 1.4),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _openAddRecord,
              icon: const Icon(Icons.add),
              label: const Text('İlk Delili Ekle'),
            ),
          ],
        ),
      ),
    );
  }
}
