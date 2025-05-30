// lib/src/features/report/domain/repositories/report_type_repository.dart

import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entity/report_type_entity.dart';

abstract class ReportTypeRepository {
  Future<Either<Failure, List<ReportTypeEntity>>> getAllReportTypes({
    required int page,
    required int limit,
  });
}