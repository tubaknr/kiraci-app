import 'package:flutter/material.dart';
import '../../../core/services/record_service.dart';
import '../controller/f1_lease_controller.dart';
import 'f1_lease_view.dart';

/// Mock Form Listesi Menüsü (Sümeyye T18'de güncelleyecek)
class FormsMenuView extends StatelessWidget {
  final String currentCaseId;

  const FormsMenuView({super.key, required this.currentCaseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yapılandırılmış Formlar')),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          _buildFormCard(
            context,
            code: 'F1',
            title: 'Sözleşme Bilgi Formu',
            subtitle: 'Kira şartlarını, bedeli ve depozitoyu sabitlemek için',
            icon: Icons.assignment_outlined,
            onTap: () {
              final controller = F1LeaseController(RecordService());
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => F1LeaseView(
                    caseId: currentCaseId,
                    controller: controller,
                    onSuccess: () {
                      controller.dispose();
                      Navigator.of(context).pop();
                    },
                  ),
                ),
              );
            },
          ),
          _buildFormCard(
            context,
            code: 'F2',
            title: 'Teslim / Tahliye Tespit Formu',
            subtitle: 'Oda durumu, sayaç değerleri ve anahtar sayısı (Tuba T15)',
            icon: Icons.key_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('F2 Formu T15 görevinde tamamlanacaktır.')),
              );
            },
          ),
          _buildFormCard(
            context,
            code: 'F3',
            title: 'Arıza / Sorun Bildirim Formu',
            subtitle: 'Evdeki tadilat/arıza bildirimleri (Sümeyye T18)',
            icon: Icons.build_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('F3 Formu Sümeyye tarafından T18\'de tasarlanacaktır.')),
              );
            },
          ),
          _buildFormCard(
            context,
            code: 'F4',
            title: 'Ödeme Bildirim Formu',
            subtitle: 'Kira ve depozito ödeme dekontları (Sümeyye T18)',
            icon: Icons.payment_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('F4 Formu Sümeyye tarafından T18\'de tasarlanacaktır.')),
              );
            },
          ),
          _buildFormCard(
            context,
            code: 'F5',
            title: 'Olay Notu Formu',
            subtitle: 'Serbest olay ve konuşma kayıtları (Sümeyye T21)',
            icon: Icons.note_alt_outlined,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('F5 Formu Sümeyye tarafından T21\'de tasarlanacaktır.')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard(
    BuildContext context, {
    required String code,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          child: Text(code, style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}
