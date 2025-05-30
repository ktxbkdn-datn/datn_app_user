import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entity/payment_transaction_entity.dart';
import '../repository/payment_transaction_repository.dart';

class CreatePaymentTransaction {
  final PaymentTransactionRepository repository;

  CreatePaymentTransaction(this.repository);

  Future<Either<Failure, PaymentTransaction>> call({
    required int billId,
    required String paymentMethod,
    required String? returnUrl,
  }) async {
    return await repository.createPaymentTransaction(
      billId: billId,
      paymentMethod: paymentMethod,
      returnUrl: returnUrl,
    );
  }
}

class GetPaymentTransactionById {
  final PaymentTransactionRepository repository;

  GetPaymentTransactionById(this.repository);

  Future<Either<Failure, PaymentTransaction>> call({
    required String transactionId,
  }) async {
    return await repository.getPaymentTransactionById(
      transactionId: transactionId,
    );
  }
}

class HandlePaymentSuccess {
  final PaymentTransactionRepository repository;

  HandlePaymentSuccess(this.repository);

  Future<Either<Failure, PaymentTransaction>> call({
    required String transactionId,
    required String status,
    required String bankCode,
    required String transactionNo,
    required String payDate,
    required double amount,
  }) async {
    return await repository.handlePaymentSuccess(
      transactionId: transactionId,
      status: status,
      bankCode: bankCode,
      transactionNo: transactionNo,
      payDate: payDate,
      amount: amount,
    );
  }
}

class HandlePaymentFailure {
  final PaymentTransactionRepository repository;

  HandlePaymentFailure(this.repository);

  Future<Either<Failure, PaymentTransaction>> call({
    required String transactionId,
    required String status,
    required String bankCode,
    required String transactionNo,
    required String payDate,
    required double amount,
  }) async {
    return await repository.handlePaymentFailure(
      transactionId: transactionId,
      status: status,
      bankCode: bankCode,
      transactionNo: transactionNo,
      payDate: payDate,
      amount: amount,
    );
  }
}

class FetchMyTransactions {
  final PaymentTransactionRepository repository;

  FetchMyTransactions(this.repository);

  Future<Either<Failure, List<PaymentTransaction>>> call({
    int page = 1,
    int limit = 10,
  }) async {
    return await repository.fetchMyTransactions(
      page: page,
      limit: limit,
    );
  }
}