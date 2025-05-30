import 'package:get_it/get_it.dart';

import '../../../../feature/auth/data/datasources/auth_remote_data_source.dart';
import '../../../../feature/auth/data/repositories/auth_repository_impl.dart';
import '../../../../feature/auth/domain/repositories/auth_repository.dart';
import '../../../../feature/auth/domain/usecases/auth_usecase.dart';
import '../../../../feature/auth/presentation/bloc/auth_bloc.dart';
import '../../network/api_client.dart';

final getIt = GetIt.instance;

void registerAuthDependencies() {
  // Đăng ký Data Source
  getIt.registerSingleton<AuthRemoteDataSource>(
    AuthRemoteDataSourceImpl(getIt<ApiService>()),
  );

  // Đăng ký Repository
  getIt.registerSingleton<AuthRepository>(
    AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
  );

  // Đăng ký Use Cases
  getIt.registerSingleton<Login>(
    Login(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<Logout>(
    Logout(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<ForgotPassword>(
    ForgotPassword(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<ResetPassword>(
    ResetPassword(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<GetUserProfile>(
    GetUserProfile(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<ChangePassword>( // Thêm use case ChangePassword
    ChangePassword(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<UpdateUserProfile>( // Thêm use case UpdateUserProfile
    UpdateUserProfile(getIt<AuthRepository>()),
  );
  getIt.registerSingleton<UpdateAvatar>( // Thêm use case UpdateAvatar
    UpdateAvatar(getIt<AuthRepository>()),
  );

  // Đăng ký BLoC
  getIt.registerFactory<AuthBloc>(() => AuthBloc(
    login: getIt<Login>(),
    logout: getIt<Logout>(),
    forgotPassword: getIt<ForgotPassword>(),
    resetPassword: getIt<ResetPassword>(),
    getUserProfile: getIt<GetUserProfile>(),
    changePassword: getIt<ChangePassword>(), // Thêm vào constructor
    updateUserProfile: getIt<UpdateUserProfile>(), // Thêm vào constructor
    updateAvatar: getIt<UpdateAvatar>(), // Thêm vào constructor
  ));
}