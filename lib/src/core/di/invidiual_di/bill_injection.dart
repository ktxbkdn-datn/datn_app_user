import 'package:get_it/get_it.dart';
import '../../../../../src/core/network/api_client.dart';
import '../../../../feature/bill/data/datasource/bill_datasource.dart';
import '../../../../feature/bill/data/repository/bill_repository_impl.dart' hide BillRemoteDataSource;
import '../../../../feature/bill/domain/repository/bill_repository.dart';
import '../../../../feature/bill/presentation/bill_bloc/bill_bloc.dart';

final getIt = GetIt.instance;

void registerBillDependencies() {
  // Đăng ký Data Source
  getIt.registerSingleton<BillRemoteDataSource>(
    BillRemoteDataSourceImpl(getIt<ApiService>()),
  );

  // Đăng ký Repository
  getIt.registerSingleton<BillRepository>(
    BillRepositoryImpl(getIt<BillRemoteDataSource>()),
  );

  // Đăng ký BLoC
  getIt.registerFactory<BillBloc>(() => BillBloc(
    billRepository: getIt<BillRepository>(),
  ));
}