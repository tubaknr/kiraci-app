import 'package:flutter/foundation.dart';

@immutable
class F1LeaseData {
  final String tenantName;
  final String landlordName;
  final String address;
  final double monthlyRent;
  final double depositAmount;
  final String currency;
  final DateTime startDate;
  final DateTime? endDate;
  final String? increaseRateNote;
  final String? specialTerms;

  const F1LeaseData({
    required this.tenantName,
    required this.landlordName,
    required this.address,
    required this.monthlyRent,
    this.depositAmount = 0.0,
    this.currency = 'TRY',
    required this.startDate,
    this.endDate,
    this.increaseRateNote,
    this.specialTerms,
  });

  Map<String, dynamic> toMap() {
    return {
      'tenant_name': tenantName,
      'landlord_name': landlordName,
      'address': address,
      'monthly_rent': monthlyRent,
      'deposit_amount': depositAmount,
      'currency': currency,
      'start_date': startDate.toUtc().toIso8601String(),
      'end_date': endDate?.toUtc().toIso8601String(),
      'increase_rate_note': increaseRateNote,
      'special_terms': specialTerms,
    };
  }

  factory F1LeaseData.fromMap(Map<String, dynamic> map) {
    return F1LeaseData(
      tenantName: map['tenant_name'] as String,
      landlordName: map['landlord_name'] as String,
      address: map['address'] as String,
      monthlyRent: (map['monthly_rent'] as num).toDouble(),
      depositAmount: (map['deposit_amount'] as num? ?? 0.0).toDouble(),
      currency: map['currency'] as String? ?? 'TRY',
      startDate: DateTime.parse(map['start_date'] as String).toUtc(),
      endDate: map['end_date'] != null ? DateTime.parse(map['end_date'] as String).toUtc() : null,
      increaseRateNote: map['increase_rate_note'] as String?,
      specialTerms: map['special_terms'] as String?,
    );
  }

  F1LeaseData copyWith({
    String? tenantName,
    String? landlordName,
    String? address,
    double? monthlyRent,
    double? depositAmount,
    String? currency,
    DateTime? startDate,
    DateTime? endDate,
    String? increaseRateNote,
    String? specialTerms,
  }) {
    return F1LeaseData(
      tenantName: tenantName ?? this.tenantName,
      landlordName: landlordName ?? this.landlordName,
      address: address ?? this.address,
      monthlyRent: monthlyRent ?? this.monthlyRent,
      depositAmount: depositAmount ?? this.depositAmount,
      currency: currency ?? this.currency,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      increaseRateNote: increaseRateNote ?? this.increaseRateNote,
      specialTerms: specialTerms ?? this.specialTerms,
    );
  }

  static Map<String, String> validate(F1LeaseData data) {
    final errors = <String, String>{};

    if (data.tenantName.trim().isEmpty) {
      errors['tenant_name'] = 'Kiracı adı boş bırakılamaz.';
    }
    if (data.landlordName.trim().isEmpty) {
      errors['landlord_name'] = 'Ev sahibi adı boş bırakılamaz.';
    }
    if (data.address.trim().isEmpty) {
      errors['address'] = 'Taşınmaz adresi boş bırakılamaz.';
    }
    if (data.monthlyRent <= 0) {
      errors['monthly_rent'] = 'Kira bedeli 0\'dan büyük olmalıdır.';
    }
    if (data.depositAmount < 0) {
      errors['deposit_amount'] = 'Depozito bedeli negatif olamaz.';
    }
    if (data.endDate != null && data.endDate!.isBefore(data.startDate)) {
      errors['end_date'] = 'Bitiş tarihi başlangıç tarihinden önce olamaz.';
    }

    return errors;
  }
}
