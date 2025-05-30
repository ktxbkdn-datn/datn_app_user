import 'package:dartz/dartz.dart';

import '../../../../src/core/error/failures.dart';
import '../../domain/entity/notification_type_entity.dart';
import '../../domain/repository/noti_type_repository.dart';
import '../datasource/noti_type_datasource.dart';



class NotificationTypeRepositoryImpl implements NotificationTypeRepository {
  final NotificationTypeRemoteDataSource remoteDataSource;

  NotificationTypeRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<NotificationType>>> getAllNotificationTypes({
    required int page,
    required int limit,
  }) async {
    try {
      final typeModels = await remoteDataSource.getAllNotificationTypes(
        page: page,
        limit: limit,
      );
      final types = typeModels.map((model) => model.toEntity()).toList();
      return Right(types);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}