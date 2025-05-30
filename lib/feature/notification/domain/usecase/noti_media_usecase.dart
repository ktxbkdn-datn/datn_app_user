import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';

import '../entity/notification_media_entity.dart';

import '../repository/noti_media_repository.dart';

class GetNotificationMedia {
  final NotificationMediaRepository repository;

  GetNotificationMedia(this.repository);

  Future<Either<Failure, List<NotificationMedia>>> call({
    required int notificationId,
    String? fileType,
  }) async {
    return await repository.getNotificationMedia(
      notificationId: notificationId,
      fileType: fileType,
    );
  }
}