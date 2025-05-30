import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entity/notification_type_entity.dart';

abstract class NotificationTypeRepository {
  Future<Either<Failure, List<NotificationType>>> getAllNotificationTypes({
    required int page,
    required int limit,
  });
}