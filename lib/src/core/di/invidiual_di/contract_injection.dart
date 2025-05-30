import 'package:get_it/get_it.dart';
import '../../../../../src/core/network/api_client.dart';
import '../../../../feature/contract/data/datasource/contract_data_source.dart';
import '../../../../feature/contract/data/repository/contract_repository_impl.dart';
import '../../../../feature/contract/domain/repository/contract_repository.dart';
import '../../../../feature/contract/domain/usecase/get_user_contract.dart';
import '../../../../feature/contract/presentation/bloc/contract_bloc.dart';

final getIt = GetIt.instance;

void registerContractDependencies() {
  // Đăng ký ApiService (nếu chưa được đăng ký ở nơi khác)
  // Đăng ký Data Source
  getIt.registerSingleton<ContractRemoteDataSource>(
    ContractRemoteDataSourceImpl(getIt<ApiService>()),
  );

  // Đăng ký Repository
  getIt.registerSingleton<ContractRepository>(
    ContractRepositoryImpl(getIt<ContractRemoteDataSource>()),
  );

  // Đăng ký Use Case
  getIt.registerSingleton<GetUserContracts>(
    GetUserContracts(getIt<ContractRepository>()),
  );

  // Đăng ký BLoC
  getIt.registerFactory<ContractBloc>(
        () => ContractBloc(
      getUserContracts: getIt<GetUserContracts>(),
    ),
  );
}