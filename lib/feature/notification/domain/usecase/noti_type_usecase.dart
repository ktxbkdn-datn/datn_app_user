import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';

import '../entity/notification_type_entity.dart';

import '../repository/noti_type_repository.dart';

class GetAllNotificationTypes {
  final NotificationTypeRepository repository;

  GetAllNotificationTypes(this.repository);

  Future<Either<Failure, List<NotificationType>>> call({
    required int page,
    required int limit,
  }) async {
    return await repository.getAllNotificationTypes(
      page: page,
      limit: limit,
    );
  }
}