
import '../entities/area_entity.dart';
import '../entities/room_entity.dart';
import '../entities/room_image_entity.dart';
import '../repositories/room_repository.dart';

class GetRooms {
  final RoomRepository repository;

  GetRooms({required this.repository});

  Future<Map<String, dynamic>> call({
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
    return await repository.getRooms(
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
}

class GetRoomById {
  final RoomRepository repository;

  GetRoomById({required this.repository});

  Future<RoomEntity> call(int roomId) async {
    return await repository.getRoomById(roomId);
  }
}

class GetRoomImages {
  final RoomRepository repository;

  GetRoomImages({required this.repository});

  Future<List<RoomImageEntity>> call(int roomId) async {
    return await repository.getRoomImages(roomId);
  }
}

class GetAreas {
  final RoomRepository repository;

  GetAreas({required this.repository});

  Future<List<AreaEntity>> call() async {
    return await repository.getAreas();
  }
}