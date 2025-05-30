

import '../../domain/entities/area_entity.dart';
import '../../domain/entities/room_entity.dart';
import '../../domain/entities/room_image_entity.dart';
import '../../domain/repositories/room_repository.dart';
import '../datasources/room_datasource.dart';

class RoomRepositoryImpl implements RoomRepository {
  final RoomRemoteDataSource remoteDataSource;

  RoomRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Map<String, dynamic>> getRooms({
    int page = 1,
    int limit = 10,
    int? minCapacity,
    int? maxCapacity,
    double? minPrice,
    double? maxPrice,
    bool? available,
    String? search,
    int? areaId,
  }) async {
    return await remoteDataSource.getRooms(
      page: page,
      limit: limit,
      minCapacity: minCapacity,
      maxCapacity: maxCapacity,
      minPrice: minPrice,
      maxPrice: maxPrice,
      available: available,
      search: search,
      areaId: areaId,
    );
  }

  @override
  Future<RoomEntity> getRoomById(int roomId) async {
    return await remoteDataSource.getRoomById(roomId);
  }

  @override
  Future<List<RoomImageEntity>> getRoomImages(int roomId) async {
    return await remoteDataSource.getRoomImages(roomId);
  }

  @override
  Future<List<AreaEntity>> getAreas() async {
    return await remoteDataSource.getAreas();
  }
}