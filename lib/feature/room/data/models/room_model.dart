// lib/src/features/room/data/models/room_model.dart
import '../../domain/entities/area_entity.dart';
import '../models/area_model.dart';
import '../../domain/entities/room_entity.dart';

class RoomModel extends RoomEntity {
  RoomModel({
    required int roomId,
    required String name,
    required int capacity,
    required double price,
    required int currentPersonNumber,
    String? description,
    required String status,
    required int areaId,
    AreaEntity? areaDetails,
  }) : super(
    roomId: roomId,
    name: name,
    capacity: capacity,
    price: price,
    currentPersonNumber: currentPersonNumber,
    description: description,
    status: status,
    areaId: areaId,
    areaDetails: areaDetails,
  );

  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      roomId: json['room_id'] is int ? json['room_id'] : int.parse(json['room_id'].toString()),
      name: json['name']?.toString() ?? '',
      capacity: json['capacity'] is int ? json['capacity'] : int.parse(json['capacity'].toString()),
      price: json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      currentPersonNumber: json['current_person_number'] is int
          ? json['current_person_number']
          : int.parse(json['current_person_number'].toString()),
      description: json['description'] as String?,
      status: json['status']?.toString() ?? 'UNKNOWN',
      areaId: json['area_id'] is int ? json['area_id'] : int.parse(json['area_id'].toString()),
      areaDetails: json['area_details'] != null ? AreaModel.fromJson(json['area_details'] as Map<String, dynamic>) : null,
    );
  }
}