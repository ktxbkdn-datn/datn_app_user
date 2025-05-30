import 'package:dartz/dartz.dart';
import 'dart:io';
import 'dart:typed_data'; // Thêm import rõ ràng cho Uint8List
import '../../../../src/core/error/failures.dart';
import '../entity/report_entity.dart';
import '../repository/report_repository.dart';

/// Use case to create a new report
class CreateReport {
  final ReportRepository repository;

  CreateReport(this.repository);

  Future<Either<Failure, ReportEntity>> call({
    required String title,
    required String content,
    int? reportTypeId,
    List<File>? images,
    List<Uint8List>? bytes, // Thêm tham số bytes cho web
  }) async {
    return await repository.createReport(
      title: title,
      content: content,
      reportTypeId: reportTypeId,
      images: images,
      bytes: bytes,
    );
  }
}

class GetReportById {
  final ReportRepository repository;

  GetReportById(this.repository);

  Future<Either<Failure, ReportEntity>> call(int reportId) async {
    return await repository.getReportById(reportId);
  }
}

class GetMyReports {
  final ReportRepository repository;

  GetMyReports(this.repository);

  Future<Either<Failure, List<ReportEntity>>> call({
    int page = 1,
    int limit = 10,
    String? status,
  }) async {
    return await repository.getMyReports(page: page, limit: limit, status: status);
  }
}