import 'package:flutter/foundation.dart';

@immutable
class F3DefectData {
  final String defectType; // 'su_tesisati', 'elektrik', 'kombi_isitma', 'rutubet', 'diger'
  final String title;
  final String description;
  final String urgency; // 'low', 'medium', 'high', 'critical'
  final DateTime reportedDate;
  final double? estimatedCost;
  final List<String> photoPaths;

  const F3DefectData({
    required this.defectType,
    required this.title,
    required this.description,
    this.urgency = 'medium',
    required this.reportedDate,
    this.estimatedCost,
    this.photoPaths = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'defect_type': defectType,
      'title': title,
      'description': description,
      'urgency': urgency,
      'reported_date': reportedDate.toUtc().toIso8601String(),
      'estimated_cost': estimatedCost,
      'photo_paths': photoPaths,
    };
  }

  factory F3DefectData.fromMap(Map<String, dynamic> map) {
    return F3DefectData(
      defectType: map['defect_type'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      urgency: map['urgency'] as String? ?? 'medium',
      reportedDate: DateTime.parse(map['reported_date'] as String).toUtc(),
      estimatedCost: (map['estimated_cost'] as num?)?.toDouble(),
      photoPaths: (map['photo_paths'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  F3DefectData copyWith({
    String? defectType,
    String? title,
    String? description,
    String? urgency,
    DateTime? reportedDate,
    double? estimatedCost,
    List<String>? photoPaths,
  }) {
    return F3DefectData(
      defectType: defectType ?? this.defectType,
      title: title ?? this.title,
      description: description ?? this.description,
      urgency: urgency ?? this.urgency,
      reportedDate: reportedDate ?? this.reportedDate,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      photoPaths: photoPaths ?? this.photoPaths,
    );
  }

  static Map<String, String> validate(F3DefectData data) {
    final errors = <String, String>{};

    if (data.title.trim().isEmpty) {
      errors['title'] = 'Arıza başlığı boş bırakılamaz.';
    }
    if (data.description.trim().isEmpty) {
      errors['description'] = 'Sorun açıklaması boş bırakılamaz.';
    }
    if (data.defectType.trim().isEmpty) {
      errors['defect_type'] = 'Arıza türü seçilmelidir.';
    }
    if (data.estimatedCost != null && data.estimatedCost! < 0) {
      errors['estimated_cost'] = 'Tahmini masraf negatif olamaz.';
    }

    return errors;
  }
}
