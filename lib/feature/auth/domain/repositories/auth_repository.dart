import 'package:dartz/dartz.dart';
import 'dart:typed_data';
import '../../../../src/core/error/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
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

  Future<Either<Failure, UserEntity>> getUserProfile();

  Future<Either<Failure, String>> changePassword({
    required String oldPassword,
    required String newPassword,
  });

  Future<Either<Failure, UserEntity>> updateUserProfile({
    String? email,
    String? fullname,
    String? phone,
    String? cccd,
    String? dateOfBirth,
    String? className,
  });

  Future<Either<Failure, UserEntity>> updateAvatar({
    String? filePath,
    Uint8List? fileBytes,
    String? mimeType,
    String? filename, // Thêm filename để hỗ trợ web
  });
}