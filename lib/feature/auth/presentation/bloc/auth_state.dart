import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final String accessToken;
  final String refreshToken;

  const Authenticated({required this.accessToken, required this.refreshToken});

  @override
  List<Object?> get props => [accessToken, refreshToken];
}

class LoggedOut extends AuthState {}

class TokenMissingError extends AuthState {
  final String message;

  const TokenMissingError({required this.message});

  @override
  List<Object?> get props => [message];
}

class ForgotPasswordSent extends AuthState {
  final String userType;

  const ForgotPasswordSent({required this.userType});

  @override
  List<Object?> get props => [userType];
}

class PasswordResetSuccess extends AuthState {}

class UserProfileLoaded extends AuthState {
  final UserEntity user;

  const UserProfileLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

class PasswordChanged extends AuthState {
  final String message;

  const PasswordChanged({required this.message});

  @override
  List<Object?> get props => [message];
}

class UserProfileUpdated extends AuthState {
  final UserEntity user;

  const UserProfileUpdated({required this.user});

  @override
  List<Object?> get props => [user];
}

class AvatarUpdated extends AuthState {
  final UserEntity user;

  const AvatarUpdated({required this.user});

  @override
  List<Object?> get props => [user];
}