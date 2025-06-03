import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

class FetchUserNotificationsEvent extends NotificationEvent {
  final int page;
  final int limit;
  final bool? isRead;

  const FetchUserNotificationsEvent({
    this.page = 1,
    this.limit = 10,
    this.isRead,
  });

  @override
  List<Object?> get props => [page, limit, isRead];
}

class FetchPublicNotificationsEvent extends NotificationEvent {
  final int page;
  final int limit;

  const FetchPublicNotificationsEvent({
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [page, limit];
}

class MarkNotificationAsReadEvent extends NotificationEvent {
  final int notificationId;

  const MarkNotificationAsReadEvent({
    required this.notificationId,
  });

  @override
  List<Object?> get props => [notificationId];
}

class MarkAllNotificationsAsReadEvent extends NotificationEvent {
  const MarkAllNotificationsAsReadEvent();

  @override
  List<Object?> get props => [];
}

class FetchUnreadNotificationsCountEvent extends NotificationEvent {
  const FetchUnreadNotificationsCountEvent();

  @override
  List<Object?> get props => [];
}

class FetchNotificationTypesEvent extends NotificationEvent {
  final int page;
  final int limit;

  const FetchNotificationTypesEvent({
    this.page = 1,
    this.limit = 10,
  });

  @override
  List<Object?> get props => [page, limit];
}

class FetchNotificationMediaEvent extends NotificationEvent {
  final int notificationId;
  final String? fileType;

  const FetchNotificationMediaEvent({
    required this.notificationId,
    this.fileType,
  });

  @override
  List<Object?> get props => [notificationId, fileType];
}

class DeleteNotificationEvent extends NotificationEvent {
  final int notificationId;

  const DeleteNotificationEvent({
    required this.notificationId,
  });

  @override
  List<Object?> get props => [notificationId];
}

class NewFcmNotificationReceived extends NotificationEvent {
  final RemoteMessage message;

  const NewFcmNotificationReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class ClearCacheEvent extends NotificationEvent {
  const ClearCacheEvent();

  @override
  List<Object?> get props => [];
}