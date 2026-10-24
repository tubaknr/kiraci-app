import 'package:flutter/material.dart';
import '../../records/models/record_model.dart';

/// Mock Kayıt Detayı Ekranı (Sümeyye T12'de güncelleyecek)
class RecordDetailView extends StatelessWidget {
  final RecordModel record;

  const RecordDetailView({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıt Detayı')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(record.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Tür: ${record.type}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            const Divider(),
            _buildDetailRow('Kayıt Zamanı (UTC)', record.recordedAt.toIso8601String()),
            _buildDetailRow('Saat Anomalisi', record.clockAnomaly ? 'VAR (Saat geriye alınmış)' : 'YOK (Normal)'),
            _buildDetailRow('İçerik SHA-256 (content_hash)', record.contentHash),
            _buildDetailRow('Önceki Zincir (prev_chain_hash)', record.prevChainHash),
            _buildDetailRow('Mevcut Zincir (chain_hash)', record.chainHash),
            if (record.filePath != null) _buildDetailRow('Göreli Dosya Yolu', record.filePath!),
            if (record.note != null && record.note!.isNotEmpty) _buildDetailRow('Açıklama / Not', record.note!),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey)),
          const SizedBox(height: 4),
          SelectableText(value, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}
