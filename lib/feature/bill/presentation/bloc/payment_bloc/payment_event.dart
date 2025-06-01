import 'package:equatable/equatable.dart';

abstract class PaymentTransactionEvent extends Equatable {
  const PaymentTransactionEvent();

  @override
  List<Object?> get props => [];
}

class CreatePaymentTransactionEvent extends PaymentTransactionEvent {
  final int billId;
  final String paymentMethod;
  final String? returnUrl;

  const CreatePaymentTransactionEvent({
    required this.billId,
    required this.paymentMethod,
    this.returnUrl,
  });

  @override
  List<Object?> get props => [billId, paymentMethod, returnUrl];
}

class GetPaymentTransactionByIdEvent extends PaymentTransactionEvent {
  final String transactionId;

  const GetPaymentTransactionByIdEvent({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}

class ProcessPaymentSuccessEvent extends PaymentTransactionEvent {
  final String transactionId;
  final String status;
  final String bankCode;
  final String transactionNo;
  final String payDate;
  final double amount;

  const ProcessPaymentSuccessEvent({
    required this.transactionId,
    required this.status,
    required this.bankCode,
    required this.transactionNo,
    required this.payDate,
    required this.amount,
  });

  @override
  List<Object?> get props => [transactionId, status, bankCode, transactionNo, payDate, amount];
}

class ProcessPaymentFailureEvent extends PaymentTransactionEvent {
  final String transactionId;
  final String status;
  final String bankCode;
  final String transactionNo;
  final String payDate;
  final double amount;

  const ProcessPaymentFailureEvent({
    required this.transactionId,
    required this.status,
    required this.bankCode,
    required this.transactionNo,
    required this.payDate,
    required this.amount,
  });

  @override
  List<Object?> get props => [transactionId, status, bankCode, transactionNo, payDate, amount];
}

class ResetPaymentTransactionStateEvent extends PaymentTransactionEvent {}

class FetchMyTransactionsEvent extends PaymentTransactionEvent {
  final int page;
  final int limit;

  const FetchMyTransactionsEvent({
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [page, limit];
}