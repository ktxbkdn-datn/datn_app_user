import 'package:equatable/equatable.dart';
import 'notification_entity.dart';

class NotificationRecipient extends Equatable {
  final int id;
  final int notificationId;
  final int userId;
  final bool isRead;
  final String? readAt;
  final bool isDeleted; // Thêm isDeleted
  final String? deletedAt; // Thêm deletedAt

  const NotificationRecipient({
    required this.id,
    required this.notificationId,
    required this.userId,
    required this.isRead,
    this.readAt,
    required this.isDeleted,
    this.deletedAt,
  });

  NotificationRecipient copyWith({
    int? id,
    int? notificationId,
    int? userId,
    bool? isRead,
    String? readAt,
    bool? isDeleted,
    String? deletedAt,
  }) {
    return NotificationRecipient(
      id: id ?? this.id,
      notificationId: notificationId ?? this.notificationId,
      userId: userId ?? this.userId,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  List<Object?> get props => [id, notificationId, userId, isRead, readAt, isDeleted, deletedAt];
}