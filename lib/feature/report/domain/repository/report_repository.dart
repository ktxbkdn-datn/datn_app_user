import 'package:dartz/dartz.dart';
import 'dart:io';
import 'dart:typed_data'; // Đảm bảo Uint8List từ dart:typed_data
import '../../../../src/core/error/failures.dart';

import '../entity/report_entity.dart';

abstract class ReportRepository {
  Future<Either<Failure, List<ReportEntity>>> getMyReports({
    required int page,
    required int limit,
    String? status,
  });

  Future<Either<Failure, ReportEntity>> getReportById(int reportId);

  Future<Either<Failure, ReportEntity>> createReport({
    required String title,
    required String content,
    int? reportTypeId,
    List<File>? images,
    List<Uint8List>? bytes,
  });
}