import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../../domain/entity/payment_transaction_entity.dart';
import '../../domain/repository/payment_transaction_repository.dart';
import '../datasource/payment_transaction_datasource.dart';

class PaymentTransactionRepositoryImpl implements PaymentTransactionRepository {
  final PaymentTransactionRemoteDataSource remoteDataSource;

  PaymentTransactionRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, PaymentTransaction>> createPaymentTransaction({
    required int billId,
    required String paymentMethod,
    required String? returnUrl,
  }) async {
    try {
      final result = await remoteDataSource.createPaymentTransaction(
        billId: billId,
        paymentMethod: paymentMethod,
        returnUrl: returnUrl,
      );
      return result.map((model) => model.toEntity());
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, PaymentTransaction>> getPaymentTransactionById({
    required String transactionId,
  }) async {
    try {
      final result = await remoteDataSource.getPaymentTransactionById(
        transactionId: transactionId,
      );
      return result.map((model) => model.toEntity());
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, PaymentTransaction>> handlePaymentSuccess({
    required String transactionId,
    required String status,
    required String bankCode,
    required String transactionNo,
    required String payDate,
    required double amount,
  }) async {
    try {
      final result = await remoteDataSource.handlePaymentSuccess(
        transactionId: transactionId,
        status: status,
        bankCode: bankCode,
        transactionNo: transactionNo,
        payDate: payDate,
        amount: amount,
      );
      return result.map((model) => model.toEntity());
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, PaymentTransaction>> handlePaymentFailure({
    required String transactionId,
    required String status,
    required String bankCode,
    required String transactionNo,
    required String payDate,
    required double amount,
  }) async {
    try {
      final result = await remoteDataSource.handlePaymentFailure(
        transactionId: transactionId,
        status: status,
        bankCode: bankCode,
        transactionNo: transactionNo,
        payDate: payDate,
        amount: amount,
      );
      return result.map((model) => model.toEntity());
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }

  @override
  Future<Either<Failure, List<PaymentTransaction>>> fetchMyTransactions({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final result = await remoteDataSource.fetchMyTransactions(
        page: page,
        limit: limit,
      );
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }
}