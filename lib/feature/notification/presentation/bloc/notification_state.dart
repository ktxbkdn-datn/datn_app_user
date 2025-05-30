import 'package:equatable/equatable.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../domain/entity/noti_recipient.dart';
import '../../domain/entity/notification_entity.dart';
import '../../domain/entity/notification_media_entity.dart';
import '../../domain/entity/notification_type_entity.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class UserNotificationsLoaded extends NotificationState {
  final List<Notification> notifications;

  const UserNotificationsLoaded({required this.notifications});

  @override
  List<Object> get props => [notifications];
}

class PublicNotificationsLoaded extends NotificationState {
  final List<Notification> notifications;

  const PublicNotificationsLoaded({required this.notifications});

  @override
  List<Object> get props => [notifications];
}

class NotificationMarkedAsRead extends NotificationState {
  final NotificationRecipient recipient;

  const NotificationMarkedAsRead({required this.recipient});

  @override
  List<Object> get props => [recipient];
}

class AllNotificationsMarkedAsRead extends NotificationState {
  const AllNotificationsMarkedAsRead();

  @override
  List<Object> get props => [];
}

class UnreadNotificationsCountLoaded extends NotificationState {
  final int count;

  const UnreadNotificationsCountLoaded({required this.count});

  @override
  List<Object> get props => [count];
}

class NotificationTypesLoaded extends NotificationState {
  final List<NotificationType> types;

  const NotificationTypesLoaded({required this.types});

  @override
  List<Object> get props => [types];
}

class NotificationMediaLoaded extends NotificationState {
  final List<NotificationMedia> media;

  const NotificationMediaLoaded({required this.media});

  @override
  List<Object> get props => [media];
}

class NotificationDeleted extends NotificationState {
  const NotificationDeleted();

  @override
  List<Object> get props => [];
}

class NotificationError extends NotificationState {
  final String message;

  const NotificationError({required this.message});

  @override
  List<Object> get props => [message];
}

// Thêm state để xử lý thông báo đẩy mới
class NewFcmNotification extends NotificationState {
  final RemoteMessage message;

  const NewFcmNotification(this.message);

  @override
  List<Object> get props => [message];
}