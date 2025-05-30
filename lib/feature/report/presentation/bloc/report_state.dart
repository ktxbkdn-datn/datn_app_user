import 'package:equatable/equatable.dart';
import '../../domain/entity/report_entity.dart';
import '../../domain/entity/report_image_entity.dart';
import '../../domain/entity/report_type_entity.dart'; // Thay import

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final List<ReportEntity> reports;
  final ReportEntity? selectedReport;
  final Map<int, List<ReportImageEntity>> reportImages;
  final List<ReportTypeEntity> reportTypes; // Sửa từ ReportTypeModel thành ReportTypeEntity
  final int currentReportsPage;
  final int totalReportsPages;
  final int currentReportTypesPage;
  final int totalReportTypesPages;

  const ReportLoaded({
    this.reports = const [],
    this.selectedReport,
    this.reportImages = const {},
    this.reportTypes = const [],
    this.currentReportsPage = 1,
    this.totalReportsPages = 1,
    this.currentReportTypesPage = 1,
    this.totalReportTypesPages = 1,
  });

  ReportLoaded copyWith({
    List<ReportEntity>? reports,
    ReportEntity? selectedReport,
    Map<int, List<ReportImageEntity>>? reportImages,
    List<ReportTypeEntity>? reportTypes, // Sửa kiểu
    int? currentReportsPage,
    int? totalReportsPages,
    int? currentReportTypesPage,
    int? totalReportTypesPages,
  }) {
    return ReportLoaded(
      reports: reports ?? this.reports,
      selectedReport: selectedReport ?? this.selectedReport,
      reportImages: reportImages ?? this.reportImages,
      reportTypes: reportTypes ?? this.reportTypes,
      currentReportsPage: currentReportsPage ?? this.currentReportsPage,
      totalReportsPages: totalReportsPages ?? this.totalReportsPages,
      currentReportTypesPage: currentReportTypesPage ?? this.currentReportTypesPage,
      totalReportTypesPages: totalReportTypesPages ?? this.totalReportTypesPages,
    );
  }

  @override
  List<Object?> get props => [
    reports,
    selectedReport,
    reportImages,
    reportTypes,
    currentReportsPage,
    totalReportsPages,
    currentReportTypesPage,
    totalReportTypesPages,
  ];
}

class ReportError extends ReportState {
  final String message;

  const ReportError({required this.message});

  @override
  List<Object> get props => [message];
}