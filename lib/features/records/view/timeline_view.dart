import 'package:flutter/material.dart';
import '../../../core/db/record_repository.dart';
import '../../../core/services/integrity_service.dart';
import '../../records/models/record_model.dart';
import 'record_detail_view.dart';

/// Mock Zaman Çizelgesi Ekranı (Sümeyye T10'da güncelleyecek)
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

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final records = await _recordRepository.getByCase(widget.caseId);
    final verification = await _integrityService.verifyChain(widget.caseId);
    if (mounted) {
      setState(() {
        _records = records;
        _verification = verification;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zaman Çizelgesi & Deliller'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (_verification != null) _buildIntegrityBadge(),
                Expanded(
                  child: _records.isEmpty
                      ? const Center(
                          child: Text(
                            'Bu dosyada henüz bir kayıt yok.\nFormlar veya Kayıt Ekle sekmesinden ekleyebilirsiniz.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _records.length,
                          itemBuilder: (context, index) {
                            final rec = _records[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Icon(_getIconForType(rec.type)),
                                title: Text(rec.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(
                                  'Tarih: ${rec.recordedAt.toLocal().toString().substring(0, 16)}\n'
                                  'Hash: ${rec.chainHash.substring(0, 16)}...',
                                ),
                                isThreeLine: true,
                                trailing: rec.clockAnomaly
                                    ? const Tooltip(
                                        message: 'Saat geriye alınmış (Saat anomalisi)',
                                        child: Icon(Icons.warning_amber, color: Colors.orange),
                                      )
                                    : const Icon(Icons.verified_outlined, color: Colors.green),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => RecordDetailView(record: rec),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildIntegrityBadge() {
    final isValid = _verification!.isValid;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      color: isValid ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
      child: Row(
        children: [
          Icon(
            isValid ? Icons.verified : Icons.error_outline,
            color: isValid ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              isValid
                  ? 'Kayıt Zinciri Sağlam (${_records.length} kayıt doğrulandı)'
                  : 'DİKKAT: Zincir Kırık! ${_verification!.failureReason ?? ""}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isValid ? Colors.green.shade800 : Colors.red.shade800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'form':
        return Icons.description;
      case 'photo':
        return Icons.photo;
      case 'document':
        return Icons.picture_as_pdf;
      case 'chat_proof':
        return Icons.chat;
      default:
        return Icons.attachment;
    }
  }
}
