import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entity/noti_recipient.dart';

abstract class NotificationRecipientRepository {
  Future<Either<Failure, NotificationRecipient>> markNotificationAsRead(int notificationId);
  Future<Either<Failure, void>> markAllNotificationsAsRead();
  Future<Either<Failure, int>> getUnreadNotificationsCount();
  Future<Either<Failure, void>> deleteNotification(int notificationId); // Thêm phương thức mới
}