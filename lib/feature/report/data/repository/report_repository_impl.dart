import 'package:dartz/dartz.dart';
import 'dart:io';
import 'dart:typed_data'; // Thêm import rõ ràng cho Uint8List
import '../../../../src/core/error/failures.dart';
import '../../domain/entity/report_entity.dart';
import '../../domain/repository/report_repository.dart';
import '../datasource/report_datasource.dart';


class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource remoteDataSource;

  ReportRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ReportEntity>>> getMyReports({
    required int page,
    required int limit,
    String? status,
  }) async {
    try {
      final reports = await remoteDataSource.getMyReports(
        page: page,
        limit: limit,
        status: status,
      );
      return Right(reports);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportEntity>> getReportById(int reportId) async {
    try {
      final report = await remoteDataSource.getReportById(reportId);
      return Right(report);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ReportEntity>> createReport({
    required String title,
    required String content,
    int? reportTypeId,
    List<File>? images,
    List<Uint8List>? bytes,
  }) async {
    try {
      final report = await remoteDataSource.createReport(
        title: title,
        content: content,
        reportTypeId: reportTypeId,
        images: images,
        bytes: bytes,
      );
      return Right(report);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}