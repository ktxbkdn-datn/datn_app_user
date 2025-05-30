import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../../domain/entity/noti_recipient.dart';
import '../../domain/repository/noti_recipient_repository.dart';
import '../datasource/noti_recipient_datasource.dart';

class NotificationRecipientRepositoryImpl implements NotificationRecipientRepository {
  final NotificationRecipientRemoteDataSource remoteDataSource;

  NotificationRecipientRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, NotificationRecipient>> markNotificationAsRead(int notificationId) async {
    try {
      final recipientModel = await remoteDataSource.markNotificationAsRead(notificationId);
      return Right(recipientModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllNotificationsAsRead() async {
    try {
      await remoteDataSource.markAllNotificationsAsRead();
      return Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadNotificationsCount() async {
    try {
      final count = await remoteDataSource.getUnreadNotificationsCount();
      return Right(count);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification(int notificationId) async {
    try {
      await remoteDataSource.deleteNotification(notificationId);
      return Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}