import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entity/notification_entity.dart';
import '../repository/noti_repository.dart';

class GetUserNotifications {
  final NotificationRepository repository;

  GetUserNotifications(this.repository);

  Future<Either<Failure, List<Notification>>> call({
    required int page,
    required int limit,
    bool? isRead,
  }) async {
    return await repository.getUserNotifications(
      page: page,
      limit: limit,
      isRead: isRead,
    );
  }
}

class GetPublicNotifications {
  final NotificationRepository repository;

  GetPublicNotifications(this.repository);

  Future<Either<Failure, List<Notification>>> call({
    required int page,
    required int limit,
  }) async {
    return await repository.getPublicNotifications(
      page: page,
      limit: limit,
    );
  }
}