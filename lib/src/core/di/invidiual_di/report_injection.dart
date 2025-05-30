import 'package:get_it/get_it.dart';
import '../../../../../src/core/network/api_client.dart';
import '../../../../feature/report/data/datasource/report_datasource.dart';
import '../../../../feature/report/data/datasource/rp_image_datasource.dart';
import '../../../../feature/report/data/datasource/rp_type_datasource.dart';
import '../../../../feature/report/data/repository/report_repository_impl.dart' hide ReportRemoteDataSource;
import '../../../../feature/report/data/repository/rp_image_repository_impl.dart';
import '../../../../feature/report/data/repository/rp_type_repository_impl.dart';
import '../../../../feature/report/domain/repository/report_repository.dart';
import '../../../../feature/report/domain/repository/rp_image_repository.dart';
import '../../../../feature/report/domain/repository/rp_type_repository.dart';
import '../../../../feature/report/presentation/bloc/report_bloc.dart';

final getIt = GetIt.instance;

void registerReportDependencies() {
  // Đăng ký Data Source
  getIt.registerSingleton<ReportRemoteDataSource>(
    ReportRemoteDataSourceImpl(getIt<ApiService>()),
  );

  getIt.registerSingleton<ReportImageRemoteDataSource>(
    ReportImageRemoteDataSourceImpl(getIt<ApiService>()),
  );

  getIt.registerSingleton<ReportTypeRemoteDataSource>(
    ReportTypeRemoteDataSourceImpl(getIt<ApiService>()),
  );

  // Đăng ký Repository
  getIt.registerSingleton<ReportRepository>(
    ReportRepositoryImpl(getIt<ReportRemoteDataSource>()),
  );

  getIt.registerSingleton<ReportImageRepository>(
    ReportImageRepositoryImpl(getIt<ReportImageRemoteDataSource>()),
  );

  getIt.registerSingleton<ReportTypeRepository>(
    ReportTypeRepositoryImpl(getIt<ReportTypeRemoteDataSource>()),
  );

  // Đăng ký BLoC
  getIt.registerFactory<ReportBloc>(() => ReportBloc(
    reportRepository: getIt<ReportRepository>(),
    reportImageRepository: getIt<ReportImageRepository>(),
    reportTypeRepository: getIt<ReportTypeRepository>(),
  ));
}