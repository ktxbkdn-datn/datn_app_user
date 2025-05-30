import 'package:equatable/equatable.dart';

class PaymentTransaction extends Equatable {
  final String transactionId;
  final int billId;
  final int userId;
  final double amount;
  final String paymentMethod;
  final String status;
  final String? bankCode;
  final String? transactionNo;
  final String? payDate;
  final String? returnUrl;
  final String? createdAt;
  final String? processedAt;
  final String? gatewayReference;
  final String? paymentUrl; // Added

  const PaymentTransaction({
    required this.transactionId,
    required this.billId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    this.bankCode,
    this.transactionNo,
    this.payDate,
    this.returnUrl,
    this.createdAt,
    this.processedAt,
    this.gatewayReference,
    this.paymentUrl, // Added
  });

  @override
  List<Object?> get props => [
    transactionId,
    billId,
    userId,
    amount,
    paymentMethod,
    status,
    bankCode,
    transactionNo,
    payDate,
    returnUrl,
    createdAt,
    processedAt,
    gatewayReference,
    paymentUrl, // Added
  ];
}