import 'package:flutter/foundation.dart';

@immutable
class RoomCondition {
  final String roomName;
  final String conditionNote;
  final bool hasDamage;

  const RoomCondition({
    required this.roomName,
    required this.conditionNote,
    this.hasDamage = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'room_name': roomName,
      'condition_note': conditionNote,
      'has_damage': hasDamage,
    };
  }

  factory RoomCondition.fromMap(Map<String, dynamic> map) {
    return RoomCondition(
      roomName: map['room_name'] as String,
      conditionNote: map['condition_note'] as String,
      hasDamage: map['has_damage'] as bool? ?? false,
    );
  }

  RoomCondition copyWith({
    String? roomName,
    String? conditionNote,
    bool? hasDamage,
  }) {
    return RoomCondition(
      roomName: roomName ?? this.roomName,
      conditionNote: conditionNote ?? this.conditionNote,
      hasDamage: hasDamage ?? this.hasDamage,
    );
  }
}

@immutable
class F2HandoverData {
  final String handoverType; // 'entry' (Teslim Alma / Giriş) veya 'exit' (Tahliye / Çıkış)
  final DateTime handoverDate;
  final String inspectorName;
  final String electricityMeter;
  final String waterMeter;
  final String gasMeter;
  final int keyCount;
  final List<RoomCondition> rooms;
  final String? generalNotes;
  final List<String> photoFilePaths;

  const F2HandoverData({
    required this.handoverType,
    required this.handoverDate,
    required this.inspectorName,
    required this.electricityMeter,
    required this.waterMeter,
    required this.gasMeter,
    this.keyCount = 1,
    this.rooms = const [],
    this.generalNotes,
    this.photoFilePaths = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'handover_type': handoverType,
      'handover_date': handoverDate.toUtc().toIso8601String(),
      'inspector_name': inspectorName,
      'electricity_meter': electricityMeter,
      'water_meter': waterMeter,
      'gas_meter': gasMeter,
      'key_count': keyCount,
      'rooms': rooms.map((r) => r.toMap()).toList(),
      'general_notes': generalNotes,
      'photo_file_paths': photoFilePaths,
    };
  }

  factory F2HandoverData.fromMap(Map<String, dynamic> map) {
    return F2HandoverData(
      handoverType: map['handover_type'] as String,
      handoverDate: DateTime.parse(map['handover_date'] as String).toUtc(),
      inspectorName: map['inspector_name'] as String,
      electricityMeter: map['electricity_meter'] as String,
      waterMeter: map['water_meter'] as String,
      gasMeter: map['gas_meter'] as String,
      keyCount: map['key_count'] as int? ?? 1,
      rooms: (map['rooms'] as List<dynamic>? ?? [])
          .map((e) => RoomCondition.fromMap(e as Map<String, dynamic>))
          .toList(),
      generalNotes: map['general_notes'] as String?,
      photoFilePaths: (map['photo_file_paths'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  F2HandoverData copyWith({
    String? handoverType,
    DateTime? handoverDate,
    String? inspectorName,
    String? electricityMeter,
    String? waterMeter,
    String? gasMeter,
    int? keyCount,
    List<RoomCondition>? rooms,
    String? generalNotes,
    List<String>? photoFilePaths,
  }) {
    return F2HandoverData(
      handoverType: handoverType ?? this.handoverType,
      handoverDate: handoverDate ?? this.handoverDate,
      inspectorName: inspectorName ?? this.inspectorName,
      electricityMeter: electricityMeter ?? this.electricityMeter,
      waterMeter: waterMeter ?? this.waterMeter,
      gasMeter: gasMeter ?? this.gasMeter,
      keyCount: keyCount ?? this.keyCount,
      rooms: rooms ?? this.rooms,
      generalNotes: generalNotes ?? this.generalNotes,
      photoFilePaths: photoFilePaths ?? this.photoFilePaths,
    );
  }

  static Map<String, String> validate(F2HandoverData data) {
    final errors = <String, String>{};

    if (data.inspectorName.trim().isEmpty) {
      errors['inspector_name'] = 'Tespiti yapan kişi adı boş bırakılamaz.';
    }
    if (data.electricityMeter.trim().isEmpty) {
      errors['electricity_meter'] = 'Elektrik sayaç değeri girilmelidir.';
    }
    if (data.waterMeter.trim().isEmpty) {
      errors['water_meter'] = 'Su sayaç değeri girilmelidir.';
    }
    if (data.gasMeter.trim().isEmpty) {
      errors['gas_meter'] = 'Doğalgaz sayaç değeri girilmelidir.';
    }
    if (data.keyCount < 0) {
      errors['key_count'] = 'Anahtar sayısı negatif olamaz.';
    }
    if (data.rooms.isEmpty) {
      errors['rooms'] = 'En az bir oda / alan durumu eklenmelidir.';
    }

    return errors;
  }
}
