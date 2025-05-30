import 'package:get_it/get_it.dart';

import '../../../../feature/room/data/datasources/room_datasource.dart';
import '../../../../feature/room/data/repository/room_repository_impl.dart';
import '../../../../feature/room/domain/repositories/room_repository.dart';
import '../../../../feature/room/domain/usecases/room_usecase.dart';
import '../../../../feature/room/presentations/bloc/room_bloc/room_bloc.dart';
import '../../network/api_client.dart';


final getIt = GetIt.instance;

void registerRoomDependencies() {
  // Đăng ký Data Source
  getIt.registerSingleton<RoomRemoteDataSource>(
    RoomRemoteDataSourceImpl(apiService: getIt<ApiService>()),
  );

  // Đăng ký Repository
  getIt.registerSingleton<RoomRepository>(
    RoomRepositoryImpl(remoteDataSource: getIt<RoomRemoteDataSource>()),
  );

  // Đăng ký UseCase
  getIt.registerSingleton<GetRooms>(
    GetRooms(repository: getIt<RoomRepository>()),
  );

  getIt.registerSingleton<GetRoomById>(
    GetRoomById(repository: getIt<RoomRepository>()),
  );

  getIt.registerSingleton<GetRoomImages>(
    GetRoomImages(repository: getIt<RoomRepository>()),
  );

  getIt.registerSingleton<GetAreas>(
    GetAreas(repository: getIt<RoomRepository>()),
  );

  // Đăng ký BLoC
  getIt.registerFactory<RoomBloc>(() => RoomBloc(
    getRooms: getIt<GetRooms>(),
    getRoomById: getIt<GetRoomById>(),
    getRoomImages: getIt<GetRoomImages>(),
    getAreas: getIt<GetAreas>(),
  ));
}