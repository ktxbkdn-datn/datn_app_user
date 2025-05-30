class RoomImageEntity {
  final int imageId;
  final int? roomId;
  final String imageUrl;
  final String? altText;
  final bool isPrimary;
  final int sortOrder;
  final String? uploadedAt;
  final bool isDeleted;
  final String? deletedAt;

  const RoomImageEntity({
    required this.imageId,
    this.roomId,
    required this.imageUrl,
    this.altText,
    required this.isPrimary,
    required this.sortOrder,
    this.uploadedAt,
    required this.isDeleted,
    this.deletedAt,
  });

  // Chuyển đổi thành JSON
  Map<String, dynamic> toJson() {
    return {
      'imageId': imageId,
      'roomId': roomId,
      'imageUrl': imageUrl,
      'altText': altText,
      'isPrimary': isPrimary,
      'sortOrder': sortOrder,
      'uploadedAt': uploadedAt,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt,
    };
  }

  // Tạo đối tượng từ JSON
  factory RoomImageEntity.fromJson(Map<String, dynamic> json) {
    return RoomImageEntity(
      imageId: json['imageId'] as int,
      roomId: json['roomId'] as int?,
      imageUrl: json['imageUrl'] as String,
      altText: json['altText'] as String?,
      isPrimary: json['isPrimary'] as bool,
      sortOrder: json['sortOrder'] as int,
      uploadedAt: json['uploadedAt'] as String?,
      isDeleted: json['isDeleted'] as bool,
      deletedAt: json['deletedAt'] as String?,
    );
  }
}