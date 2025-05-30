import 'package:dartz/dartz.dart';
import '../../../../src/core/error/failures.dart';
import '../../domain/entity/report_type_entity.dart';
import '../../domain/repository/rp_type_repository.dart';
import '../datasource/rp_type_datasource.dart';
import '../model/report_type.dart';

class ReportTypeRepositoryImpl implements ReportTypeRepository {
  final ReportTypeRemoteDataSource remoteDataSource;

  ReportTypeRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ReportTypeEntity>>> getAllReportTypes({
    required int page,
    required int limit,
  }) async {
    try {
      final reportTypeModels = await remoteDataSource.getAllReportTypes(
        page: page,
        limit: limit,
      );
      // Chuyển đổi từ List<ReportTypeModel> sang List<ReportTypeEntity>
      final reportTypes = reportTypeModels
          .map((model) => ReportTypeEntity(
        reportTypeId: model.reportTypeId,
        name: model.name,
      ))
          .toList();
      return Right(reportTypes);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}