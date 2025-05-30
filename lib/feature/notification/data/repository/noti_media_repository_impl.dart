import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';

import '../../domain/entity/notification_media_entity.dart';

import '../../domain/repository/noti_media_repository.dart';
import '../datasource/noti_media_datasource.dart';


class NotificationMediaRepositoryImpl implements NotificationMediaRepository {
  final NotificationMediaRemoteDataSource remoteDataSource;

  NotificationMediaRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<NotificationMedia>>> getNotificationMedia({
    required int notificationId,
    String? fileType,
  }) async {
    try {
      final mediaModels = await remoteDataSource.getNotificationMedia(
        notificationId: notificationId,
        fileType: fileType,
      );
      final media = mediaModels.map((model) => model.toEntity()).toList();
      return Right(media);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}