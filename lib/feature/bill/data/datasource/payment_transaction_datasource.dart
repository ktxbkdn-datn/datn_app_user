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
      // Convert the billId to a String to match expected API format
      final body = {
        'bill_id': billId.toString(), // Convert to string to match API expectations
        'payment_method': 'VNPAY',
        'return_url': returnUrl ?? 'http://kytucxa.dev.dut.navia.io.vn/payment-transactions/callback',
      };

      print('Creating payment transaction with body: $body');
      print('Bill ID original type: ${billId.runtimeType}, value: $billId');
      print('Bill ID converted type: ${body['bill_id'].runtimeType}, value: ${body['bill_id']}');
      print('API base URL: ${apiService.baseUrl}');
      print('Endpoint: payment-transactions (without leading slash)');
      
      // The base URL already includes /api so we don't need to include it in the endpoint
      final response = await apiService.post('/payment-transactions', body);
      print('Payment transaction created: $response');
      return Right(PaymentTransactionModel.fromJson(response));
    } catch (e) {
      print('Error creating payment transaction: $e');
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, PaymentTransactionModel>> getPaymentTransactionById({
    required String transactionId,
  }) async {
    try {
      print('Fetching payment transaction with ID: $transactionId');
      print('API base URL: ${apiService.baseUrl}');
      print('Endpoint: /payment-transactions/$transactionId (with leading slash)');
      
      final response = await apiService.get('/payment-transactions/$transactionId');
      print('Payment transaction fetched: $response');
      return Right(PaymentTransactionModel.fromJson(response));
    } catch (e) {
      print('Error fetching payment transaction: $e');
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
      print('Handling payment success with: $body');
      final response = await apiService.post('/payment-transactions/success', body);
      print('Payment success response: $response');
      return Right(PaymentTransactionModel.fromJson(response));
    } catch (e) {
      print('Error handling payment success: $e');
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
      print('Handling payment failure with: $body');
      final response = await apiService.post('/payment-transactions/failure', body);
      print('Payment failure response: $response');
      return Right(PaymentTransactionModel.fromJson(response));
    } catch (e) {
      print('Error handling payment failure: $e');
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
      print('Fetching my transactions with: $queryParams');
      final response = await apiService.get('/payment-transactions/my-transactions', queryParams: queryParams);
      print('My transactions response: $response');
      final transactions = (response['transactions'] as List)
          .map((json) => PaymentTransactionModel.fromJson(json))
          .toList();
      return Right(transactions);
    } catch (e) {
      print('Error fetching my transactions: $e');
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