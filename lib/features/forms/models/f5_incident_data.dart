import 'package:flutter/foundation.dart';

@immutable
class F5IncidentData {
  final String incidentTitle;
  final DateTime incidentDate;
  final String partiesInvolved; // Olayda yer alan kişiler
  final String? location; // Olay yeri veya iletişim kanalı (örn. Telefon, Kapı önü)
  final String summary; // Olay özeti ve detayları
  final List<String> attachedFilePaths;

  const F5IncidentData({
    required this.incidentTitle,
    required this.incidentDate,
    required this.partiesInvolved,
    this.location,
    required this.summary,
    this.photoFilePaths = const [],
    this.attachedFilePaths = const [],
  });

  // Geriye dönük uyumluluk için alias
  final List<String> photoFilePaths;

  Map<String, dynamic> toMap() {
    return {
      'attached_file_paths': attachedFilePaths.isNotEmpty ? attachedFilePaths : photoFilePaths,
      'incident_date': incidentDate.toUtc().toIso8601String(),
      'incident_title': incidentTitle,
      'location': location,
      'parties_involved': partiesInvolved,
      'summary': summary,
    };
  }

  factory F5IncidentData.fromMap(Map<String, dynamic> map) {
    final files = (map['attached_file_paths'] as List<dynamic>? ?? [])
        .map((e) => e.toString())
        .toList();

    return F5IncidentData(
      incidentTitle: map['incident_title'] as String,
      incidentDate: DateTime.parse(map['incident_date'] as String).toUtc(),
      partiesInvolved: map['parties_involved'] as String,
      location: map['location'] as String?,
      summary: map['summary'] as String,
      attachedFilePaths: files,
      photoFilePaths: files,
    );
  }

  F5IncidentData copyWith({
    String? incidentTitle,
    DateTime? incidentDate,
    String? partiesInvolved,
    String? location,
    String? summary,
    List<String>? attachedFilePaths,
  }) {
    final updatedFiles = attachedFilePaths ?? this.attachedFilePaths;
    return F5IncidentData(
      incidentTitle: incidentTitle ?? this.incidentTitle,
      incidentDate: incidentDate ?? this.incidentDate,
      partiesInvolved: partiesInvolved ?? this.partiesInvolved,
      location: location ?? this.location,
      summary: summary ?? this.summary,
      attachedFilePaths: updatedFiles,
      photoFilePaths: updatedFiles,
    );
  }

  static Map<String, String> validate(F5IncidentData data) {
    final errors = <String, String>{};

    if (data.incidentTitle.trim().isEmpty) {
      errors['incident_title'] = 'Olay başlığı boş bırakılamaz.';
    }
    if (data.partiesInvolved.trim().isEmpty) {
      errors['parties_involved'] = 'Muhatap / katılan kişiler belirtilmelidir.';
    }
    if (data.summary.trim().isEmpty) {
      errors['summary'] = 'Olay özeti boş bırakılamaz.';
    }

    return errors;
  }
}
