import 'package:flutter/material.dart';
import '../../../core/constants/view_status.dart';
import '../controller/f2_handover_controller.dart';
import '../models/f2_handover_data.dart';
import '../widget/f2_handover_fields.dart';

class F2HandoverView extends StatefulWidget {
  final String caseId;
  final F2HandoverController controller;
  final VoidCallback? onSuccess;

  const F2HandoverView({
    super.key,
    required this.caseId,
    required this.controller,
    this.onSuccess,
  });

  @override
  State<F2HandoverView> createState() => _F2HandoverViewState();
}

class _F2HandoverViewState extends State<F2HandoverView> {
  String _handoverType = 'entry'; // 'entry' veya 'exit'
  final _inspectorController = TextEditingController();
  final _electricityController = TextEditingController();
  final _waterController = TextEditingController();
  final _gasController = TextEditingController();
  final _keyCountController = TextEditingController(text: '1');
  final _notesController = TextEditingController();

  final List<RoomCondition> _rooms = [
    const RoomCondition(roomName: 'Salon', conditionNote: 'Temiz, hasarsız'),
  ];

  @override
  void dispose() {
    _inspectorController.dispose();
    _electricityController.dispose();
    _waterController.dispose();
    _gasController.dispose();
    _keyCountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addRoomDialog() {
    final nameCtrl = TextEditingController();
    final noteCtrl = TextEditingController(text: 'İyi durumda');
    bool hasDamage = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDlgState) => AlertDialog(
          title: const Text('Oda / Alan Durumu Ekle'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Oda/Bölüm Adı (örn. Mutfak)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: noteCtrl,
                decoration: const InputDecoration(labelText: 'Durum Notu'),
              ),
              CheckboxListTile(
                title: const Text('Hasar / Kusur Var'),
                value: hasDamage,
                onChanged: (val) => setDlgState(() => hasDamage = val ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty) {
                  setState(() {
                    _rooms.add(RoomCondition(
                      roomName: nameCtrl.text.trim(),
                      conditionNote: noteCtrl.text.trim(),
                      hasDamage: hasDamage,
                    ));
                  });
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final data = F2HandoverData(
      handoverType: _handoverType,
      handoverDate: DateTime.now(),
      inspectorName: _inspectorController.text,
      electricityMeter: _electricityController.text,
      waterMeter: _waterController.text,
      gasMeter: _gasController.text,
      keyCount: int.tryParse(_keyCountController.text) ?? 1,
      rooms: List.unmodifiable(_rooms),
      generalNotes: _notesController.text.trim().isEmpty ? null : _notesController.text,
    );

    final success = await widget.controller.submit(
      caseId: widget.caseId,
      data: data,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('F2 Tespit Tutanağı doğrulandı ve zincire eklendi.')),
      );
      widget.onSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('F2 Teslim / Tahliye Formu'),
      ),
      body: ValueListenableBuilder<ViewStatus>(
        valueListenable: widget.controller.status,
        builder: (context, status, _) {
          return Stack(
            children: [
              _buildFormContent(),
              if (status == ViewStatus.loading)
                const ColoredBox(
                  color: Colors.black26,
                  child: Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFormContent() {
    return ValueListenableBuilder<Map<String, String>>(
      valueListenable: widget.controller.fieldErrors,
      builder: (context, errors, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildTypeSelector(),
              const SizedBox(height: 12),
              _buildInspectorField(errors),
              const SizedBox(height: 16),
              const Text('Sayaç Endeksleri', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              MeterInputField(
                controller: _electricityController,
                label: 'Elektrik Sayacı (kWh) *',
                icon: Icons.electric_bolt,
                errorText: errors['electricity_meter'],
              ),
              MeterInputField(
                controller: _waterController,
                label: 'Su Sayacı (m³) *',
                icon: Icons.water_drop,
                errorText: errors['water_meter'],
              ),
              MeterInputField(
                controller: _gasController,
                label: 'Doğalgaz Sayacı (m³) *',
                icon: Icons.local_fire_department,
                errorText: errors['gas_meter'],
              ),
              const SizedBox(height: 12),
              _buildKeyCountField(errors),
              const SizedBox(height: 16),
              _buildRoomsHeader(errors),
              const SizedBox(height: 8),
              _buildRoomsList(),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Genel Notlar / Demirbaş Durumu',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.lock_clock),
                label: const Text('Tutanağı Doğrula ve Kayda Geçir'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTypeSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment(value: 'entry', label: Text('Teslim Alma (Giriş)')),
        ButtonSegment(value: 'exit', label: Text('Tahliye (Çıkış)')),
      ],
      selected: {_handoverType},
      onSelectionChanged: (val) => setState(() => _handoverType = val.first),
    );
  }

  Widget _buildInspectorField(Map<String, String> errors) {
    return TextField(
      controller: _inspectorController,
      decoration: InputDecoration(
        labelText: 'Tespiti Yapan / Teslim Eden *',
        errorText: errors['inspector_name'],
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildKeyCountField(Map<String, String> errors) {
    return TextField(
      controller: _keyCountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Teslim Edilen Anahtar Sayısı *',
        errorText: errors['key_count'],
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildRoomsHeader(Map<String, String> errors) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Oda & Demirbaş Durumları *', style: TextStyle(fontWeight: FontWeight.bold)),
            if (errors['rooms'] != null)
              Text(errors['rooms']!, style: const TextStyle(color: Colors.red, fontSize: 12)),
          ],
        ),
        TextButton.icon(
          onPressed: _addRoomDialog,
          icon: const Icon(Icons.add),
          label: const Text('Oda Ekle'),
        ),
      ],
    );
  }

  Widget _buildRoomsList() {
    return Column(
      children: _rooms.asMap().entries.map((entry) {
        return RoomConditionTile(
          room: entry.value,
          onRemove: () => setState(() => _rooms.removeAt(entry.key)),
        );
      }).toList(),
    );
  }
}
