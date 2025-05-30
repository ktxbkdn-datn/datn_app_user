import 'package:dartz/dartz.dart';
import 'dart:typed_data';
import '../../../../src/core/error/failures.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Map<String, String>>> login({
    required String email,
    required String password,
  }) async {
    try {
      final result = await remoteDataSource.login(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final result = await remoteDataSource.logout();
      return result;
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> forgotPassword({
    required String email,
  }) async {
    try {
      final result = await remoteDataSource.forgotPassword(email: email);
      return result;
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String email,
    required String newPassword,
    required String code,
  }) async {
    try {
      final result = await remoteDataSource.resetPassword(
        email: email,
        newPassword: newPassword,
        code: code,
      );
      return result;
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserProfile() async {
    try {
      final result = await remoteDataSource.getUserProfile();
      return result.map((userModel) => userModel.toEntity());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final result = await remoteDataSource.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return result;
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUserProfile({
    String? email,
    String? fullname,
    String? phone,
    String? cccd,
    String? dateOfBirth,
    String? className,
  }) async {
    try {
      final result = await remoteDataSource.updateUserProfile(
        email: email,
        fullname: fullname,
        phone: phone,
        cccd: cccd,
        dateOfBirth: dateOfBirth,
        className: className,
      );
      return result.map((userModel) => userModel.toEntity());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateAvatar({
    String? filePath,
    Uint8List? fileBytes,
    String? mimeType,
    String? filename,
  }) async {
    try {
      final result = await remoteDataSource.updateAvatar(
        filePath: filePath,
        fileBytes: fileBytes,
        mimeType: mimeType,
        filename: filename,
      );
      return result.map((userModel) => userModel.toEntity());
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}