import 'package:equatable/equatable.dart';
import '../../domain/entity/notification_media_entity.dart';

class NotificationMediaModel extends Equatable {
  final int mediaId;
  final int notificationId;
  final String mediaUrl;
  final String? altText;
  final String? uploadedAt;
  final bool isPrimary;
  final int sortOrder;
  final bool isDeleted;
  final String? deletedAt;
  final String fileType;
  final int? fileSize;

  NotificationMediaModel({
    required this.mediaId,
    required this.notificationId,
    required this.mediaUrl,
    this.altText,
    this.uploadedAt,
    required this.isPrimary,
    required this.sortOrder,
    required this.isDeleted,
    this.deletedAt,
    required this.fileType,
    this.fileSize,
  });

  factory NotificationMediaModel.fromJson(Map<String, dynamic> json) {
    return NotificationMediaModel(
      mediaId: json['media_id'] as int? ?? 0,
      notificationId: json['notification_id'] as int? ?? 0,
      mediaUrl: json['media_url'] as String? ?? '',
      altText: json['alt_text'] as String?,
      uploadedAt: json['uploaded_at'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
      isDeleted: json['is_deleted'] as bool? ?? false,
      deletedAt: json['deleted_at'] as String?,
      fileType: json['file_type'] as String? ?? 'image',
      fileSize: json['file_size'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'media_id': mediaId,
      'notification_id': notificationId,
      'media_url': mediaUrl,
      'alt_text': altText,
      'uploaded_at': uploadedAt,
      'is_primary': isPrimary,
      'sort_order': sortOrder,
      'is_deleted': isDeleted,
      'deleted_at': deletedAt,
      'file_type': fileType,
      'file_size': fileSize,
    };
  }

  NotificationMedia toEntity() {
    return NotificationMedia(
      mediaId: mediaId,
      notificationId: notificationId,
      mediaUrl: mediaUrl,
      altText: altText,
      uploadedAt: uploadedAt,
      isPrimary: isPrimary,
      sortOrder: sortOrder,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
      fileType: fileType,
      fileSize: fileSize,
    );
  }

  @override
  List<Object?> get props => [
    mediaId,
    notificationId,
    mediaUrl,
    altText,
    uploadedAt,
    isPrimary,
    sortOrder,
    isDeleted,
    deletedAt,
    fileType,
    fileSize,
  ];
}