import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';

import '../entity/notification_entity.dart';

abstract class NotificationRepository {
  Future<Either<Failure, (List<Notification>, int)>> getUserNotifications({
    required int page,
    required int limit,
    bool? isRead,
  });

  Future<Either<Failure, List<Notification>>> getPublicNotifications({
    required int page,
    required int limit,
  });
}