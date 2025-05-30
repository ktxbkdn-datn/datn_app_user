import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class GetMyReportsEvent extends ReportEvent {
  final int page;
  final int limit;
  final String? status;

  const GetMyReportsEvent({this.page = 1, this.limit = 10, this.status});

  @override
  List<Object?> get props => [page, limit, status];
}

class GetReportByIdEvent extends ReportEvent {
  final int reportId;

  const GetReportByIdEvent(this.reportId);

  @override
  List<Object> get props => [reportId];
}

class CreateReportEvent extends ReportEvent {
  final String title;
  final String content;
  final int? reportTypeId;
  final List<File>? images; // Dùng cho di động
  final List<Uint8List>? bytes; // Dùng cho web

  const CreateReportEvent({
    required this.title,
    required this.content,
    this.reportTypeId,
    this.images,
    this.bytes,
  });

  @override
  List<Object?> get props => [title, content, reportTypeId, images, bytes];
}

class GetReportImagesEvent extends ReportEvent {
  final int reportId;

  const GetReportImagesEvent(this.reportId);

  @override
  List<Object> get props => [reportId];
}

class GetReportTypesEvent extends ReportEvent {
  final int page;
  final int limit;

  const GetReportTypesEvent({this.page = 1, this.limit = 10});

  @override
  List<Object> get props => [page, limit];
}

class ResetReportStateEvent extends ReportEvent {
  const ResetReportStateEvent();

  @override
  List<Object?> get props => [];
}