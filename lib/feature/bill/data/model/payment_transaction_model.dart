import 'package:equatable/equatable.dart';

import '../../domain/entity/payment_transaction_entity.dart';


class PaymentTransactionModel extends Equatable {
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

  const PaymentTransactionModel({
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

  factory PaymentTransactionModel.fromJson(Map<String, dynamic> json) {
    return PaymentTransactionModel(
      transactionId: json['transaction_id'].toString(),
      billId: json['bill_id'] as int? ?? 0, // Gán giá trị mặc định nếu null
      userId: json['user_id'] as int? ?? 0, // Gán giá trị mặc định nếu null
      amount: double.parse(json['amount']?.toString() ?? '0.0'),
      paymentMethod: json['payment_method'] as String? ?? '',
      status: json['status'] as String? ?? '',
      bankCode: json['bank_code'] as String?,
      transactionNo: json['transaction_no'] as String?,
      payDate: json['pay_date'] as String?,
      returnUrl: json['return_url'] as String?,
      createdAt: json['created_at'] as String?,
      processedAt: json['processed_at'] as String?,
      gatewayReference: json['gateway_reference'] as String?,
      paymentUrl: json['payment_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'bill_id': billId,
      'user_id': userId,
      'amount': amount,
      'payment_method': paymentMethod,
      'status': status,
      'bank_code': bankCode,
      'transaction_no': transactionNo,
      'pay_date': payDate,
      'return_url': returnUrl,
      'created_at': createdAt,
      'processed_at': processedAt,
      'gateway_reference': gatewayReference,
      'payment_url': paymentUrl, // Added
    };
  }

  PaymentTransaction toEntity() {
    return PaymentTransaction(
      transactionId: transactionId,
      billId: billId,
      userId: userId,
      amount: amount,
      paymentMethod: paymentMethod,
      status: status,
      bankCode: bankCode,
      transactionNo: transactionNo,
      payDate: payDate,
      returnUrl: returnUrl,
      createdAt: createdAt,
      processedAt: processedAt,
      gatewayReference: gatewayReference,
      paymentUrl: paymentUrl, // Added
    );
  }

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