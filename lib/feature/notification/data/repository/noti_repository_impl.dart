import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../../domain/entity/notification_entity.dart';
import '../../domain/repository/noti_repository.dart';
import '../datasource/noti_datasource.dart';


class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Notification>>> getUserNotifications({
    required int page,
    required int limit,
    bool? isRead,
  }) async {
    try {
      final notificationModels = await remoteDataSource.getUserNotifications(
        page: page,
        limit: limit,
        isRead: isRead,
      );
      final notifications = notificationModels.map((model) => model.toEntity()).toList();
      return Right(notifications);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Notification>>> getPublicNotifications({
    required int page,
    required int limit,
  }) async {
    try {
      final notificationModels = await remoteDataSource.getPublicNotifications(
        page: page,
        limit: limit,
      );
      final notifications = notificationModels.map((model) => model.toEntity()).toList();
      return Right(notifications);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}