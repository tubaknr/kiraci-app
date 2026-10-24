import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/view_status.dart';
import '../controller/case_create_controller.dart';

/// Dosya Oluştur Ekranı (Sümeyye - T07)
class CaseCreateView extends StatefulWidget {
  final CaseCreateController controller;
  final VoidCallback? onSuccess;

  const CaseCreateView({
    super.key,
    required this.controller,
    this.onSuccess,
  });

  @override
  State<CaseCreateView> createState() => _CaseCreateViewState();
}

class _CaseCreateViewState extends State<CaseCreateView> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _otherPartyController = TextEditingController();
  String _selectedRole = 'tenant';
  DateTime _leaseStart = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _otherPartyController.dispose();
    super.dispose();
  }

  Future<void> _pickLeaseDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _leaseStart,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _leaseStart = picked);
    }
  }

  Future<void> _submit() async {
    final bool success = await widget.controller.createCase(
      title: _titleController.text.trim(),
      address: _addressController.text.trim(),
      myRole: _selectedRole,
      otherPartyName: _otherPartyController.text.trim(),
      leaseStart: _leaseStart,
    );

    if (success && mounted) {
      Navigator.of(context).pop();
      widget.onSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Kira Dosyası Aç'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildRoleSelector(),
            const SizedBox(height: 16),
            _buildTextFields(),
            const SizedBox(height: 16),
            _buildDatePickerTile(),
            const SizedBox(height: 16),
            _buildErrorMessage(),
            const SizedBox(height: 8),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSelector() {
    return SegmentedButton<String>(
      segments: const [
        ButtonSegment<String>(
          value: 'tenant',
          label: Text('Kiracıyım'),
          icon: Icon(Icons.person_outline),
        ),
        ButtonSegment<String>(
          value: 'landlord',
          label: Text('Ev Sahibiyim'),
          icon: Icon(Icons.home_work_outlined),
        ),
      ],
      selected: {_selectedRole},
      onSelectionChanged: (Set<String> newSelection) {
        setState(() => _selectedRole = newSelection.first);
      },
    );
  }

  Widget _buildTextFields() {
    return Column(
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Dosya Başlığı *',
            hintText: 'Örn: Kadıköy Moda Daire Kirası',
            prefixIcon: Icon(Icons.bookmark_border),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _addressController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Taşınmaz Adresi *',
            hintText: 'İl, ilçe, mahalle, sokak, no, daire...',
            prefixIcon: Icon(Icons.location_on_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _otherPartyController,
          decoration: const InputDecoration(
            labelText: 'Karşı Taraf Adı Soyadı *',
            hintText: 'Ev sahibi ya da kiracının adı',
            prefixIcon: Icon(Icons.badge_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerTile() {
    final String dateFormatted = _leaseStart.toIso8601String().substring(0, 10);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.calendar_today_outlined, color: AppColors.primary),
        title: const Text('Kira Başlangıç Tarihi'),
        subtitle: Text(dateFormatted),
        trailing: OutlinedButton(
          onPressed: _pickLeaseDate,
          child: const Text('Tarih Seç'),
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return ValueListenableBuilder<String?>(
      valueListenable: widget.controller.errorMessage,
      builder: (BuildContext context, String? error, _) {
        if (error == null || error.isEmpty) return const SizedBox.shrink();
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.error),
          ),
          child: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
            ],
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
        return ElevatedButton(
          onPressed: isLoading ? null : _submit,
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Dosyayı Kaydet ve Başla'),
        );
      },
    );
  }
}
