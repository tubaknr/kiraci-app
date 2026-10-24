import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/view_status.dart';
import '../controller/f3_defect_controller.dart';
import '../models/f3_defect_data.dart';

/// F3 Arıza / Sorun Bildirim Formu Ekranı (Sümeyye - T18)
class F3DefectView extends StatefulWidget {
  final String caseId;
  final F3DefectController controller;
  final VoidCallback? onSuccess;

  const F3DefectView({
    super.key,
    required this.caseId,
    required this.controller,
    this.onSuccess,
  });

  @override
  State<F3DefectView> createState() => _F3DefectViewState();
}

class _F3DefectViewState extends State<F3DefectView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  String _defectType = 'su_tesisati';
  String _urgency = 'medium';
  DateTime _reportedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final double? cost = double.tryParse(_costController.text.trim());

    final F3DefectData data = F3DefectData(
      defectType: _defectType,
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
      urgency: _urgency,
      reportedDate: _reportedDate,
      estimatedCost: cost,
    );

    final bool success = await widget.controller.submit(
      caseId: widget.caseId,
      data: data,
    );

    if (success && mounted) {
      widget.onSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('F3 Arıza / Sorun Bildirimi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDefectTypeSelector(),
            const SizedBox(height: 16),
            _buildTextFields(),
            const SizedBox(height: 16),
            _buildUrgencySelector(),
            const SizedBox(height: 16),
            _buildCostAndDateTile(),
            const SizedBox(height: 16),
            _buildFieldErrors(),
            const SizedBox(height: 12),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildDefectTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Arıza Kategorisi *',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _defectType,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.build_circle_outlined),
          ),
          items: const [
            DropdownMenuItem(value: 'su_tesisati', child: Text('Su Tesisatı & Gider')),
            DropdownMenuItem(value: 'elektrik', child: Text('Elektrik & Aydınlatma')),
            DropdownMenuItem(value: 'kombi_isitma', child: Text('Kombi / Isıtma Sistemi')),
            DropdownMenuItem(value: 'rutubet', child: Text('Nem, Küf ve Rutubet')),
            DropdownMenuItem(value: 'diger', child: Text('Diğer Yapısal Sorunlar')),
          ],
          onChanged: (String? val) {
            if (val != null) setState(() => _defectType = val);
          },
        ),
      ],
    );
  }

  Widget _buildTextFields() {
    return Column(
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Arıza Başlığı *',
            hintText: 'Örn: Banyo Tavanından Alt Kata Su Sızıntısı',
            prefixIcon: Icon(Icons.title),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _descController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Sorunun Detaylı Açıklaması *',
            hintText: 'Arıza ne zaman başladı, ev sahibine nasıl bildirildi, mevcut durum nedir?',
            prefixIcon: Icon(Icons.description_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildUrgencySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aciliyet Durumu',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'low', label: Text('Düşük')),
            ButtonSegment(value: 'medium', label: Text('Orta')),
            ButtonSegment(value: 'high', label: Text('Yüksek')),
            ButtonSegment(value: 'critical', label: Text('Kritik')),
          ],
          selected: {_urgency},
          onSelectionChanged: (Set<String> s) => setState(() => _urgency = s.first),
        ),
      ],
    );
  }

  Widget _buildCostAndDateTile() {
    final String dateStr = _reportedDate.toIso8601String().substring(0, 10);

    return Column(
      children: [
        TextField(
          controller: _costController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Tahmini / Harcanan Tutar (TL, Opsiyonel)',
            prefixIcon: Icon(Icons.payments_outlined),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: ListTile(
            leading: const Icon(Icons.calendar_today, color: AppColors.primary),
            title: const Text('Tespit / Bildirim Tarihi'),
            subtitle: Text(dateStr),
            trailing: OutlinedButton(
              onPressed: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _reportedDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) setState(() => _reportedDate = picked);
              },
              child: const Text('Değiştir'),
            ),
          ),
        ),
      ],
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
              : const Icon(Icons.save_outlined),
          label: Text(isLoading ? 'Kaydediliyor...' : 'Arıza Bildirimini Mühürle (F3)'),
        );
      },
    );
  }
}
