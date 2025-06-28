import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../../domain/entity/notification_entity.dart';
import 'noti_type_model.dart';
import 'notification_media_model.dart';

class NotificationModel extends Equatable {
  final int? notificationId;
  final String title;
  final String message;
  final String targetType;
  final String? createdAt;
  final int? recipientId;
  final bool isDeleted;
  final String? deletedAt;
  final List<NotificationMediaModel>? media;
  final NotificationTypeModel? notificationType;
  final bool isRead;

  const NotificationModel({
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
    required this.isRead,
  });  factory NotificationModel.fromJson(Map<String, dynamic> json) {    
    print('Parsing NotificationModel: $json');
    // Fix for API inconsistency - personal_notifications with isRead=true are actually read
    // So in our model, they should also be marked as isRead=true
    final dynamic isReadRaw = json['is_read'] ?? json['isRead'];
    bool isReadValue = false;
    
    if (isReadRaw is bool) {
      isReadValue = isReadRaw;
    } else if (isReadRaw is int) {
      isReadValue = isReadRaw == 1;
    } else if (isReadRaw is String) {
      isReadValue = isReadRaw == '1' || isReadRaw.toLowerCase() == 'true';
    }
    
    // Debug log for isRead parsing
    print('DEBUG: Parsed isRead from $isReadRaw to $isReadValue for notification ${json['id']}, title: "${json['title']}"');

    return NotificationModel(
      notificationId: json['id'] as int?,
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      targetType: json['target_type'] as String? ?? '',
      createdAt: json['created_at'] as String?,
      recipientId: json['recipientId'] as int?,
      isDeleted: json['is_deleted'] as bool? ?? false,
      deletedAt: json['deleted_at'] as String?,
      media: json['media'] != null && (json['media'] as List).isNotEmpty
          ? (json['media'] as List)
          .map((item) => NotificationMediaModel.fromJson(item as Map<String, dynamic>))
          .toList()
          : [],
      notificationType: json['notification_type'] != null
          ? NotificationTypeModel.fromJson(json['notification_type'] as Map<String, dynamic>)
          : null,
      isRead: isReadValue,
    );
  }

  // Thêm phương thức parse từ FCM message
  factory NotificationModel.fromFcmMessage(RemoteMessage message) {
    return NotificationModel(
      notificationId: int.tryParse(message.data['notification_id'] ?? ''),
      title: message.notification?.title ?? '',
      message: message.notification?.body ?? '',
      targetType: message.data['target_type'] ?? '',
      createdAt: DateTime.now().toIso8601String(),
      recipientId: int.tryParse(message.data['notification_id'] ?? ''),
      isDeleted: false,
      deletedAt: null,
      media: [],
      notificationType: null,
      isRead: false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': notificationId,
      'title': title,
      'message': message,
      'target_type': targetType,
      'created_at': createdAt,
      'recipientId': recipientId,
      'is_deleted': isDeleted,
      'deleted_at': deletedAt,
      'media': media?.map((item) => item.toJson()).toList(),
      'notification_type': notificationType?.toJson(),
      'isRead': isRead,
    };
  }

  Notification toEntity() {
    return Notification(
      notificationId: notificationId,
      title: title,
      message: message,
      targetType: targetType,
      createdAt: createdAt,
      recipientId: recipientId,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
      media: media?.map((item) => item.toEntity()).toList(),
      notificationType: notificationType?.toEntity(),
      isRead: isRead,
    );
  }

  @override
  List<Object?> get props => [
    notificationId,
    title,
    message,
    targetType,
    createdAt,
    recipientId,
    isDeleted,
    deletedAt,
    media,
    notificationType,
    isRead,
  ];
}