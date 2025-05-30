import 'package:dartz/dartz.dart';
import 'dart:typed_data';
import '../../../../src/core/error/failures.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class Login {
  final AuthRepository repository;

  Login(this.repository);

  Future<Either<Failure, Map<String, String>>> call({
    required String email,
    required String password,
  }) async {
    return await repository.login(email: email, password: password);
  }
}

class Logout {
  final AuthRepository repository;

  Logout(this.repository);

  Future<Either<Failure, void>> call() async {
    return await repository.logout();
  }
}

class ForgotPassword {
  final AuthRepository repository;

  ForgotPassword(this.repository);

  Future<Either<Failure, String>> call({
    required String email,
  }) async {
    return await repository.forgotPassword(email: email);
  }
}

class ResetPassword {
  final AuthRepository repository;

  ResetPassword(this.repository);

  Future<Either<Failure, void>> call({
    required String email,
    required String newPassword,
    required String code,
  }) async {
    return await repository.resetPassword(
      email: email,
      newPassword: newPassword,
      code: code,
    );
  }
}

class GetUserProfile {
  final AuthRepository repository;

  GetUserProfile(this.repository);

  Future<Either<Failure, UserEntity>> call() async {
    return await repository.getUserProfile();
  }
}

class ChangePassword {
  final AuthRepository repository;

  ChangePassword(this.repository);

  Future<Either<Failure, String>> call({
    required String oldPassword,
    required String newPassword,
  }) async {
    return await repository.changePassword(
      oldPassword: oldPassword,
      newPassword: newPassword,
    );
  }
}

class UpdateUserProfile {
  final AuthRepository repository;

  UpdateUserProfile(this.repository);

  Future<Either<Failure, UserEntity>> call({
    String? email,
    String? fullname,
    String? phone,
    String? cccd,
    String? dateOfBirth,
    String? className,
  }) async {
    return await repository.updateUserProfile(
      email: email,
      fullname: fullname,
      phone: phone,
      cccd: cccd,
      dateOfBirth: dateOfBirth,
      className: className,
    );
  }
}

class UpdateAvatar {
  final AuthRepository repository;

  UpdateAvatar(this.repository);

  Future<Either<Failure, UserEntity>> call({
    String? filePath,
    Uint8List? fileBytes,
    String? mimeType,
    String? filename, // Thêm filename để hỗ trợ web
  }) async {
    return await repository.updateAvatar(
      filePath: filePath,
      fileBytes: fileBytes,
      mimeType: mimeType,
      filename: filename,
    );
  }
}