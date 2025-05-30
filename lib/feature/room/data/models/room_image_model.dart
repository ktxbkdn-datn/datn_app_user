// lib/src/features/room/data/models/room_image_model.dart
import '../../domain/entities/room_image_entity.dart';

class RoomImageModel extends RoomImageEntity {
  RoomImageModel({
    required int imageId,
    int? roomId,
    required String imageUrl,
    String? altText,
    required bool isPrimary,
    required int sortOrder,
    String? uploadedAt,
    required bool isDeleted,
    String? deletedAt,
  }) : super(
    imageId: imageId,
    roomId: roomId,
    imageUrl: imageUrl,
    altText: altText,
    isPrimary: isPrimary,
    sortOrder: sortOrder,
    uploadedAt: uploadedAt,
    isDeleted: isDeleted,
    deletedAt: deletedAt,
  );

  factory RoomImageModel.fromJson(Map<String, dynamic> json) {
    return RoomImageModel(
      imageId: json['image_id'] as int,
      roomId: json['room_id'] as int?,
      imageUrl: json['image_url'] as String,
      altText: json['alt_text'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
      uploadedAt: json['uploaded_at'] as String?,
      isDeleted: json['is_deleted'] as bool? ?? false,
      deletedAt: json['deleted_at'] as String?,
    );
  }
}