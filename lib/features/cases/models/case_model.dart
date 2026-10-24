import 'package:flutter/foundation.dart';

@immutable
class CaseModel {
  final String id;
  final String title;
  final String address;
  final String myRole; // 'tenant' (kiracı) veya 'landlord' (ev sahibi)
  final String otherPartyName;
  final DateTime leaseStart;
  final DateTime? leaseEnd;
  final DateTime createdAt;

  const CaseModel({
    required this.id,
    required this.title,
    required this.address,
    required this.myRole,
    required this.otherPartyName,
    required this.leaseStart,
    this.leaseEnd,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'address': address,
      'my_role': myRole,
      'other_party_name': otherPartyName,
      'lease_start': leaseStart.toIso8601String(),
      'lease_end': leaseEnd?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory CaseModel.fromMap(Map<String, dynamic> map) {
    return CaseModel(
      id: map['id'] as String,
      title: map['title'] as String,
      address: map['address'] as String,
      myRole: map['my_role'] as String,
      otherPartyName: map['other_party_name'] as String,
      leaseStart: DateTime.parse(map['lease_start'] as String),
      leaseEnd: map['lease_end'] != null ? DateTime.parse(map['lease_end'] as String) : null,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  CaseModel copyWith({
    String? id,
    String? title,
    String? address,
    String? myRole,
    String? otherPartyName,
    DateTime? leaseStart,
    DateTime? leaseEnd,
    DateTime? createdAt,
  }) {
    return CaseModel(
      id: id ?? this.id,
      title: title ?? this.title,
      address: address ?? this.address,
      myRole: myRole ?? this.myRole,
      otherPartyName: otherPartyName ?? this.otherPartyName,
      leaseStart: leaseStart ?? this.leaseStart,
      leaseEnd: leaseEnd ?? this.leaseEnd,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CaseModel &&
        other.id == id &&
        other.title == title &&
        other.address == address &&
        other.myRole == myRole &&
        other.otherPartyName == otherPartyName &&
        other.leaseStart == leaseStart &&
        other.leaseEnd == leaseEnd &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      address,
      myRole,
      otherPartyName,
      leaseStart,
      leaseEnd,
      createdAt,
    );
  }
}
