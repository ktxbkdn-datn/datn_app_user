import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../entity/notification_media_entity.dart';

abstract class NotificationMediaRepository {
  // Lấy danh sách media của một thông báo (nếu có API public cho user)
  Future<Either<Failure, List<NotificationMedia>>> getNotificationMedia({
    required int notificationId,
    String? fileType,
  });
}