import 'dart:typed_data';
import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
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
  }) async {
    try {
      final body = <String, dynamic>{};
      if (email != null) body['email'] = email;
      if (fullname != null) body['fullname'] = fullname;
      if (phone != null) body['phone'] = phone;
      if (cccd != null) body['CCCD'] = cccd;
      if (dateOfBirth != null) body['date_of_birth'] = dateOfBirth;
      if (className != null) body['class_name'] = className;

      final response = await apiService.put('/me', body);
      final user = UserModel.fromJson(response);
      return Right(user);
    } catch (e) {
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