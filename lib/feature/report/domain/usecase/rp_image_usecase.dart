// lib/src/features/report/domain/usecases/report_image_usecases.dart
import 'package:dartz/dartz.dart';
import 'dart:io';

import '../../../../src/core/error/failures.dart';
import '../entity/report_image_entity.dart';
import '../repository/rp_image_repository.dart';

/// Use case to fetch images/videos for a report
class GetReportImages {
  final ReportImageRepository repository;

  GetReportImages(this.repository);

  Future<Either<Failure, List<ReportImageEntity>>> call(int reportId) async {
    return await repository.getReportImages(reportId);
  }
}

/// Use case to add images/videos to a report
class AddReportImages {
  final ReportImageRepository repository;

  AddReportImages(this.repository);

  Future<Either<Failure, List<ReportImageEntity>>> call({
    required int reportId,
    required List<File> files,
    String? altText,
  }) async {
    return await repository.addReportImages(
      reportId: reportId,
      files: files,
      altText: altText,
    );
  }
}