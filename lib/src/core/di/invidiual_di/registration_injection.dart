import 'package:get_it/get_it.dart';

import '../../../../feature/register/data/datasoucre/registration_datasource.dart';
import '../../../../feature/register/data/repository/registration_repository_impl.dart';
import '../../../../feature/register/domain/repository/registration_repository.dart';
import '../../../../feature/register/domain/usecase/register_usecase.dart';
import '../../../../feature/register/presentation/bloc/registration_bloc.dart';
import '../../network/api_client.dart';


final getIt = GetIt.instance;

void registerRegistrationDependencies() {
  // Đăng ký Data Source
  getIt.registerSingleton<RegistrationRemoteDataSource>(
    RegistrationRemoteDataSourceImpl(getIt<ApiService>()),
  );

  // Đăng ký Repository
  getIt.registerSingleton<RegistrationRepository>(
    RegistrationRepositoryImpl(getIt<RegistrationRemoteDataSource>()),
  );

  // Đăng ký Use Case
  getIt.registerSingleton<CreateRegistration>(
    CreateRegistration(getIt<RegistrationRepository>()),
  );

  // Đăng ký BLoC
  getIt.registerFactory<RegistrationBloc>(() => RegistrationBloc(
    getIt<CreateRegistration>(),
  ));
}