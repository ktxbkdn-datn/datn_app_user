import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repository/report_repository.dart';
import '../../domain/repository/rp_image_repository.dart';
import '../../domain/repository/rp_type_repository.dart'; // Thêm import
import '../../domain/entity/report_entity.dart';
import '../../domain/entity/report_image_entity.dart';
import '../bloc/report_event.dart';
import '../bloc/report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository reportRepository;
  final ReportImageRepository reportImageRepository;
  final ReportTypeRepository reportTypeRepository; // Thêm dependency

  ReportBloc({
    required this.reportRepository,
    required this.reportImageRepository,
    required this.reportTypeRepository, // Thêm vào constructor
  }) : super(ReportInitial()) {
    on<GetMyReportsEvent>(_onGetMyReports);
    on<GetReportTypesEvent>(_onGetReportTypes);
    on<CreateReportEvent>(_onCreateReport);
    on<GetReportByIdEvent>(_onGetReportById);
    on<GetReportImagesEvent>(_onGetReportImages);
    on<ResetReportStateEvent>(_onResetReportState);
  }

  Future<void> _onGetMyReports(GetMyReportsEvent event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    final result = await reportRepository.getMyReports(
      page: event.page,
      limit: event.limit,
      status: event.status,
    );
    emit(result.fold(
          (failure) => ReportError(message: failure.message),
          (reports) {
        if (state is ReportLoaded) {
          final currentState = state as ReportLoaded;
          return currentState.copyWith(
            reports: reports,
            currentReportsPage: event.page,
            totalReportsPages: (reports.length / event.limit).ceil(),
          );
        } else {
          return ReportLoaded(
            reports: reports,
            currentReportsPage: event.page,
            totalReportsPages: (reports.length / event.limit).ceil(),
          );
        }
      },
    ));
  }

  Future<void> _onGetReportTypes(GetReportTypesEvent event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    final result = await reportTypeRepository.getAllReportTypes( // Sửa để gọi từ reportTypeRepository
      page: event.page,
      limit: event.limit,
    );
    emit(result.fold(
          (failure) => ReportError(message: failure.message),
          (reportTypes) {
        if (state is ReportLoaded) {
          final currentState = state as ReportLoaded;
          return currentState.copyWith(
            reportTypes: reportTypes,
            currentReportTypesPage: event.page,
            totalReportTypesPages: (reportTypes.length / event.limit).ceil(),
          );
        } else {
          return ReportLoaded(
            reportTypes: reportTypes,
            currentReportTypesPage: event.page,
            totalReportTypesPages: (reportTypes.length / event.limit).ceil(),
          );
        }
      },
    ));
  }

  Future<void> _onCreateReport(CreateReportEvent event, Emitter<ReportState> emit) async {
    emit(ReportLoading());
    final result = await reportRepository.createReport(
      title: event.title,
      content: event.content,
      reportTypeId: event.reportTypeId,
      images: event.images,
      bytes: event.bytes,
    );
    emit(result.fold(
          (failure) => ReportError(message: failure.message),
          (report) {
        if (state is ReportLoaded) {
          final currentState = state as ReportLoaded;
          return currentState.copyWith(selectedReport: report);
        } else {
          return ReportLoaded(selectedReport: report);
        }
      },
    ));
  }

  Future<void> _onGetReportById(GetReportByIdEvent event, Emitter<ReportState> emit) async {
    // Không emit ReportLoading để tránh làm mất trạng thái hiện tại
    final result = await reportRepository.getReportById(event.reportId);
    emit(result.fold(
          (failure) => ReportError(message: failure.message),
          (report) {
        if (state is ReportLoaded) {
          final currentState = state as ReportLoaded;
          return currentState.copyWith(selectedReport: report);
        } else {
          return ReportLoaded(selectedReport: report);
        }
      },
    ));
  }

  Future<void> _onGetReportImages(GetReportImagesEvent event, Emitter<ReportState> emit) async {
    // Không emit ReportLoading để tránh làm mất trạng thái hiện tại
    final result = await reportImageRepository.getReportImages(event.reportId);
    emit(result.fold(
          (failure) => ReportError(message: '${failure.message}: Không tìm thấy media cho báo cáo này'),
          (images) {
        if (state is ReportLoaded) {
          final currentState = state as ReportLoaded;
          final updatedImages = Map<int, List<ReportImageEntity>>.from(currentState.reportImages);
          updatedImages[event.reportId] = images;
          return currentState.copyWith(reportImages: updatedImages);
        } else {
          return ReportLoaded(reportImages: {event.reportId: images});
        }
      },
    ));
  }

  Future<void> _onResetReportState(ResetReportStateEvent event, Emitter<ReportState> emit) async {
    emit(ReportInitial());
  }
}