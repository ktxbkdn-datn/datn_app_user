import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entity/noti_recipient.dart';
import '../repository/noti_recipient_repository.dart';

class MarkNotificationAsRead {
  final NotificationRecipientRepository repository;

  MarkNotificationAsRead(this.repository);

  Future<Either<Failure, NotificationRecipient>> call(int notificationId) async {
    return await repository.markNotificationAsRead(notificationId);
  }
}

class MarkAllNotificationsAsRead {
  final NotificationRecipientRepository repository;

  MarkAllNotificationsAsRead(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.markAllNotificationsAsRead();
  }
}

class GetUnreadNotificationsCount {
  final NotificationRecipientRepository repository;

  GetUnreadNotificationsCount(this.repository);

  Future<Either<Failure, int>> call() async {
    return await repository.getUnreadNotificationsCount();
  }
}

class DeleteNotification {
  final NotificationRecipientRepository repository;

  DeleteNotification(this.repository);

  Future<Either<Failure, void>> call(int notificationId) async {
    return await repository.deleteNotification(notificationId);
  }
}