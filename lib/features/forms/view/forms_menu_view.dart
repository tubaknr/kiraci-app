import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/record_service.dart';
import '../controller/f1_lease_controller.dart';
import '../controller/f2_handover_controller.dart';
import '../controller/f3_defect_controller.dart';
import '../controller/f4_payment_controller.dart';
import '../controller/f5_incident_controller.dart';
import 'f1_lease_view.dart';
import 'f2_handover_view.dart';
import 'f3_defect_view.dart';
import 'f4_payment_view.dart';
import 'f5_incident_view.dart';

/// Yapılandırılmış Formlar Menüsü (Sümeyye - T18)
class FormsMenuView extends StatelessWidget {
  final String currentCaseId;

  const FormsMenuView({super.key, required this.currentCaseId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Yapılandırılmış Formlar')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildFormCard(
            context,
            code: 'F1',
            title: 'Sözleşme Bilgi Formu',
            subtitle: 'Kira başlangıcı, bedel, artış oranı ve depozito tespiti',
            icon: Icons.assignment_outlined,
            onTap: () {
              final controller = F1LeaseController(RecordService());
              Navigator.of(context).push(
                MaterialPageRoute<void>(
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
            subtitle: 'Anahtar teslimi, sayaç değerleri ve oda demirbaş durumları',
            icon: Icons.key_outlined,
            onTap: () {
              final controller = F2HandoverController(RecordService());
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => F2HandoverView(
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
            code: 'F3',
            title: 'Arıza / Sorun Bildirim Formu',
            subtitle: 'Evdeki tesisat, elektrik veya kombi arızalarının tespiti',
            icon: Icons.build_outlined,
            onTap: () {
              final controller = F3DefectController(RecordService());
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => F3DefectView(
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
            code: 'F4',
            title: 'Kira & Ödeme Bildirim Formu',
            subtitle: 'Kira bedeli, depozito veya aidat ödeme kayıtları ve dekontları',
            icon: Icons.payment_outlined,
            onTap: () {
              final controller = F4PaymentController(RecordService());
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => F4PaymentView(
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
            code: 'F5',
            title: 'Olay ve Durum Notu Formu',
            subtitle: 'Kira ilişkisindeki serbest olaylar, sözlü görüşmeler ve ihtar kayıtları',
            icon: Icons.note_alt_outlined,
            onTap: () {
              final controller = F5IncidentController(RecordService());
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (context) => F5IncidentView(
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
    final Color primaryColor = AppColors.primaryCol(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: primaryColor.withValues(alpha: 0.15),
          child: Text(
            code,
            style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textMain(context)),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: AppColors.textMuted(context)),
        ),
        trailing: Icon(Icons.chevron_right, color: primaryColor),
        onTap: onTap,
      ),
    );
  }
}
