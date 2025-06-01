import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../src/core/error/failures.dart';
import '../../../domain/repository/payment_transaction_repository.dart';
import '../../../domain/usecase/payment_transaction_usecases.dart';
import 'payment_event.dart';
import 'payment_state.dart';

class PaymentTransactionBloc extends Bloc<PaymentTransactionEvent, PaymentTransactionState> {
  final PaymentTransactionRepository paymentTransactionRepository;

  PaymentTransactionBloc({
    required this.paymentTransactionRepository,
  }) : super(PaymentTransactionInitial()) {
    on<CreatePaymentTransactionEvent>(_onCreatePaymentTransaction);
    on<GetPaymentTransactionByIdEvent>(_onGetPaymentTransactionById);
    on<ProcessPaymentSuccessEvent>(_onProcessPaymentSuccess);
    on<ProcessPaymentFailureEvent>(_onProcessPaymentFailure);
    on<ResetPaymentTransactionStateEvent>(_onResetPaymentTransactionState);
    on<FetchMyTransactionsEvent>(_onFetchMyTransactions);
  }

  /// Xử lý sự kiện tạo giao dịch thanh toán mới.
  /// Emit [PaymentTransactionLoading] khi bắt đầu, sau đó emit [PaymentTransactionLoaded] hoặc [PaymentTransactionError].
  Future<void> _onCreatePaymentTransaction(
      CreatePaymentTransactionEvent event, Emitter<PaymentTransactionState> emit) async {
    emit(PaymentTransactionLoading());
    final result = await CreatePaymentTransaction(paymentTransactionRepository)(
      billId: event.billId,
      paymentMethod: event.paymentMethod,
      returnUrl: event.returnUrl,
    );
    emit(result.fold(
          (failure) {
        if (failure is NetworkFailure) {
          return PaymentTransactionError(message: 'Không có kết nối mạng: ${failure.message}');
        }
        if (failure is ServerFailure) {
          if (failure.message.contains('Hóa đơn đã được thanh toán')) {
            return PaymentTransactionError(message: 'Hóa đơn đã được thanh toán');
          }
          if (failure.message.contains('Bạn không có quyền thanh toán hóa đơn này')) {
            return PaymentTransactionError(message: 'Bạn không có quyền thanh toán hóa đơn này');
          }
        }
        return PaymentTransactionError(message: failure.message);
      },
          (transaction) => PaymentTransactionLoaded(selectedTransaction: transaction),
    ));
  }

  /// Xử lý sự kiện lấy chi tiết giao dịch thanh toán.
  /// Emit [PaymentTransactionLoading] khi bắt đầu, sau đó emit [PaymentTransactionLoaded], [PaymentTransactionEmpty] hoặc [PaymentTransactionError].
  Future<void> _onGetPaymentTransactionById(
      GetPaymentTransactionByIdEvent event, Emitter<PaymentTransactionState> emit) async {
    emit(PaymentTransactionLoading());
    final result = await GetPaymentTransactionById(paymentTransactionRepository)(
      transactionId: event.transactionId,
    );
    emit(result.fold(
          (failure) {
        if (failure is NetworkFailure) {
          return PaymentTransactionError(message: 'Không có kết nối mạng: ${failure.message}');
        }
        if (failure is ServerFailure && failure.message.contains('Transaction not found')) {
          return PaymentTransactionEmpty(message: 'Không tìm thấy giao dịch');
        }
        return PaymentTransactionError(message: failure.message);
      },
          (transaction) => PaymentTransactionLoaded(selectedTransaction: transaction),
    ));
  }

  /// Xử lý sự kiện callback thanh toán thành công.
  /// Emit [PaymentTransactionLoading] khi bắt đầu, sau đó emit [PaymentTransactionLoaded] hoặc [PaymentTransactionError].
  Future<void> _onProcessPaymentSuccess(
      ProcessPaymentSuccessEvent event, Emitter<PaymentTransactionState> emit) async {
    emit(PaymentTransactionLoading());
    final result = await HandlePaymentSuccess(paymentTransactionRepository)(
      transactionId: event.transactionId,
      status: event.status,
      bankCode: event.bankCode,
      transactionNo: event.transactionNo,
      payDate: event.payDate,
      amount: event.amount,
    );
    emit(result.fold(
          (failure) {
        if (failure is NetworkFailure) {
          return PaymentTransactionError(message: 'Không có kết nối mạng: ${failure.message}');
        }
        return PaymentTransactionError(message: failure.message);
      },
          (transaction) {
        if (state is PaymentTransactionLoaded) {
          final currentState = state as PaymentTransactionLoaded;
          return currentState.copyWith(selectedTransaction: transaction);
        }
        return PaymentTransactionLoaded(selectedTransaction: transaction);
      },
    ));
  }

  /// Xử lý sự kiện callback thanh toán thất bại.
  /// Emit [PaymentTransactionLoading] khi bắt đầu, sau đó emit [PaymentTransactionLoaded] hoặc [PaymentTransactionError].
  Future<void> _onProcessPaymentFailure(
      ProcessPaymentFailureEvent event, Emitter<PaymentTransactionState> emit) async {
    emit(PaymentTransactionLoading());
    final result = await HandlePaymentFailure(paymentTransactionRepository)(
      transactionId: event.transactionId,
      status: event.status,
      bankCode: event.bankCode,
      transactionNo: event.transactionNo,
      payDate: event.payDate,
      amount: event.amount,
    );
    emit(result.fold(
          (failure) {
        if (failure is NetworkFailure) {
          return PaymentTransactionError(message: 'Không có kết nối mạng: ${failure.message}');
        }
        return PaymentTransactionError(message: failure.message);
      },
          (transaction) {
        if (state is PaymentTransactionLoaded) {
          final currentState = state as PaymentTransactionLoaded;
          return currentState.copyWith(selectedTransaction: transaction);
        }
        return PaymentTransactionLoaded(selectedTransaction: transaction);
      },
    ));
  }

  /// Xử lý sự kiện lấy lịch sử giao dịch thanh toán của người dùng.
  /// Emit [PaymentTransactionLoading] khi bắt đầu, sau đó emit [PaymentTransactionLoaded], [PaymentTransactionEmpty] hoặc [PaymentTransactionError].
  Future<void> _onFetchMyTransactions(
      FetchMyTransactionsEvent event, Emitter<PaymentTransactionState> emit) async {
    emit(PaymentTransactionLoading());
    final result = await FetchMyTransactions(paymentTransactionRepository)(
      page: event.page,
      limit: event.limit,
    );
    emit(result.fold(
          (failure) {
        if (failure is NetworkFailure) {
          return PaymentTransactionError(message: 'Không có kết nối mạng: ${failure.message}');
        }
        if (failure is ServerFailure && failure.message.contains('Không tìm thấy giao dịch nào')) {
          return PaymentTransactionEmpty(message: 'Không tìm thấy giao dịch nào');
        }
        return PaymentTransactionError(message: failure.message);
      },
          (transactions) {
        if (state is PaymentTransactionLoaded) {
          final currentState = state as PaymentTransactionLoaded;
          return currentState.copyWith(transactions: transactions);
        }
        return PaymentTransactionLoaded(transactions: transactions);
      },
    ));
  }

  /// Xử lý sự kiện reset trạng thái về [PaymentTransactionInitial].
  Future<void> _onResetPaymentTransactionState(
      ResetPaymentTransactionStateEvent event, Emitter<PaymentTransactionState> emit) async {
    emit(PaymentTransactionInitial());
  }
}