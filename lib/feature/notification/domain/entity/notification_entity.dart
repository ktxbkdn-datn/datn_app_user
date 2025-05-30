import 'notification_media_entity.dart';
import 'notification_type_entity.dart';

class Notification {
  final int? notificationId;
  final String title;
  final String message;
  final String targetType;
  final String? createdAt;
  final int? recipientId; // Thêm recipientId
  final bool isDeleted;
  final String? deletedAt;
  final List<NotificationMedia>? media;
  final NotificationType? notificationType;
  final bool isRead; // Thêm isRead

  Notification({
    this.notificationId,
    required this.title,
    required this.message,
    required this.targetType,
    this.createdAt,
    this.recipientId,
    required this.isDeleted,
    this.deletedAt,
    this.media,
    this.notificationType,
    required this.isRead, // Yêu cầu isRead
  });

  Notification copyWith({
    int? notificationId,
    String? title,
    String? message,
    int? typeId,
    String? targetType,
    String? createdAt,
    int? recipientId, // Thêm vào copyWith
    bool? isDeleted,
    String? deletedAt,
    List<NotificationMedia>? media,
    NotificationType? notificationType,
    bool? isRead, // Thêm vào copyWith
  }) {
    return Notification(
      notificationId: notificationId ?? this.notificationId,
      title: title ?? this.title,
      message: message ?? this.message,
      targetType: targetType ?? this.targetType,
      createdAt: createdAt ?? this.createdAt,
      recipientId: recipientId ?? this.recipientId, // Thêm recipientId
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      media: media ?? this.media,
      notificationType: notificationType ?? this.notificationType,
      isRead: isRead ?? this.isRead, // Thêm isRead
    );
  }
}