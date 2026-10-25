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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor ?? AppColors.cardBg(context),
      elevation: 0,
      scrolledUnderElevation: 1,
      title: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: AppColors.badgeBlueBgColor(context),
            child: Icon(Icons.timeline_rounded, size: 16, color: AppColors.primaryCol(context)),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SafeRentHouse',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain(context)),
              ),
              Text(
                'Zaman Tüneli',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted(context)),
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
              icon: Icon(Icons.notifications_none_rounded, size: 22, color: AppColors.textMain(context)),
              onPressed: () => _showNotificationSheet(context),
            ),
            const Positioned(
              top: 12,
              right: 12,
              child: CircleAvatar(radius: 4, backgroundColor: AppColors.error),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 14.0, left: 4.0),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () => _showProfileSheet(context),
            child: CircleAvatar(
              radius: 15,
              backgroundColor: AppColors.badgeIndigoBgColor(context),
              child: Icon(Icons.person, size: 18, color: AppColors.primaryCol(context)),
            ),
          ),
        ),
      ],
    );
  }

  void _showNotificationSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Zaman Tüneli Bildirimleri', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain(context))),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ],
              ),
              const Divider(),
              ListTile(
                leading: CircleAvatar(backgroundColor: AppColors.badgeGreenBgColor(context), child: const Icon(Icons.link, color: AppColors.success)),
                title: Text('Zincir Bağlantısı Aktif', style: TextStyle(color: AppColors.textMain(context))),
                subtitle: Text('Tüm bloklar geriye dönük hash kontrolünden başarıyla geçmiştir.', style: TextStyle(color: AppColors.textMuted(context))),
                dense: true,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showProfileSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: AppColors.primaryCol(context),
                child: const Icon(Icons.person, size: 36, color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text('Kullanıcı & Kasa Profili', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain(context))),
              Text('Çevrimdışı Bütünlük Korumalı Kasa', style: TextStyle(fontSize: 12, color: AppColors.textMuted(context))),
              const SizedBox(height: 16),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.vpn_key_outlined, color: AppColors.primary),
                title: const Text('Aktif Kasa ID'),
                subtitle: Text('#${widget.caseId}'),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Tamam'),
                ),
              ),
            ],
          ),
        );
      },
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
            Icon(Icons.timeline, size: 64, color: AppColors.textMuted(context)),
            const SizedBox(height: 16),
            Text(
              'Henüz delil veya form kaydı eklenmedi.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain(context)),
            ),
            const SizedBox(height: 8),
            Text(
              'Eklenen tüm belgeler, sözleşmeler ve tutanaklar tarih sırasıyla burada listelenir.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted(context), height: 1.4),
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
