import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:mime/mime.dart';
import 'dart:developer' as developer;
import 'dart:typed_data';
import '../../../../src/core/error/failures.dart';
import '../../../../src/core/network/api_client.dart';
import '../model/report_model.dart';

abstract class ReportRemoteDataSource {
  Future<List<ReportModel>> getMyReports({
    required int page,
    required int limit,
    String? status,
  });

  Future<ReportModel> getReportById(int reportId);

  Future<ReportModel> createReport({
    required String title,
    required String content,
    int? reportTypeId,
    List<File>? images,
    List<Uint8List>? bytes,
  });
}

class ReportRemoteDataSourceImpl implements ReportRemoteDataSource {
  final ApiService apiService;
  static const int maxFileSizeInBytes = 50 * 1024 * 1024; // 50MB
  static const int maxFilesPerRequest = 10; // 10 file mỗi yêu cầu
  static const int maxTotalSizeInBytes = 500 * 1024 * 1024; // 500MB tổng

  ReportRemoteDataSourceImpl(this.apiService);

  @override
  Future<List<ReportModel>> getMyReports({
    required int page,
    required int limit,
    String? status,
  }) async {
    try {
      final queryParameters = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
      };
      final response = await apiService.get('/me/reports', queryParams: queryParameters);
      if (response is Map<String, dynamic> && response.containsKey('reports')) {
        final reports = (response['reports'] as List<dynamic>)
            .map((item) => ReportModel.fromJson(item as Map<String, dynamic>))
            .toList();
        return reports;
      } else {
        throw ServerFailure('Phản hồi API không hợp lệ: $response');
      }
    } catch (e) {
      if (e is ApiException && e.isNetworkError) {
        throw ServerFailure('Lỗi mạng khi lấy danh sách báo cáo');
      } else if (e is ApiException && e.message.contains('404')) {
        return [];
      }
      throw ServerFailure('Lỗi khi gọi API /me/reports: $e');
    }
  }

  @override
  Future<ReportModel> getReportById(int reportId) async {
    try {
      final response = await apiService.get('/reports/$reportId');
      if (response is Map<String, dynamic>) {
        return ReportModel.fromJson(response);
      } else {
        throw ServerFailure('Phản hồi API không hợp lệ: $response');
      }
    } catch (e) {
      throw ServerFailure('Lỗi khi gọi API /reports/$reportId: $e');
    }
  }

  @override
  Future<ReportModel> createReport({
    required String title,
    required String content,
    int? reportTypeId,
    List<File>? images,
    List<Uint8List>? bytes,
  }) async {
    try {
      final formData = <String, String>{
        'title': title,
        'content': content,
        if (reportTypeId != null) 'report_type_id': reportTypeId.toString(),
      };

      final files = <http.MultipartFile>[];
      int totalSize = 0;

      // Xử lý trên di động (images)
      if (images != null && images.isNotEmpty) {
        if (images.length > maxFilesPerRequest) {
          throw ServerFailure('Chỉ được upload tối đa $maxFilesPerRequest ảnh/video');
        }

        for (var file in images) {
          final fileSize = await file.length();
          totalSize += fileSize;
          if (fileSize > maxFileSizeInBytes) {
            throw ServerFailure('Ảnh/video ${file.path.split('/').last} vượt quá giới hạn kích thước (50MB)');
          }
        }

        for (var i = 0; i < images.length; i++) {
          final file = images[i];
          final fileName = file.path.split('/').last;
          final mimeType = lookupMimeType(file.path) ?? 'application/octet-stream';
          developer.log('Uploading file on mobile: $fileName, MIME type: $mimeType, size: ${await file.length()} bytes');

          final multipartFile = await http.MultipartFile.fromPath(
            'images', // Backend nhận danh sách file với key 'images'
            file.path,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          );
          files.add(multipartFile);
        }
      }

      // Xử lý trên web (bytes)
      if (bytes != null && bytes.isNotEmpty) {
        if (bytes.length > maxFilesPerRequest) {
          throw ServerFailure('Chỉ được upload tối đa $maxFilesPerRequest ảnh/video');
        }

        for (var byteData in bytes) {
          final fileSize = byteData.length;
          totalSize += fileSize;
          if (fileSize > maxFileSizeInBytes) {
            throw ServerFailure('Ảnh/video vượt quá giới hạn kích thước (50MB)');
          }
        }

        for (var i = 0; i < bytes.length; i++) {
          final byteData = bytes[i];
          final mimeType = lookupMimeType('file_$i', headerBytes: byteData) ?? 'application/octet-stream';
          final extension = mimeType.split('/').last;
          final fileName = 'file_$i.$extension';
          developer.log('Uploading file on web: $fileName, MIME type: $mimeType, size: ${byteData.length} bytes');

          final multipartFile = http.MultipartFile.fromBytes(
            'images', // Backend nhận danh sách file với key 'images'
            byteData,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          );
          files.add(multipartFile);
        }
      }

      // Kiểm tra tổng kích thước
      if (totalSize > maxTotalSizeInBytes) {
        throw ServerFailure('Tổng kích thước file vượt quá giới hạn (${maxTotalSizeInBytes ~/ (1024 * 1024)}MB)');
      }

      // Gửi yêu cầu multipart trong mọi trường hợp
      developer.log('Sending multipart request to /reports with formData: $formData, files: ${files.length}');
      final response = await apiService.postMultipart(
        '/reports',
        fields: formData,
        files: files,
      );
      if (response is Map<String, dynamic>) {
        developer.log('Received response: $response');
        return ReportModel.fromJson(response);
      } else {
        throw ServerFailure('Phản hồi API không hợp lệ: $response');
      }
    } catch (e) {
      developer.log('Error in createReport: $e');
      throw ServerFailure('Lỗi khi gọi API /reports: $e');
    }
  }
}