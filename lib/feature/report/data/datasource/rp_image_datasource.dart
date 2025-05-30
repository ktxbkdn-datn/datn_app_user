// lib/src/features/report/data/datasources/report_image_remote_data_source.dart
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../../../src/core/error/failures.dart';
import '../../../../src/core/network/api_client.dart';
import '../model/report_image_model.dart';


abstract class ReportImageRemoteDataSource {
  Future<List<ReportImageModel>> getReportImages(int reportId);
  Future<List<ReportImageModel>> addReportImages({
    required int reportId,
    required List<File> files,
    String? altText,
  });
}

class ReportImageRemoteDataSourceImpl implements ReportImageRemoteDataSource {
  final ApiService apiService;

  ReportImageRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<ReportImageModel>> getReportImages(int reportId) async {
    try {
      final response = await apiService.get('/reports/$reportId/images');
      if (response is List<dynamic>) {
        final imageList = response
            .map((item) => ReportImageModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return imageList;
      } else if (response is Map<String, dynamic> && response.containsKey('message')) {
        return []; // Trả về danh sách rỗng nếu không tìm thấy ảnh
      } else {
        throw ServerFailure('Phản hồi API không hợp lệ: $response');
      }
    } catch (e) {
      if (e is ApiException && e.isNetworkError) {
        throw ServerFailure('Không tìm thấy hình ảnh cho báo cáo $reportId - Lỗi mạng');
      } else if (e is ApiException && e.message.contains('404')) {
        return []; // Trả về danh sách rỗng thay vì lỗi
      }
      throw ServerFailure('Lỗi khi gọi API /reports/$reportId/images: $e');
    }
  }

  @override
  Future<List<ReportImageModel>> addReportImages({
    required int reportId,
    required List<File> files,
    String? altText,
  }) async {
    try {
      final formData = <String, String>{
        if (altText != null && altText.isNotEmpty) 'alt_text': altText,
      };

      final multipartFiles = <http.MultipartFile>[];
      for (var file in files) {
        final fileName = file.path.split('/').last;
        multipartFiles.add(
          await http.MultipartFile.fromPath('images[]', file.path, filename: fileName),
        );
      }

      final response = await apiService.postMultipart(
        '/reports/$reportId/images',
        fields: formData,
        files: multipartFiles,
      );

      if (response is List<dynamic>) {
        final imageList = response
            .map((item) => ReportImageModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return imageList;
      } else {
        throw ServerFailure('Phản hồi API không hợp lệ: $response');
      }
    } catch (e) {
      throw ServerFailure('Lỗi khi gọi API /reports/$reportId/images: $e');
    }
  }
}