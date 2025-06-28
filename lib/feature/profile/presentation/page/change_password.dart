import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:ui';
import 'dart:async';

import '../../../../common/utils/responsive_utils.dart';
import '../../../../common/utils/responsive_widget_extension.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../auth/presentation/pages/login_page.dart'; // Import LoginPage


class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  TextEditingController oldPasswordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  // ValueNotifier để quản lý thông báo lỗi
  final ValueNotifier<String?> oldPasswordError = ValueNotifier<String?>(null);
  final ValueNotifier<String?> newPasswordError = ValueNotifier<String?>(null);

  // ValueNotifier để quản lý trạng thái có lỗi hay không
  final ValueNotifier<bool> hasErrorsNotifier = ValueNotifier<bool>(false);

  // FocusNode để kiểm tra khi field mất focus
  FocusNode oldPasswordFocusNode = FocusNode();
  FocusNode newPasswordFocusNode = FocusNode();

  // Biến trạng thái để quản lý hiển thị mật khẩu
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;

  // Regex cho mật khẩu mới
  final RegExp passwordRegex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{12,}$');

  // Thêm biến để kiểm soát đã chạm vào ô nhập hay chưa
  bool _oldPasswordTouched = false;
  bool _newPasswordTouched = false;

  @override
  void initState() {
    super.initState();
    
    try {
      oldPasswordFocusNode.addListener(_oldPasswordFocusListener);
      newPasswordFocusNode.addListener(_newPasswordFocusListener);

      oldPasswordError.addListener(_updateHasErrors);
      newPasswordError.addListener(_updateHasErrors);
    } catch (e) {
      debugPrint('Error adding listeners: $e');
    }
  }

  @override
  void dispose() {
    try {
      // Remove the specific listeners before disposing
      if (oldPasswordFocusNode != null) {
        oldPasswordFocusNode.removeListener(_oldPasswordFocusListener);
      }
      if (newPasswordFocusNode != null) {
        newPasswordFocusNode.removeListener(_newPasswordFocusListener);
      }
      
      if (oldPasswordError != null) {
        oldPasswordError.removeListener(_updateHasErrors);
      }
      if (newPasswordError != null) {
        newPasswordError.removeListener(_updateHasErrors);
      }
    } catch (e) {
      debugPrint('Error removing listeners: $e');
    }
    
    // Dispose all resources safely with try-catch
    try {
      oldPasswordController.dispose();
      newPasswordController.dispose();
      oldPasswordFocusNode.dispose();
      newPasswordFocusNode.dispose();
      oldPasswordError.dispose();
      newPasswordError.dispose();
      hasErrorsNotifier.dispose();
    } catch (e) {
      debugPrint('Error disposing resources: $e');
    }
    
    super.dispose();
  }

  // Hàm kiểm tra mật khẩu cũ
  void _validateOldPassword(String value) {
    if (!_oldPasswordTouched) return;
    if (value.isEmpty) {
      oldPasswordError.value = "Mật khẩu cũ không được để trống";
    } else {
      oldPasswordError.value = null;
    }
  }

  // Hàm kiểm tra mật khẩu mới
  void _validateNewPassword(String value) {
    if (!_newPasswordTouched) return;
    if (value.isEmpty) {
      newPasswordError.value = "Mật khẩu mới không được để trống";
    } else if (!passwordRegex.hasMatch(value)) {
      newPasswordError.value = "Mật khẩu mới phải dài ít nhất 12 ký tự, chứa chữ hoa, chữ thường, số và ký tự đặc biệt (@\$!%*?&)";
    } else {
      newPasswordError.value = null;
    }
  }

  // Hàm cập nhật hasErrorsNotifier khi lỗi thay đổi
  void _updateHasErrors() {
    hasErrorsNotifier.value = _hasErrors;
  }

  // Kiểm tra xem có lỗi nào không
  bool get _hasErrors {
    return oldPasswordError.value != null || newPasswordError.value != null;
  }

  Future<void> _saveChanges() async {
    // Khi submit, đánh dấu cả hai field đã được chạm vào
    setState(() {
      _oldPasswordTouched = true;
      _newPasswordTouched = true;
    });
    _validateOldPassword(oldPasswordController.text);
    _validateNewPassword(newPasswordController.text);

    if (_hasErrors) return;

    // Xóa lỗi trước đó nếu có
    oldPasswordError.value = null;

    context.read<AuthBloc>().add(ChangePasswordEvent(
      oldPassword: oldPasswordController.text,
      newPassword: newPasswordController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is PasswordChanged) {
          // Show dialog and force logout, then go to login page
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Thành công'),
              content: Text(state.message),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.read<AuthBloc>().add(const LogoutEvent());
                    Get.offAll(() => LoginPage());
                  },
                  child: const Text('Đăng nhập lại', style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          );
        }
        if (state is TokenMissingError) {
          // Session expired, force logout and go to login page
          Get.offAll(() => LoginPage());
        }
      },
      child: Material(
        color: Colors.transparent,
        child: Stack(
          children: [
            // Glassmorphism overlay
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFE0ECFF), // blue-50
                      Color(0xFFEDE9FE), // indigo-50
                      Color(0xFFF3E8FF), // purple-50
                    ],
                  ),
                ),
              ),
            ),
            // Blurred background blobs
            Positioned(
              top: -60,
              left: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.withOpacity(0.20),
                      Colors.purple.withOpacity(0.20),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: const SizedBox(),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              right: -80,
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.purple.withOpacity(0.20),
                      Colors.pink.withOpacity(0.20),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
                  child: const SizedBox(),
                ),
              ),
            ),
            Center(
              child: Container(
                constraints: BoxConstraints(maxWidth: ResponsiveUtils.isPhone(context) ? 
                  ResponsiveUtils.screenWidth(context) * 0.9 : 500),
                margin: EdgeInsets.symmetric(
                  vertical: ResponsiveUtils.hp(context, 4),
                  horizontal: ResponsiveUtils.wp(context, 3)
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.90),
                  borderRadius: BorderRadius.circular(ResponsiveUtils.wp(context, 7)),
                  border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.wp(context, 6), 
                    vertical: ResponsiveUtils.hp(context, 3)
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.black87),
                              onPressed: () => Get.back(),
                              tooltip: 'Đóng',
                            ),
                            SizedBox(width: ResponsiveUtils.wp(context, 2)),
                            Text(
                              'Đổi mật khẩu',
                              style: TextStyle(
                                fontSize: ResponsiveUtils.sp(context, 22),
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        // Form fields
                        _buildPasswordField(
                          text: 'Mật khẩu cũ',
                          controller: oldPasswordController,
                          focusNode: oldPasswordFocusNode,
                          errorNotifier: oldPasswordError,
                          obscureText: _obscureOldPassword,
                          onVisibilityToggle: () {
                            setState(() {
                              _obscureOldPassword = !_obscureOldPassword;
                            });
                          },
                          onEditingComplete: () {
                            _validateOldPassword(oldPasswordController.text);
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        _buildPasswordField(
                          text: 'Mật khẩu mới',
                          controller: newPasswordController,
                          focusNode: newPasswordFocusNode,
                          errorNotifier: newPasswordError,
                          obscureText: _obscureNewPassword,
                          onVisibilityToggle: () {
                            setState(() {
                              _obscureNewPassword = !_obscureNewPassword;
                            });
                          },
                          onEditingComplete: () {
                            _validateNewPassword(newPasswordController.text);
                            FocusScope.of(context).nextFocus();
                          },
                        ),
                        const SizedBox(height: 18),
                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Get.back(),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: Colors.white.withOpacity(0.7),
                                  side: const BorderSide(color: Colors.black),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: const Text('Hủy', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black)),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: ValueListenableBuilder<bool>(
                                valueListenable: hasErrorsNotifier,
                                builder: (context, hasErrors, child) {
                                  return ElevatedButton(
                                    onPressed: hasErrors ? null : _saveChanges,
                                    style: ElevatedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      elevation: 0,
                                      backgroundColor: hasErrors
                                        ? Colors.grey
                                        : const Color(0xFF3B82F6),
                                    ),
                                    child: (hasErrors)
                                      ? const Text('Lưu thay đổi', style: TextStyle(fontWeight: FontWeight.w500))
                                      : (BlocProvider.of<AuthBloc>(context).state is AuthLoading)
                                        ? Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const SizedBox(
                                                width: 18,
                                                height: 18,
                                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                              ),
                                              const SizedBox(width: 10),
                                              const Text('Đang xử lý...'),
                                            ],
                                          )
                                        : const Text('Lưu thay đổi', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white)),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  // FocusNode listener for old password field
  void _oldPasswordFocusListener() {
    try {
      if (!oldPasswordFocusNode.hasFocus && _oldPasswordTouched) {
        _validateOldPassword(oldPasswordController.text);
      }
    } catch (e) {
      debugPrint('Error in _oldPasswordFocusListener: $e');
    }
  }
  
  // FocusNode listener for new password field
  void _newPasswordFocusListener() {
    try {
      if (!newPasswordFocusNode.hasFocus && _newPasswordTouched) {
        _validateNewPassword(newPasswordController.text);
      }
    } catch (e) {
      debugPrint('Error in _newPasswordFocusListener: $e');
    }
  }

  // Helper method to safely check FocusNode
  bool isFocusNodeActive(FocusNode node) {
    try {
      // This will throw if the FocusNode is disposed
      final _ = node.hasFocus;
      return true;
    } catch (e) {
      debugPrint('FocusNode already disposed: $e');
      return false;
    }
  }

  // Helper method to safely get a focus node for use in TextFormField
  FocusNode? getSafeFocusNode(FocusNode? node) {
    if (node == null) return null;
    try {
      // Try to access a property to verify the node is still valid
      final _ = node.canRequestFocus;
      return node;
    } catch (e) {
      debugPrint('FocusNode is not valid: $e');
      return null;
    }
  }
  
  // Helper method to safely get a controller for use in TextFormField
  TextEditingController? getSafeController(TextEditingController? controller) {
    if (controller == null) return null;
    try {
      // Try to access a property to verify the controller is still valid
      final _ = controller.text;
      return controller;
    } catch (e) {
      debugPrint('TextEditingController is not valid: $e');
      return null;
    }
  }

  Widget _buildPasswordField({
    required String text,
    required TextEditingController controller,
    required FocusNode focusNode,
    required ValueNotifier<String?> errorNotifier,
    required bool obscureText,
    required VoidCallback onVisibilityToggle,
    required VoidCallback onEditingComplete,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.hp(context, 1)),
      child: Container(
        padding: EdgeInsets.all(ResponsiveUtils.wp(context, 4)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ResponsiveUtils.wp(context, 3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: ResponsiveUtils.sp(context, 16),
                color: Colors.grey,
              ),
            ),
            SizedBox(height: ResponsiveUtils.hp(context, 1)),
            TextFormField(
              controller: controller,
              focusNode: focusNode,
              onTap: () {
                setState(() {
                  if (text == "Mật khẩu cũ") _oldPasswordTouched = true;
                  if (text == "Mật khẩu mới") _newPasswordTouched = true;
                });
              },
              onChanged: (value) {
                if (text == "Mật khẩu cũ" && _oldPasswordTouched) _validateOldPassword(value);
                if (text == "Mật khẩu mới" && _newPasswordTouched) _validateNewPassword(value);
              },
              onEditingComplete: onEditingComplete,
              obscureText: obscureText,
              style: TextStyle(color: Colors.black87, fontSize: ResponsiveUtils.sp(context, 15)),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.wp(context, 4.5), 
                  vertical: ResponsiveUtils.hp(context, 2)
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(ResponsiveUtils.wp(context, 12.5))),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: onVisibilityToggle,
                ),
              ),
            ),
            ValueListenableBuilder<String?>(
              valueListenable: errorNotifier,
              builder: (context, error, child) {
                if (error != null) {
                  return Padding(
                    padding: EdgeInsets.only(top: ResponsiveUtils.hp(context, 1)),
                    child: Row(
                      children: [
                        const Icon(Icons.error, color: Colors.red, size: 16),
                        SizedBox(width: ResponsiveUtils.wp(context, 2)),
                        Expanded(
                          child: Text(
                            error,
                            style: TextStyle(color: Colors.red, fontSize: ResponsiveUtils.sp(context, 14)),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}