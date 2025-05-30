import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entity/service_entities.dart';
import '../repository/service_repository.dart';

class GetServices {
  final ServiceRepository repository;

  GetServices(this.repository);

  Future<Either<Failure, List<Service>>> call({
    int page = 1,
    int limit = 10,
  }) async {
    return await repository.getServices(
      page: page,
      limit: limit,
    );
  }
}