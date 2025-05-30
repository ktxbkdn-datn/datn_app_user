import 'package:equatable/equatable.dart';
import 'dart:typed_data';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();

  @override
  List<Object?> get props => [];
}

class ForgotPasswordEvent extends AuthEvent {
  final String email;

  const ForgotPasswordEvent({
    required this.email,
  });

  @override
  List<Object?> get props => [email];
}

class ResetPasswordEvent extends AuthEvent {
  final String email;
  final String newPassword;
  final String code;

  const ResetPasswordEvent({
    required this.email,
    required this.newPassword,
    required this.code,
  });

  @override
  List<Object?> get props => [email, newPassword, code];
}

class GetUserProfileEvent extends AuthEvent {
  const GetUserProfileEvent();

  @override
  List<Object?> get props => [];
}

class ResetAuthStateEvent extends AuthEvent {
  const ResetAuthStateEvent();

  @override
  List<Object?> get props => [];
}

class ChangePasswordEvent extends AuthEvent {
  final String oldPassword;
  final String newPassword;

  const ChangePasswordEvent({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword];
}

class UpdateUserProfileEvent extends AuthEvent {
  final String? email;
  final String? fullname;
  final String? phone;
  final String? cccd;
  final String? dateOfBirth;
  final String? className;

  const UpdateUserProfileEvent({
    this.email,
    this.fullname,
    this.phone,
    this.cccd,
    this.dateOfBirth,
    this.className,
  });

  @override
  List<Object?> get props => [email, fullname, phone, cccd, dateOfBirth, className];
}

class UpdateAvatarEvent extends AuthEvent {
  final String? filePath;
  final Uint8List? fileBytes;
  final String? mimeType;
  final String? filename; // Thêm filename để hỗ trợ web

  const UpdateAvatarEvent({
    this.filePath,
    this.fileBytes,
    this.mimeType,
    this.filename,
  });

  @override
  List<Object?> get props => [filePath, fileBytes, mimeType, filename];
}