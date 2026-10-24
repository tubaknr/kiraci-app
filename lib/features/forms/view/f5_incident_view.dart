import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/view_status.dart';
import '../../../core/services/notification_service.dart';
import '../controller/f5_incident_controller.dart';
import '../models/f5_incident_data.dart';

/// F5 Olay ve Durum Notu Formu Ekranı (Sümeyye - T21)
class F5IncidentView extends StatefulWidget {
  final String caseId;
  final F5IncidentController controller;
  final VoidCallback? onSuccess;

  const F5IncidentView({
    super.key,
    required this.caseId,
    required this.controller,
    this.onSuccess,
  });

  @override
  State<F5IncidentView> createState() => _F5IncidentViewState();
}

class _F5IncidentViewState extends State<F5IncidentView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _partiesController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();
  final NotificationService _notificationService = NotificationService();

  DateTime _incidentDate = DateTime.now();
  bool _setReminder = false;

  @override
  void dispose() {
    _titleController.dispose();
    _partiesController.dispose();
    _locationController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final F5IncidentData data = F5IncidentData(
      incidentTitle: _titleController.text.trim(),
      incidentDate: _incidentDate,
      partiesInvolved: _partiesController.text.trim(),
      location: _locationController.text.trim().isEmpty
          ? null
          : _locationController.text.trim(),
      summary: _summaryController.text.trim(),
    );

    final bool success = await widget.controller.submit(
      caseId: widget.caseId,
      data: data,
    );

    if (success && mounted) {
      if (_setReminder) {
        await _notificationService.showNotification(
          id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
          title: 'SafeRentHouse Hatırlatıcı',
          body: 'Olay kaydı eklendi: ${_titleController.text.trim()}',
        );
      }
      widget.onSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('F5 Olay ve Durum Notu'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildInfoCard(),
            const SizedBox(height: 16),
            _buildTextFields(),
            const SizedBox(height: 16),
            _buildDateTile(),
            const SizedBox(height: 16),
            _buildReminderTile(),
            const SizedBox(height: 16),
            _buildFieldErrors(),
            const SizedBox(height: 12),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.notes, color: AppColors.primary),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Sözlü vaatler, apartman içi görüşmeler, çilingir çağrılması veya ihtar gibi serbest olayları kronolojik delil olarak kaydeder.',
              style: TextStyle(fontSize: 12, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextFields() {
    return Column(
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Olay Başlığı *',
            hintText: 'Örn: Ev Sahibi ile Sözlü Kira Artışı Görüşmesi',
            prefixIcon: Icon(Icons.bookmark_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _partiesController,
          decoration: const InputDecoration(
            labelText: 'Görüşülen / Katılan Kişiler *',
            hintText: 'Örn: Ev Sahibi Ahmet Bey ve Emlakçı Mehmet',
            prefixIcon: Icon(Icons.people_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _locationController,
          decoration: const InputDecoration(
            labelText: 'Görüşme Kanalı / Yeri (Opsiyonel)',
            hintText: 'Örn: Telefon Görüşmesi, Daire Kapısı',
            prefixIcon: Icon(Icons.place_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _summaryController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Olay Özeti ve Konuşulan Maddeler *',
            hintText: 'Tarih, saat ve konuşulanların tam dökümü...',
            prefixIcon: Icon(Icons.description_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTile() {
    final String dateStr = _incidentDate.toIso8601String().substring(0, 10);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today, color: AppColors.primary),
        title: const Text('Olayın Gerçekleştiği Tarih'),
        subtitle: Text(dateStr),
        trailing: OutlinedButton(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _incidentDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) setState(() => _incidentDate = picked);
          },
          child: const Text('Değiştir'),
        ),
      ),
    );
  }

  Widget _buildReminderTile() {
    return Card(
      child: SwitchListTile(
        title: const Text('Takip Hatırlatıcısı Kur'),
        subtitle: const Text('Bu olay kaydı sonrası cihazda yerel bildirim tetikle'),
        value: _setReminder,
        onChanged: (bool val) => setState(() => _setReminder = val),
      ),
    );
  }

  Widget _buildFieldErrors() {
    return ValueListenableBuilder<Map<String, String>>(
      valueListenable: widget.controller.fieldErrors,
      builder: (BuildContext context, Map<String, String> errors, _) {
        if (errors.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.error),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: errors.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        e.value,
                        style: const TextStyle(color: AppColors.error, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return ValueListenableBuilder<ViewStatus>(
      valueListenable: widget.controller.status,
      builder: (BuildContext context, ViewStatus status, _) {
        final bool isLoading = status == ViewStatus.loading;
        return ElevatedButton.icon(
          onPressed: isLoading ? null : _submit,
          icon: isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Icon(Icons.shield_outlined),
          label: Text(isLoading ? 'Kaydediliyor...' : 'Olay Notunu Mühürle (F5)'),
        );
      },
    );
  }
}
