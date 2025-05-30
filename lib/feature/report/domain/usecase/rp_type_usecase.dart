// lib/src/features/report/domain/usecases/report_type_usecases.dart
import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../entity/report_type_entity.dart';
import '../repository/rp_type_repository.dart';


/// Use case to fetch all report types
class GetAllReportTypes {
  final ReportTypeRepository repository;

  GetAllReportTypes(this.repository);

  Future<Either<Failure, List<ReportTypeEntity>>> call({
    int page = 1,
    int limit = 10,
  }) async {
    return await repository.getAllReportTypes(page: page, limit: limit);
  }
}