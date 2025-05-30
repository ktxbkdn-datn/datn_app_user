// lib/src/features/report/data/repositories/report_image_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'dart:io';

import '../../../../src/core/error/failures.dart';
import '../../domain/entity/report_image_entity.dart';
import '../../domain/repository/rp_image_repository.dart';
import '../datasource/rp_image_datasource.dart';


class ReportImageRepositoryImpl implements ReportImageRepository {
  final ReportImageRemoteDataSource remoteDataSource;

  ReportImageRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<ReportImageEntity>>> getReportImages(int reportId) async {
    try {
      final remoteImages = await remoteDataSource.getReportImages(reportId);
      return Right(remoteImages);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ReportImageEntity>>> addReportImages({
    required int reportId,
    required List<File> files,
    String? altText,
  }) async {
    try {
      final images = await remoteDataSource.addReportImages(
        reportId: reportId,
        files: files,
        altText: altText,
      );
      return Right(images);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}