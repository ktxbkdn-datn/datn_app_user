
import 'package:dartz/dartz.dart';
import 'dart:io';

import '../../../../src/core/error/failures.dart';
import '../entity/report_image_entity.dart';


abstract class ReportImageRepository {
  Future<Either<Failure, List<ReportImageEntity>>> getReportImages(int reportId);

  Future<Either<Failure, List<ReportImageEntity>>> addReportImages({
    required int reportId,
    required List<File> files,
    String? altText,
  });
}