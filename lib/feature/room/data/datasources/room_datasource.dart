import '../../../../src/core/network/api_client.dart';
import '../models/area_model.dart';
import '../models/room_image_model.dart';
import '../models/room_model.dart';

abstract class RoomRemoteDataSource {
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
  Future<RoomModel> getRoomById(int roomId);
  Future<List<RoomImageModel>> getRoomImages(int roomId);
  Future<List<AreaModel>> getAreas();
}

class RoomRemoteDataSourceImpl implements RoomRemoteDataSource {
  final ApiService apiService;

  RoomRemoteDataSourceImpl({required this.apiService});

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
    final queryParams = {
      'page': page.toString(),
      'limit': limit.toString(),
      if (minCapacity != null) 'min_capacity': minCapacity.toString(),
      if (maxCapacity != null) 'max_capacity': maxCapacity.toString(),
      if (minPrice != null) 'min_price': minPrice.toString(),
      if (maxPrice != null) 'max_price': maxPrice.toString(),
      if (available != null) 'available': available.toString(),
      if (search != null && search.isNotEmpty) 'search': search,
      if (areaId != null) 'area_id': areaId.toString(),
    };

    final response = await apiService.get('/rooms', queryParams: queryParams);
    final rooms = (response['rooms'] as List).map((json) => RoomModel.fromJson(json)).toList();
    return {
      'rooms': rooms,
      'total': response['total'] as int,
      'pages': response['pages'] as int,
      'current_page': response['current_page'] as int,
    };
  }

  @override
  Future<RoomModel> getRoomById(int roomId) async {
    final response = await apiService.get('/rooms/$roomId');
    return RoomModel.fromJson(response);
  }

  @override
  Future<List<RoomImageModel>> getRoomImages(int roomId) async {
    try {
      final response = await apiService.get('/rooms/$roomId/images');
      print('GET /rooms/$roomId/images response: $response');
      final images = (response as List)
          .map((json) {
        final imageModel = RoomImageModel.fromJson({
          'image_id': json['imageId'],
          'image_url': json['imageUrl'],
          'file_type': json['fileType'],
          'room_id': roomId,
          'is_primary': json['isPrimary'] ?? false,
          'sort_order': json['sortOrder'] ?? 0,
          'is_deleted': json['isDeleted'] ?? false,
        });
        print('Parsed RoomImageModel: roomId=${imageModel.roomId}, imageUrl=${imageModel.imageUrl}');
        return imageModel;
      })
          .toList();
      return images;
    } catch (e) {
      print('Error fetching images for room $roomId: $e');
      rethrow;
    }
  }

  @override
  Future<List<AreaModel>> getAreas() async {
    try {
      final response = await apiService.get('/public/areas');
      print('GET /public/areas response: $response');
      final areaList = (response is List) ? response : response['areas'] as List;
      final areas = areaList.map((json) => AreaModel.fromJson(json)).toList();
      return areas;
    } catch (e) {
      print('Error fetching areas: $e');
      rethrow;
    }
  }
}