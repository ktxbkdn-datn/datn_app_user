import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;

import '../../../../src/core/error/failures.dart';
import '../../../../src/core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<Either<Failure, Map<String, String>>> login({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, String>> forgotPassword({
    required String email,
  });

  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String newPassword,
    required String code,
  });

  Future<Either<Failure, UserModel>> getUserProfile();

  Future<Either<Failure, String>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<Either<Failure, UserModel>> updateUserProfile({
    String? email,
    String? fullname,
    String? phone,
    String? cccd,
    String? dateOfBirth,
    String? className,
    String? studentCode, // thêm
    String? hometown,    // thêm
  });

  Future<Either<Failure, UserModel>> updateAvatar({
    String? filePath,
    Uint8List? fileBytes,
    String? mimeType,
    String? filename, // Thêm filename để hỗ trợ web
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiService apiService;

  AuthRemoteDataSourceImpl(this.apiService);

  @override
  Future<Either<Failure, Map<String, String>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final body = {
        'email': email,
        'password': password,
      };
      final response = await apiService.post('/auth/user/login', body);
      final accessToken = response['access_token'] as String?;
      final refreshToken = response['refresh_token'] as String?;
      if (accessToken != null && refreshToken != null) {
        await apiService.setToken(accessToken, refreshToken: refreshToken);
        return Right({
          'access_token': accessToken,
          'refresh_token': refreshToken,
        });
      } else {
        throw ApiException('Đăng nhập thất bại: Không nhận được token hợp lệ.');
      }
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await apiService.post('/auth/logout', {});
      await apiService.clearToken();
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, String>> forgotPassword({
    required String email,
  }) async {
    try {
      final body = {
        'email': email,
      };
      final response = await apiService.post('/auth/forgot-password', body);
      final userType = response['user_type'] as String;
      return Right(userType);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String newPassword,
    required String code,
  }) async {
    try {
      final body = {
        'email': email,
        'newPassword': newPassword,
        'code': code,
      };
      await apiService.post('/auth/reset-password', body);
      return const Right(null);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, UserModel>> getUserProfile() async {
    try {
      final response = await apiService.get('/me');
      final user = UserModel.fromJson(response);
      return Right(user);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, String>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final body = {
        'old_password': oldPassword,
        'new_password': newPassword,
      };
      final response = await apiService.put('/user/password', body);
      final message = response['message'] as String;
      return Right(message);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateUserProfile({
    String? email,
    String? fullname,
    String? phone,
    String? cccd,
    String? dateOfBirth,
    String? className,
    String? studentCode,
    String? hometown,
  }) async {
    try {
      final body = <String, dynamic>{};
      
      // Chỉ thêm các trường thực sự cần cập nhật để tránh gửi dữ liệu không cần thiết
      // Backend hiện không hỗ trợ cập nhật email thông qua /me endpoint
      if (fullname != null && fullname.trim().isNotEmpty) body['fullname'] = fullname.trim();
      if (phone != null) body['phone'] = phone.trim();
      if (cccd != null) body['CCCD'] = cccd.trim();
      if (studentCode != null) body['student_code'] = studentCode.trim();
      if (hometown != null) body['hometown'] = hometown.trim();
      if (className != null && className.trim().isNotEmpty) body['class_name'] = className.trim();
      
      // Xử lý ngày sinh đặc biệt - API backend mong đợi định dạng dd-MM-yyyy
      if (dateOfBirth != null && dateOfBirth.trim().isNotEmpty) {
        try {
          final trimmedDate = dateOfBirth.trim();
          
          // Nếu là định dạng yyyy-MM-dd, chuyển sang dd-MM-yyyy
          if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(trimmedDate)) {
            final date = DateFormat('yyyy-MM-dd').parse(trimmedDate);
            body['date_of_birth'] = DateFormat('dd-MM-yyyy').format(date);
            debugPrint('Date converted from $trimmedDate to ${body['date_of_birth']}');
          } 
          // Nếu đã là định dạng dd-MM-yyyy, giữ nguyên
          else if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(trimmedDate)) {
            body['date_of_birth'] = trimmedDate;
            debugPrint('Date already in correct format: $trimmedDate');
          } 
          // Thử phân tích định dạng khác
          else {
            final date = DateTime.parse(trimmedDate);
            body['date_of_birth'] = DateFormat('dd-MM-yyyy').format(date);
            debugPrint('Date parsed and converted to: ${body['date_of_birth']}');
          }
        } catch (e) {
          debugPrint('Error formatting date: $e');
          return Left(ServerFailure('Định dạng ngày sinh không hợp lệ: $dateOfBirth'));
        }
      }
      
      // Log để debug
      debugPrint('PUT /me request payload: $body');
      
      // Kiểm tra body trống
      if (body.isEmpty) {
        return Left(ServerFailure('Không có thông tin nào để cập nhật'));
      }
      
      try {
        // Gửi yêu cầu PUT đến API
        final response = await apiService.put('/me', body);
        
        // Log chi tiết phản hồi
        debugPrint('PUT /me response: $response');
        
        // Phân tích phản hồi
        final user = UserModel.fromJson(response);
        
        // Sau khi cập nhật thành công, lấy lại thông tin mới từ API
        try {
          final currentProfileResponse = await apiService.get('/me');
          debugPrint('GET /me after update response: $currentProfileResponse');
          final currentUser = UserModel.fromJson(currentProfileResponse);
          debugPrint('Updated user profile: ${currentUser.toString()}');
          return Right(currentUser);
        } catch (fallbackError) {
          debugPrint('Failed to get updated profile: $fallbackError');
          // Vẫn trả về user từ response PUT nếu không lấy được thông tin mới
          return Right(user);
        }
      } catch (apiError) {
        debugPrint('API error when updating profile: $apiError');
        
        // Hiển thị lỗi từ server một cách chi tiết hơn
        if (apiError.toString().contains("500")) {
          return Left(ServerFailure('Lỗi server khi cập nhật hồ sơ. Vui lòng thử lại sau hoặc liên hệ admin.'));
        }
        
        // KHÔNG lấy hồ sơ hiện tại để trả về nếu cập nhật thất bại
        // Thay vào đó, trả về lỗi để thông báo cho người dùng
        return Left(_handleError(apiError));
      }
    } catch (e) {
      debugPrint('PUT /me error: $e');
      return Left(_handleError(e));
    }
  }

  @override
  Future<Either<Failure, UserModel>> updateAvatar({
    String? filePath,
    Uint8List? fileBytes,
    String? mimeType,
    String? filename,
  }) async {
    try {
      // Xác định fileName và mimeType
      String fileName;
      String finalMimeType;
      if (filePath != null) {
        fileName = path.basename(filePath);
        finalMimeType = mimeType ?? lookupMimeType(filePath) ?? _getMimeTypeFromExtension(fileName);
   
      } else if (fileBytes != null && filename != null) {
        fileName = filename;
        finalMimeType = mimeType ?? _getMimeTypeFromExtension(filename);
        
      } else {
        throw Exception("No file data provided");
      }

      // Kiểm tra mimeType
      if (!_isValidImageMimeType(finalMimeType)) {
   
        throw Exception('Định dạng file không hợp lệ: $finalMimeType');
      }

      // Tạo multipart file
      http.MultipartFile multipartFile;
      if (filePath != null) {
        multipartFile = await http.MultipartFile.fromPath(
          'avatar',
          filePath,
          contentType: MediaType.parse(finalMimeType),
        );
      } else {
        multipartFile = http.MultipartFile.fromBytes(
          'avatar',
          fileBytes!,
          filename: fileName,
          contentType: MediaType.parse(finalMimeType),
        );
      }

      final response = await apiService.putMultipart(
        '/me/avatar',
        fileFieldName: "avatar",
        fileName: fileName,
        files: filePath != null ? [multipartFile] : null,
        fileBytes: fileBytes,
        mimeType: finalMimeType,
      );

      final user = UserModel.fromJson(response);
      return Right(user);
    } catch (e) {
      return Left(_handleError(e));
    }
  }

  Failure _handleError(dynamic error) {
    if (error is ServerFailure) {
      return ServerFailure(error.message);
    } else if (error is NetworkFailure) {
      return NetworkFailure(error.message);
    } else {
      return ServerFailure('Unexpected error: $error');
    }
  }

  bool _isValidImageMimeType(String mimeType) {
    const allowedMimeTypes = [
      'image/png', 'image/jpeg', 'image/gif', 'image/webp', 'image/bmp',
      'image/tiff', 'image/heic', 'image/heif'
    ];
    return allowedMimeTypes.contains(mimeType);
  }

  String _getMimeTypeFromExtension(String filename) {
    final extension = filename.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'tiff':
        return 'image/tiff';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      default:
        return 'application/octet-stream';
    }
  }
}