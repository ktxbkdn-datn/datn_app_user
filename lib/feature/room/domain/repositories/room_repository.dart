
import '../entities/area_entity.dart';
import '../entities/room_entity.dart';
import '../entities/room_image_entity.dart';

abstract class RoomRepository {
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
  });
  Future<RoomEntity> getRoomById(int roomId);
  Future<List<RoomImageEntity>> getRoomImages(int roomId);
  Future<List<AreaEntity>> getAreas();
}