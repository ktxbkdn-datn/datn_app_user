import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../domain/entities/user_entity.dart';
import '../../domain/usecases/auth_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';
import '../../../../src/core/network/api_client.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final Login login;
  final Logout logout;
  final ForgotPassword forgotPassword;
  final ResetPassword resetPassword;
  final GetUserProfile getUserProfile;
  final ChangePassword changePassword;
  final UpdateUserProfile updateUserProfile;
  final UpdateAvatar updateAvatar;
  UserEntity? _userCache;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthBloc({
    required this.login,
    required this.logout,
    required this.forgotPassword,
    required this.resetPassword,
    required this.getUserProfile,
    required this.changePassword,
    required this.updateUserProfile,
    required this.updateAvatar,
  }) : super(AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<ForgotPasswordEvent>(_onForgotPassword);
    on<ResetPasswordEvent>(_onResetPassword);
    on<GetUserProfileEvent>(_onGetUserProfile);
    on<ResetAuthStateEvent>(_onResetAuthState);
    on<ChangePasswordEvent>(_onChangePassword);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
    on<UpdateAvatarEvent>(_onUpdateAvatar);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await login(
      email: event.email,
      password: event.password,
    );
    result.fold(
      (failure) {
        emit(AuthError(message: _getUserFriendlyErrorMessage(failure.message)));
      },
      (tokenData) {
        final accessToken = tokenData['access_token'] as String?;
        final refreshToken = tokenData['refresh_token'] as String?;
        if (accessToken != null && refreshToken != null) {
          emit(Authenticated(accessToken: accessToken, refreshToken: refreshToken));
        } else {
          emit(AuthError(message: 'Đăng nhập thất bại: Không nhận được token hợp lệ.'));
        }
      },
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      // Clear SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final prefsKeysBefore = prefs.getKeys();
      print('SharedPreferences keys before logout: $prefsKeysBefore');
      await prefs.clear();
      print('Cleared all SharedPreferences data');
      final prefsKeysAfter = prefs.getKeys();
      print('SharedPreferences keys after logout: $prefsKeysAfter');

      // Clear FlutterSecureStorage
      final secureKeysBefore = await _secureStorage.readAll();
      print('SecureStorage keys before logout: ${secureKeysBefore.keys}');
      await _secureStorage.deleteAll();
      print('Cleared all FlutterSecureStorage data (including access_token, refresh_token)');
      final secureKeysAfter = await _secureStorage.readAll();
      print('SecureStorage keys after logout: ${secureKeysAfter.keys}');

      // Clear CachedNetworkImage
      await CachedNetworkImage.evictFromCache('');
      print('Cleared CachedNetworkImage cache');

      // Clear FlutterLocalNotifications
      final notificationsPlugin = FlutterLocalNotificationsPlugin();
      await notificationsPlugin.cancelAll();
      print('Cleared all local notifications');

      // Clear temporary files
      try {
        final tempDir = await getTemporaryDirectory();
        if (await tempDir.exists()) {
          await tempDir.delete(recursive: true);
          print('Cleared temporary directory');
        }
      } catch (e) {
        print('Error clearing temporary directory: $e');
      }

      // Perform logout via API
      final result = await logout();
      result.fold(
        (failure) {
          emit(AuthError(message: _getUserFriendlyErrorMessage(failure.message)));
        },
        (_) {
          _userCache = null;
          emit(LoggedOut());
        },
      );
    } catch (e) {
      emit(AuthError(message: _getUserFriendlyErrorMessage('Logout failed: $e')));
    }
  }

  Future<void> _onForgotPassword(ForgotPasswordEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await forgotPassword(
      email: event.email,
    );
    result.fold(
      (failure) {
        emit(AuthError(message: _getUserFriendlyErrorMessage(failure.message)));
      },
      (userType) {
        emit(ForgotPasswordSent(userType: userType));
      },
    );
  }

  Future<void> _onResetPassword(ResetPasswordEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await resetPassword(
      email: event.email,
      newPassword: event.newPassword,
      code: event.code,
    );
    result.fold(
      (failure) {
        emit(AuthError(message: _getUserFriendlyErrorMessage(failure.message)));
      },
      (_) {
        emit(PasswordResetSuccess());
      },
    );
  }

  Future<void> _onGetUserProfile(GetUserProfileEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await getUserProfile();
    result.fold(
      (failure) {
        String errorMessage = _getUserFriendlyErrorMessage(failure.message);
        if (errorMessage == "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.") {
          emit(TokenMissingError(message: errorMessage));
        } else {
          emit(AuthError(message: errorMessage));
        }
      },
      (user) {
        _userCache = user;
        emit(UserProfileLoaded(user: user));
      },
    );
  }

  Future<void> _onResetAuthState(ResetAuthStateEvent event, Emitter<AuthState> emit) async {
    emit(AuthInitial());
    _userCache = null;
  }

  Future<void> _onChangePassword(ChangePasswordEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await changePassword(
      oldPassword: event.oldPassword,
      newPassword: event.newPassword,
    );
    result.fold(
      (failure) {
        emit(AuthError(message: _getUserFriendlyErrorMessage(failure.message)));
      },
      (message) {
        emit(PasswordChanged(message: message));
      },
    );
  }

  Future<void> _onUpdateUserProfile(UpdateUserProfileEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final result = await updateUserProfile(
      email: event.email,
      fullname: event.fullname,
      phone: event.phone,
      cccd: event.cccd,
      dateOfBirth: event.dateOfBirth,
      className: event.className,
    );
    result.fold(
      (failure) {
        emit(AuthError(message: _getUserFriendlyErrorMessage(failure.message)));
      },
      (user) {
        _userCache = user;
        emit(UserProfileUpdated(user: user));
      },
    );
  }

  Future<void> _onUpdateAvatar(UpdateAvatarEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      final result = await updateAvatar(
        filePath: event.filePath,
        fileBytes: event.fileBytes,
        mimeType: event.mimeType,
        filename: event.filename,
      );
      result.fold(
        (failure) {
          emit(AuthError(message: _getUserFriendlyErrorMessage(failure.message)));
        },
        (user) {
          _userCache = user;
          emit(AvatarUpdated(user: user));
          add(GetUserProfileEvent());
        },
      );
    } catch (e) {
      emit(AuthError(message: _getUserFriendlyErrorMessage(e.toString())));
    }
  }

  String _getUserFriendlyErrorMessage(String errorMessage) {
    if (errorMessage.contains("Lỗi kết nối") || errorMessage.contains("Network error")) {
      return "Không có kết nối mạng. Vui lòng kiểm tra kết nối và thử lại.";
    } else if (errorMessage.contains("Unauthorized") || errorMessage.contains("Token không tồn tại")) {
      return "Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.";
    } else if (errorMessage.contains("Invalid email")) {
      return "Tài khoản không tồn tại. Vui lòng kiểm tra lại email.";
    } else if (errorMessage.contains("Invalid password")) {
      return "Mật khẩu không đúng. Vui lòng thử lại.";
    } else if (errorMessage.contains("Bạn chưa tạo hợp đồng")) {
      return errorMessage;
    } else if (errorMessage.contains("Mật khẩu cũ không đúng")) {
      return errorMessage;
    } else if (errorMessage.contains("Tài khoản tạm khóa")) {
      return errorMessage;
    } else if (errorMessage.contains("Invalid file format")) {
      return "Định dạng ảnh không hợp lệ. Vui lòng chọn ảnh JPG hoặc PNG.";
    } else if (errorMessage.contains("File size exceeds")) {
      return "Kích thước ảnh quá lớn. Vui lòng chọn ảnh nhỏ hơn 5MB.";
    } else if (errorMessage.contains("Bad Request")) {
      return "Dữ liệu gửi lên không hợp lệ. Vui lòng kiểm tra lại.";
    } else if (errorMessage.contains("Internal Server Error") || errorMessage.contains("Lỗi server")) {
      return "Có lỗi xảy ra từ phía server. Vui lòng thử lại sau.";
    } else if (errorMessage.contains("Not Found")) {
      return "Không tìm thấy tài nguyên. Vui lòng thử lại.";
    } else {
      return "Đã xảy ra lỗi không xác định. Vui lòng thử lại.";
    }
  }
}