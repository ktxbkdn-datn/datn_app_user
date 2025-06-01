import 'package:get_it/get_it.dart';
import '../../../../../src/core/network/api_client.dart';
import '../../../../feature/bill/data/datasource/payment_transaction_datasource.dart';
import '../../../../feature/bill/data/repository/payment_transaction_repository_impl.dart' hide PaymentTransactionRemoteDataSource;
import '../../../../feature/bill/domain/repository/payment_transaction_repository.dart';
import '../../../../feature/bill/presentation/bloc/payment_bloc/payment_bloc.dart';

final getIt = GetIt.instance;

void registerPaymentDependencies() {
  // Đăng ký Data Source
  getIt.registerSingleton<PaymentTransactionRemoteDataSource>(
    PaymentTransactionRemoteDataSourceImpl(getIt<ApiService>()),
  );

  // Đăng ký Repository
  getIt.registerSingleton<PaymentTransactionRepository>(
    PaymentTransactionRepositoryImpl(getIt<PaymentTransactionRemoteDataSource>()),
  );

  // Đăng ký BLoC
  getIt.registerFactory<PaymentTransactionBloc>(() => PaymentTransactionBloc(
    paymentTransactionRepository: getIt<PaymentTransactionRepository>(),
  ));
}