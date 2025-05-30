import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../../domain/entity/service_entities.dart';
import '../../domain/repository/service_repository.dart';
import '../datasource/service_datasource.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceRemoteDataSource remoteDataSource;

  ServiceRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<Service>>> getServices({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final result = await remoteDataSource.getServices(
        page: page,
        limit: limit,
      );
      return result.map((models) => models.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(ServerFailure('Lỗi không xác định: $e'));
    }
  }
}