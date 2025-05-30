import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../../domain/entity/service_entities.dart';

abstract class ServiceRepository {
  Future<Either<Failure, List<Service>>> getServices({
    int page = 1,
    int limit = 10,
  });
}