import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entity/payment_transaction_entity.dart';

abstract class PaymentTransactionRepository {
  Future<Either<Failure, PaymentTransaction>> createPaymentTransaction({
    required int billId,
    required String paymentMethod,
    required String? returnUrl,
  });

  Future<Either<Failure, PaymentTransaction>> getPaymentTransactionById({
    required String transactionId,
  });

  Future<Either<Failure, PaymentTransaction>> handlePaymentSuccess({
    required String transactionId,
    required String status,
    required String bankCode,
    required String transactionNo,
    required String payDate,
    required double amount,
  });

  Future<Either<Failure, PaymentTransaction>> handlePaymentFailure({
    required String transactionId,
    required String status,
    required String bankCode,
    required String transactionNo,
    required String payDate,
    required double amount,
  });

  Future<Either<Failure, List<PaymentTransaction>>> fetchMyTransactions({
    int page = 1,
    int limit = 10,
  });
}