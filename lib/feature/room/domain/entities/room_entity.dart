// lib/src/features/room/domain/entities/room_entity.dart
import 'area_entity.dart';

class RoomEntity {
  final int roomId;
  final String name;
  final int capacity;
  final double price;
  final int currentPersonNumber;
  final String? description;
  final String status;
  final int areaId;
  final AreaEntity? areaDetails;

  const RoomEntity({
    required this.roomId,
    required this.name,
    required this.capacity,
    required this.price,
    required this.currentPersonNumber,
    this.description,
    required this.status,
    required this.areaId,
    this.areaDetails,
  });

  // Chuyển đổi thành JSON
  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'name': name,
      'capacity': capacity,
      'price': price,
      'currentPersonNumber': currentPersonNumber,
      'description': description,
      'status': status,
      'areaId': areaId,
      'areaDetails': areaDetails?.toJson(),
    };
  }

  // Tạo đối tượng từ JSON
  factory RoomEntity.fromJson(Map<String, dynamic> json) {
    return RoomEntity(
      roomId: json['roomId'] as int,
      name: json['name'] as String,
      capacity: json['capacity'] as int,
      price: (json['price'] as num).toDouble(),
      currentPersonNumber: json['currentPersonNumber'] as int,
      description: json['description'] as String?,
      status: json['status'] as String,
      areaId: json['areaId'] as int,
      areaDetails: json['areaDetails'] != null
          ? AreaEntity.fromJson(json['areaDetails'] as Map<String, dynamic>)
          : null,
    );
  }
}