import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/view_status.dart';
import '../controller/f4_payment_controller.dart';
import '../models/f4_payment_data.dart';

/// F4 Kira & Ödeme Bildirim Formu Ekranı (Sümeyye - T18)
class F4PaymentView extends StatefulWidget {
  final String caseId;
  final F4PaymentController controller;
  final VoidCallback? onSuccess;

  const F4PaymentView({
    super.key,
    required this.caseId,
    required this.controller,
    this.onSuccess,
  });

  @override
  State<F4PaymentView> createState() => _F4PaymentViewState();
}

class _F4PaymentViewState extends State<F4PaymentView> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _periodController = TextEditingController();
  final TextEditingController _payerController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _receiptNoController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _paymentType = 'rent';
  String _paymentMethod = 'bank_transfer';
  DateTime _paidAt = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _periodController.dispose();
    _payerController.dispose();
    _receiverController.dispose();
    _receiptNoController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final double amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    final F4PaymentData data = F4PaymentData(
      paymentType: _paymentType,
      amount: amount,
      currency: 'TRY',
      period: _periodController.text.trim(),
      paymentMethod: _paymentMethod,
      paidAt: _paidAt,
      payerName: _payerController.text.trim(),
      receiverName: _receiverController.text.trim(),
      receiptNumber: _receiptNoController.text.trim().isEmpty
          ? null
          : _receiptNoController.text.trim(),
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
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
        title: const Text('F4 Kira & Ödeme Kaydı'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildPaymentTypeSelector(),
            const SizedBox(height: 16),
            _buildAmountAndPeriodRow(),
            const SizedBox(height: 16),
            _buildMethodSelector(),
            const SizedBox(height: 16),
            _buildPartiesFields(),
            const SizedBox(height: 16),
            _buildReceiptAndNotes(),
            const SizedBox(height: 16),
            _buildDateTile(),
            const SizedBox(height: 16),
            _buildFieldErrors(),
            const SizedBox(height: 12),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentTypeSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ödeme Türü *',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _paymentType,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.category_outlined),
          ),
          items: const [
            DropdownMenuItem(value: 'rent', child: Text('Kira Bedeli Ödemesi')),
            DropdownMenuItem(value: 'deposit', child: Text('Güvence / Depozito Bedeli')),
            DropdownMenuItem(value: 'dues', child: Text('Bina / Site Aidatı')),
            DropdownMenuItem(value: 'other', child: Text('Diğer Masraf & Ödeme')),
          ],
          onChanged: (String? val) {
            if (val != null) setState(() => _paymentType = val);
          },
        ),
      ],
    );
  }

  Widget _buildAmountAndPeriodRow() {
    return Row(
      children: [
        Expanded(
          flex: 3,
          child: TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Tutar (TL) *',
              hintText: 'Örn: 18500',
              prefixIcon: Icon(Icons.currency_lira),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: TextField(
            controller: _periodController,
            decoration: const InputDecoration(
              labelText: 'Dönem *',
              hintText: 'Örn: Kasım 2026',
              prefixIcon: Icon(Icons.date_range),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMethodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ödeme Kanalı',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
        ),
        const SizedBox(height: 8),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'bank_transfer', label: Text('Banka/EFT')),
            ButtonSegment(value: 'cash', label: Text('Elden/Nakit')),
            ButtonSegment(value: 'other', label: Text('Diğer')),
          ],
          selected: {_paymentMethod},
          onSelectionChanged: (Set<String> s) => setState(() => _paymentMethod = s.first),
        ),
      ],
    );
  }

  Widget _buildPartiesFields() {
    return Column(
      children: [
        TextField(
          controller: _payerController,
          decoration: const InputDecoration(
            labelText: 'Ödeyen (Kiracı) Adı Soyadı *',
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _receiverController,
          decoration: const InputDecoration(
            labelText: 'Alıcı (Ev Sahibi / Temsilci) Adı Soyadı *',
            prefixIcon: Icon(Icons.person_pin_outlined),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptAndNotes() {
    return Column(
      children: [
        TextField(
          controller: _receiptNoController,
          decoration: const InputDecoration(
            labelText: 'Dekont / Fiş No (Opsiyonel)',
            hintText: 'Örn: TR12000... veya Dekont Ref No',
            prefixIcon: Icon(Icons.receipt_outlined),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _notesController,
          maxLines: 2,
          decoration: const InputDecoration(
            labelText: 'Açıklama / Havale Notu (Opsiyonel)',
            hintText: 'Banka dekontu açıklamasına yazılan metin...',
            prefixIcon: Icon(Icons.notes),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTile() {
    final String dateStr = _paidAt.toIso8601String().substring(0, 10);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.event_available, color: AppColors.primary),
        title: const Text('Ödeme Tarihi'),
        subtitle: Text(dateStr),
        trailing: OutlinedButton(
          onPressed: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _paidAt,
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) setState(() => _paidAt = picked);
          },
          child: const Text('Değiştir'),
        ),
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
          label: Text(isLoading ? 'Kaydediliyor...' : 'Ödeme Kaydını Zincire Ekle (F4)'),
        );
      },
    );
  }
}
