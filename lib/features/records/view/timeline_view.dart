import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/db/record_repository.dart';
import '../../../core/services/integrity_service.dart';
import '../../../core/services/record_service.dart';
import '../../records/models/record_model.dart';
import '../controller/record_add_controller.dart';
import 'record_add_view.dart';
import 'record_detail_view.dart';

/// Zaman Çizelgesi ve Delil Zinciri Ekranı (Sümeyye - T10)
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zaman Çizelgesi & Zincir'),
        actions: [
          IconButton(
            tooltip: _newestFirst ? 'Eskiden Yeniye Sırala' : 'Yeniden Eskiye Sırala',
            icon: Icon(_newestFirst ? Icons.arrow_downward : Icons.arrow_upward),
            onPressed: () => setState(() => _newestFirst = !_newestFirst),
          ),
          IconButton(
            tooltip: 'Yenile ve Doğrula',
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_verification != null) _buildIntegritySummaryCard(),
                Expanded(
                  child: _records.isEmpty
                      ? _buildEmptyState()
                      : _buildTimelineList(),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddRecord,
        icon: const Icon(Icons.add),
        label: const Text('Delil Ekle'),
      ),
    );
  }

  Widget _buildIntegritySummaryCard() {
    final bool isValid = _verification!.isValid;
    final Color statusColor = isValid ? AppColors.success : AppColors.error;
    final int count = _records.length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: statusColor, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(isValid ? Icons.verified : Icons.gpp_bad, color: statusColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isValid ? 'Zincir Bütünlüğü Doğrulandı' : 'Tahrifat / Zincir Kırılması!',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isValid
                      ? '$count delil kaydı SHA-256 ile mühürlü • Tahrifat yok'
                      : (_verification!.failureReason ?? 'Veri tabanı veya dosya değiştirilmiş!'),
                  style: const TextStyle(fontSize: 11, color: AppColors.lightTextSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
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

  Widget _buildTimelineList() {
    final List<RecordModel> displayList = _newestFirst
        ? _records.reversed.toList()
        : _records;

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: displayList.length,
      itemBuilder: (BuildContext context, int index) {
        final RecordModel rec = displayList[index];
        return _buildTimelineItem(rec, index, displayList.length);
      },
    );
  }

  Widget _buildTimelineItem(RecordModel rec, int index, int total) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) => RecordDetailView(record: rec),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTypeAvatar(rec.type),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rec.title,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tarih: ${rec.recordedAt.toLocal().toString().substring(0, 16)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.lightTextSecondary),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Hash: ${rec.chainHash.substring(0, 16)}...',
                      style: const TextStyle(
                        fontSize: 11,
                        fontFamily: 'monospace',
                        color: AppColors.lightTextHint,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusPill(rec),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeAvatar(String type) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
      child: Icon(_getIconForType(type), size: 20, color: AppColors.primary),
    );
  }

  Widget _buildStatusPill(RecordModel rec) {
    if (rec.clockAnomaly) {
      return const Tooltip(
        message: 'Saat geriye alınmış (Saat anomalisi)',
        child: Icon(Icons.warning_amber_rounded, color: AppColors.warning),
      );
    }
    return const Icon(Icons.verified_outlined, color: AppColors.secondary, size: 20);
  }

  static IconData _getIconForType(String type) {
    switch (type) {
      case 'f1_lease':
      case 'f2_handover':
      case 'f3_defect':
      case 'f4_payment':
      case 'f5_incident':
        return Icons.assignment_outlined;
      case 'photo':
        return Icons.photo_camera_outlined;
      case 'video':
        return Icons.videocam_outlined;
      case 'audio':
        return Icons.mic_outlined;
      case 'chat':
        return Icons.chat_outlined;
      default:
        return Icons.description_outlined;
    }
  }
}
