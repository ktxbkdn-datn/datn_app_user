import 'package:get_it/get_it.dart';
import '../../../../../src/core/network/api_client.dart';

import '../../../../feature/service/data/datasource/service_datasource.dart';
import '../../../../feature/service/data/repository/service_repository_impl.dart';
import '../../../../feature/service/domain/repository/service_repository.dart';
import '../../../../feature/service/presentation/bloc/service_bloc.dart';

final getIt = GetIt.instance;

void registerServiceDependencies() {
  // Đăng ký Data Source
  getIt.registerSingleton<ServiceRemoteDataSource>(
    ServiceRemoteDataSourceImpl(getIt<ApiService>()),
  );

  // Đăng ký Repository
  getIt.registerSingleton<ServiceRepository>(
    ServiceRepositoryImpl(getIt<ServiceRemoteDataSource>()),
  );

  // Đăng ký BLoC
  getIt.registerFactory<ServiceBloc>(
        () => ServiceBloc(serviceRepository: getIt<ServiceRepository>()),
  );
}