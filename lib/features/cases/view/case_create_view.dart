import 'package:flutter/material.dart';
import '../../../core/constants/view_status.dart';
import '../controller/case_create_controller.dart';

/// Mock Dosya Oluştur Ekranı (Sümeyye T07'de güncelleyecek)
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
  final _titleController = TextEditingController();
  final _addressController = TextEditingController();
  final _otherPartyController = TextEditingController();
  String _selectedRole = 'tenant';
  final DateTime _leaseStart = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _otherPartyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final success = await widget.controller.createCase(
      title: _titleController.text,
      address: _addressController.text,
      myRole: _selectedRole,
      otherPartyName: _otherPartyController.text,
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
      appBar: AppBar(title: const Text('Yeni Dosya Oluştur')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Dosya Başlığı (örn. Kadıköy Daire Kira)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Taşınmaz Adresi',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedRole,
              decoration: const InputDecoration(
                labelText: 'Rolüm',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'tenant', child: Text('Kiracıyım')),
                DropdownMenuItem(value: 'landlord', child: Text('Ev Sahibiyim')),
              ],
              onChanged: (val) {
                if (val != null) setState(() => _selectedRole = val);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _otherPartyController,
              decoration: const InputDecoration(
                labelText: 'Karşı Taraf Adı Soyadı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<String?>(
              valueListenable: widget.controller.errorMessage,
              builder: (context, error, _) {
                if (error == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(error, style: const TextStyle(color: Colors.red)),
                );
              },
            ),
            ValueListenableBuilder<ViewStatus>(
              valueListenable: widget.controller.status,
              builder: (context, status, _) {
                if (status == ViewStatus.loading) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text('Dosyayı Kaydet'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
