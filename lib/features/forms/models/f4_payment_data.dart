import 'package:flutter/foundation.dart';

@immutable
class F4PaymentData {
  final String paymentType; // 'rent' (Kira), 'deposit' (Depozito), 'dues' (Aidat), 'other' (Diğer)
  final double amount;
  final String currency;
  final String period; // örn. 'Kasım 2026'
  final String paymentMethod; // 'bank_transfer' (Banka Havale/EFT), 'cash' (Nakit/Elden), 'other'
  final DateTime paidAt;
  final String payerName;
  final String receiverName;
  final String? receiptNumber;
  final String? receiptFilePath;
  final String? notes;

  const F4PaymentData({
    required this.paymentType,
    required this.amount,
    this.currency = 'TRY',
    required this.period,
    this.paymentMethod = 'bank_transfer',
    required this.paidAt,
    required this.payerName,
    required this.receiverName,
    this.receiptNumber,
    this.receiptFilePath,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'payment_type': paymentType,
      'amount': amount,
      'currency': currency,
      'period': period,
      'payment_method': paymentMethod,
      'paid_at': paidAt.toUtc().toIso8601String(),
      'payer_name': payerName,
      'receiver_name': receiverName,
      'receipt_number': receiptNumber,
      'receipt_file_path': receiptFilePath,
      'notes': notes,
    };
  }

  factory F4PaymentData.fromMap(Map<String, dynamic> map) {
    return F4PaymentData(
      paymentType: map['payment_type'] as String,
      amount: (map['amount'] as num).toDouble(),
      currency: map['currency'] as String? ?? 'TRY',
      period: map['period'] as String,
      paymentMethod: map['payment_method'] as String? ?? 'bank_transfer',
      paidAt: DateTime.parse(map['paid_at'] as String).toUtc(),
      payerName: map['payer_name'] as String,
      receiverName: map['receiver_name'] as String,
      receiptNumber: map['receipt_number'] as String?,
      receiptFilePath: map['receipt_file_path'] as String?,
      notes: map['notes'] as String?,
    );
  }

  F4PaymentData copyWith({
    String? paymentType,
    double? amount,
    String? currency,
    String? period,
    String? paymentMethod,
    DateTime? paidAt,
    String? payerName,
    String? receiverName,
    String? receiptNumber,
    String? receiptFilePath,
    String? notes,
  }) {
    return F4PaymentData(
      paymentType: paymentType ?? this.paymentType,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      period: period ?? this.period,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paidAt: paidAt ?? this.paidAt,
      payerName: payerName ?? this.payerName,
      receiverName: receiverName ?? this.receiverName,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      receiptFilePath: receiptFilePath ?? this.receiptFilePath,
      notes: notes ?? this.notes,
    );
  }

  static Map<String, String> validate(F4PaymentData data) {
    final errors = <String, String>{};

    if (data.amount <= 0) {
      errors['amount'] = 'Ödeme tutarı 0\'dan büyük olmalıdır.';
    }
    if (data.period.trim().isEmpty) {
      errors['period'] = 'Ödeme dönemi belirtilmelidir (örn. Kasım 2026).';
    }
    if (data.payerName.trim().isEmpty) {
      errors['payer_name'] = 'Ödeyen kişi adı boş bırakılamaz.';
    }
    if (data.receiverName.trim().isEmpty) {
      errors['receiver_name'] = 'Alıcı adı boş bırakılamaz.';
    }

    return errors;
  }
}
