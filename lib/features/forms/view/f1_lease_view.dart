import 'package:flutter/material.dart';
import '../../../core/constants/view_status.dart';
import '../controller/f1_lease_controller.dart';
import '../models/f1_lease_data.dart';
import '../widget/f1_lease_fields.dart';

class F1LeaseView extends StatefulWidget {
  final String caseId;
  final F1LeaseController controller;
  final VoidCallback? onSuccess;

  const F1LeaseView({
    super.key,
    required this.caseId,
    required this.controller,
    this.onSuccess,
  });

  @override
  State<F1LeaseView> createState() => _F1LeaseViewState();
}

class _F1LeaseViewState extends State<F1LeaseView> {
  final _tenantController = TextEditingController();
  final _landlordController = TextEditingController();
  final _addressController = TextEditingController();
  final _rentController = TextEditingController();
  final _depositController = TextEditingController();
  final _increaseNoteController = TextEditingController();
  final _specialTermsController = TextEditingController();

  DateTime _startDate = DateTime.now();
  DateTime? _endDate;

  @override
  void dispose() {
    _tenantController.dispose();
    _landlordController.dispose();
    _addressController.dispose();
    _rentController.dispose();
    _depositController.dispose();
    _increaseNoteController.dispose();
    _specialTermsController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 365)),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  Future<void> _handleSubmit() async {
    final data = F1LeaseData(
      tenantName: _tenantController.text,
      landlordName: _landlordController.text,
      address: _addressController.text,
      monthlyRent: double.tryParse(_rentController.text) ?? 0.0,
      depositAmount: double.tryParse(_depositController.text) ?? 0.0,
      startDate: _startDate,
      endDate: _endDate,
      increaseRateNote: _increaseNoteController.text.trim().isEmpty ? null : _increaseNoteController.text,
      specialTerms: _specialTermsController.text.trim().isEmpty ? null : _specialTermsController.text,
    );

    final success = await widget.controller.submit(
      caseId: widget.caseId,
      data: data,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sözleşme formu doğrulandı ve zincire eklendi.')),
      );
      widget.onSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('F1 Sözleşme Bilgi Formu'),
      ),
      body: ValueListenableBuilder<ViewStatus>(
        valueListenable: widget.controller.status,
        builder: (context, status, _) {
          return Stack(
            children: [
              _F1FormBody(
                tenantController: _tenantController,
                landlordController: _landlordController,
                addressController: _addressController,
                rentController: _rentController,
                depositController: _depositController,
                increaseNoteController: _increaseNoteController,
                specialTermsController: _specialTermsController,
                startDate: _startDate,
                endDate: _endDate,
                onPickStartDate: _pickStartDate,
                onPickEndDate: _pickEndDate,
                onSubmit: _handleSubmit,
                controller: widget.controller,
              ),
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
}

class _F1FormBody extends StatelessWidget {
  final TextEditingController tenantController;
  final TextEditingController landlordController;
  final TextEditingController addressController;
  final TextEditingController rentController;
  final TextEditingController depositController;
  final TextEditingController increaseNoteController;
  final TextEditingController specialTermsController;
  final DateTime startDate;
  final DateTime? endDate;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;
  final VoidCallback onSubmit;
  final F1LeaseController controller;

  const _F1FormBody({
    required this.tenantController,
    required this.landlordController,
    required this.addressController,
    required this.rentController,
    required this.depositController,
    required this.increaseNoteController,
    required this.specialTermsController,
    required this.startDate,
    required this.endDate,
    required this.onPickStartDate,
    required this.onPickEndDate,
    required this.onSubmit,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Map<String, String>>(
      valueListenable: controller.fieldErrors,
      builder: (context, errors, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInfoBanner(context),
              const SizedBox(height: 12),
              F1TextFormField(
                controller: tenantController,
                label: 'Kiracı Adı Soyadı *',
                errorText: errors['tenant_name'],
              ),
              F1TextFormField(
                controller: landlordController,
                label: 'Ev Sahibi Adı Soyadı *',
                errorText: errors['landlord_name'],
              ),
              F1TextFormField(
                controller: addressController,
                label: 'Kiralanan Taşınmaz Adresi *',
                errorText: errors['address'],
                maxLines: 2,
              ),
              F1TextFormField(
                controller: rentController,
                label: 'Aylık Kira Bedeli (TL) *',
                errorText: errors['monthly_rent'],
                keyboardType: TextInputType.number,
              ),
              F1TextFormField(
                controller: depositController,
                label: 'Depozito Bedeli (TL)',
                errorText: errors['deposit_amount'],
                keyboardType: TextInputType.number,
              ),
              F1DateFormField(
                label: 'Sözleşme Başlangıç Tarihi *',
                selectedDate: startDate,
                errorText: errors['start_date'],
                onTap: onPickStartDate,
              ),
              F1DateFormField(
                label: 'Sözleşme Bitiş Tarihi',
                selectedDate: endDate,
                errorText: errors['end_date'],
                onTap: onPickEndDate,
              ),
              F1TextFormField(
                controller: increaseNoteController,
                label: 'Kira Artış Oranı / Şartı (örn. TÜFE)',
              ),
              F1TextFormField(
                controller: specialTermsController,
                label: 'Özel Şartlar / Notlar',
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onSubmit,
                icon: const Icon(Icons.lock_clock),
                label: const Text('Doğrula ve Kayda Geçir'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Form kaydedildikten sonra değiştirilemez; kanonik JSON olarak hash zincirine eklenir.',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
