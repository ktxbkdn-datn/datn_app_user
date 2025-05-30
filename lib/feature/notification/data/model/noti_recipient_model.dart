import 'package:equatable/equatable.dart';
import '../../domain/entity/noti_recipient.dart';

class NotificationRecipientModel extends Equatable {
  final int id;
  final int notificationId;
  final int userId;
  final bool isRead;
  final String? readAt;
  final bool isDeleted; // Thêm isDeleted
  final String? deletedAt; // Thêm deletedAt

  const NotificationRecipientModel({
    required this.id,
    required this.notificationId,
    required this.userId,
    required this.isRead,
    this.readAt,
    required this.isDeleted,
    this.deletedAt,
  });

  factory NotificationRecipientModel.fromJson(Map<String, dynamic> json) {
    return NotificationRecipientModel(
      id: json['id'] as int? ?? 0,
      notificationId: json['notification_id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      isRead: json['is_read'] as bool? ?? false,
      readAt: json['read_at'] as String?,
      isDeleted: json['is_deleted'] as bool? ?? false, // Parse isDeleted
      deletedAt: json['deleted_at'] as String?, // Parse deletedAt
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_id': notificationId,
      'user_id': userId,
      'is_read': isRead,
      'read_at': readAt,
      'is_deleted': isDeleted,
      'deleted_at': deletedAt,
    };
  }

  NotificationRecipient toEntity() {
    return NotificationRecipient(
      id: id,
      notificationId: notificationId,
      userId: userId,
      isRead: isRead,
      readAt: readAt,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
    );
  }

  @override
  List<Object?> get props => [id, notificationId, userId, isRead, readAt, isDeleted, deletedAt];
}