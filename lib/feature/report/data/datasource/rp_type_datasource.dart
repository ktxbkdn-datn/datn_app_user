// lib/src/features/report/data/datasources/report_type_remote_data_source.dart
import '../../../../src/core/error/failures.dart';
import '../../../../src/core/network/api_client.dart';
import '../model/report_type.dart';


abstract class ReportTypeRemoteDataSource {
  Future<List<ReportTypeModel>> getAllReportTypes({
    required int page,
    required int limit,
  });
}

class ReportTypeRemoteDataSourceImpl implements ReportTypeRemoteDataSource {
  final ApiService apiService;

  ReportTypeRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<ReportTypeModel>> getAllReportTypes({
    required int page,
    required int limit,
  }) async {
    try {
      final queryParameters = {
        'page': page.toString(),
        'limit': limit.toString(),
      };
      final response = await apiService.get(
        '/report-types',
        queryParams: queryParameters,
      );
      if (response is Map<String, dynamic> && response.containsKey('report_types')) {
        final reportTypes = (response['report_types'] as List<dynamic>)
            .map((item) => ReportTypeModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return reportTypes;
      } else {
        throw ServerFailure('Phản hồi API không hợp lệ: $response');
      }
    } catch (e) {
      if (e is ApiException && e.isNetworkError) {
        throw ServerFailure('Lỗi mạng khi lấy danh sách loại báo cáo');
      } else if (e is ApiException && e.message.contains('404')) {
        return [];
      }
      throw ServerFailure('Lỗi khi gọi API /report-types: $e');
    }
  }
}