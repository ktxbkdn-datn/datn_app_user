import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../../../../src/core/network/api_client.dart';
import '../model/payment_transaction_model.dart';


abstract class PaymentTransactionRemoteDataSource {
  Future<Either<Failure, PaymentTransactionModel>> createPaymentTransaction({
    required int billId,
    required String paymentMethod,
    required String? returnUrl,
  });

  Future<Either<Failure, PaymentTransactionModel>> getPaymentTransactionById({
    required String transactionId,
  });

  Future<Either<Failure, PaymentTransactionModel>> handlePaymentSuccess({
    required String transactionId,
    required String status,
    required String bankCode,
    required String transactionNo,
    required String payDate,
    required double amount,
  });

  Future<Either<Failure, PaymentTransactionModel>> handlePaymentFailure({
    required String transactionId,
    required String status,
    required String bankCode,
    required String transactionNo,
    required String payDate,
    required double amount,
  });

  Future<Either<Failure, List<PaymentTransactionModel>>> fetchMyTransactions({
    int page = 1,
    int limit = 10,
  });
}

class PaymentTransactionRemoteDataSourceImpl implements PaymentTransactionRemoteDataSource {
  final ApiService apiService;

  PaymentTransactionRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<Failure, PaymentTransactionModel>> createPaymentTransaction({
    required int billId,
    required String paymentMethod,
    required String? returnUrl,
  }) async {
    try {
      final body = {
        'bill_id': billId,
        'payment_method': paymentMethod,
        'return_url': returnUrl,
      };
      final response = await apiService.post('/payment-transactions', body);
      return Right(PaymentTransactionModel.fromJson(response));
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, PaymentTransactionModel>> getPaymentTransactionById({
    required String transactionId,
  }) async {
    try {
      final response = await apiService.get('/payment-transaction/$transactionId');
      return Right(PaymentTransactionModel.fromJson(response));
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, PaymentTransactionModel>> handlePaymentSuccess({
    required String transactionId,
    required String status,
    required String bankCode,
    required String transactionNo,
    required String payDate,
    required double amount,
  }) async {
    try {
      final body = {
        'transaction_id': transactionId,
        'status': status,
        'bank_code': bankCode,
        'transaction_no': transactionNo,
        'pay_date': payDate,
        'amount': amount,
      };
      final response = await apiService.post('/payment-transaction/success', body);
      return Right(PaymentTransactionModel.fromJson(response));
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, PaymentTransactionModel>> handlePaymentFailure({
    required String transactionId,
    required String status,
    required String bankCode,
    required String transactionNo,
    required String payDate,
    required double amount,
  }) async {
    try {
      final body = {
        'transaction_id': transactionId,
        'status': status,
        'bank_code': bankCode,
        'transaction_no': transactionNo,
        'pay_date': payDate,
        'amount': amount,
      };
      final response = await apiService.post('/payment-transaction/failure', body);
      return Right(PaymentTransactionModel.fromJson(response));
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, List<PaymentTransactionModel>>> fetchMyTransactions({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      final response = await apiService.get('/my-transactions', queryParams: queryParams);
      final transactions = (response['transactions'] as List)
          .map((json) => PaymentTransactionModel.fromJson(json))
          .toList();
      return Right(transactions);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(dynamic error) {
    if (error is ApiException) {
      return ServerFailure(error.message);
    } else if (error is NetworkFailure) {
      return NetworkFailure(error.message);
    } else {
      return ServerFailure('Lỗi không xác định: $error');
    }
  }
}