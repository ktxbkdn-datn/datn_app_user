import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ionicons/ionicons.dart';
import 'dart:ui';
import 'dart:async';

import '../../../../common/constant/colors.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../welcome_page/welcome_page.dart';

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

  @override
  void initState() {
    super.initState();

    // Thêm listener cho FocusNode
    oldPasswordFocusNode.addListener(() {
      if (!oldPasswordFocusNode.hasFocus) {
        _validateOldPassword(oldPasswordController.text);
      }
    });
    newPasswordFocusNode.addListener(() {
      if (!newPasswordFocusNode.hasFocus) {
        _validateNewPassword(newPasswordController.text);
      }
    });

    // Thêm listener để cập nhật hasErrorsNotifier khi lỗi thay đổi
    oldPasswordError.addListener(_updateHasErrors);
    newPasswordError.addListener(_updateHasErrors);

    // Kiểm tra ban đầu
    _validateOldPassword(oldPasswordController.text);
    _validateNewPassword(newPasswordController.text);
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    oldPasswordFocusNode.dispose();
    newPasswordFocusNode.dispose();
    oldPasswordError.removeListener(_updateHasErrors);
    newPasswordError.removeListener(_updateHasErrors);
    oldPasswordError.dispose();
    newPasswordError.dispose();
    hasErrorsNotifier.dispose();
    super.dispose();
  }

  // Hàm kiểm tra mật khẩu cũ
  void _validateOldPassword(String value) {
    if (value.isEmpty) {
      oldPasswordError.value = "Mật khẩu cũ không được để trống";
    } else {
      oldPasswordError.value = null; // Xóa lỗi trước đó nếu có
    }
  }

  // Hàm kiểm tra mật khẩu mới
  void _validateNewPassword(String value) {
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
    if (_hasErrors) return;

    // Xóa lỗi trước đó nếu có
    oldPasswordError.value = null;

    context.read<AuthBloc>().add(ChangePasswordEvent(
      oldPassword: oldPasswordController.text,
      newPassword: newPasswordController.text,
    ));
  }

  void _showCustomDialog({
    required bool isSuccess,
    required String title,
    required String message,
    bool showLoading = false,
  }) {
    // Biến để kiểm soát trạng thái của dialog
    bool dialogClosed = false;

    // Hiển thị dialog
    showDialog(
      context: context,
      barrierDismissible: !showLoading,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        contentPadding: const EdgeInsets.all(20),
        content: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
            gradient: LinearGradient(
              colors: isSuccess
                  ? [Colors.green.shade50, Colors.white]
                  : [Colors.red.shade50, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              showLoading
                  ? const CircularProgressIndicator()
                  : Icon(
                isSuccess ? Icons.check_circle : Icons.error,
                color: isSuccess ? Colors.green : Colors.red,
                size: 50,
              ),
              const SizedBox(height: 16),
              Text(
                title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? Colors.green : Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              if (!showLoading) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (message.contains("kết nối") || message.contains("server")) ...[
                      ElevatedButton(
                        onPressed: () {
                          dialogClosed = true;
                          Navigator.of(dialogContext).pop();
                          _saveChanges();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        ),
                        child: const Text(
                          "Thử lại",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    ElevatedButton(
                      onPressed: () {
                        dialogClosed = true;
                        Navigator.of(dialogContext).pop();
                        if (isSuccess) {
                          Get.offAll(() => const WelcomePage());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSuccess ? Colors.green : Colors.red.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                      ),
                      child: const Text(
                        "OK",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    ).then((_) {
      dialogClosed = true;
    });

    // Tự động đóng dialog sau 5 giây nếu chưa đóng và không có lỗi kết nối/server
    if (!showLoading && !message.contains("kết nối") && !message.contains("server")) {
      Timer(const Duration(seconds: 5), () {
        if (!dialogClosed && mounted) {
          Navigator.of(context).pop();
          if (isSuccess) {
            Get.offAll(() => const WelcomePage());
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          Get.snackbar(
            'Error',
            state.message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            borderRadius: 10,
          );
        }
        if (state is PasswordChanged) {
          _showCustomDialog(
            isSuccess: true,
            title: "Thành công",
            message: state.message,
          );
        }
      },
      builder: (context, state) {
        if (state is AuthLoading) {
          return const Center(child: CircularProgressIndicator.adaptive());
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.glassmorphismStart, AppColors.glassmorphismEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back, color: Colors.black87),
                              onPressed: () => Get.back(),
                            ),
                            const Expanded(
                              child: Text(
                                "Đổi mật khẩu",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      Form(
                        child: Column(
                          children: [
                            _buildPasswordField(
                              text: "Mật khẩu cũ",
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
                              text: "Mật khẩu mới",
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
                          ],
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(
                            width: 120,
                            child: ElevatedButton(
                              onPressed: () => Get.back(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey.withOpacity(0.1),
                                foregroundColor: Colors.black87,
                                minimumSize: const Size(double.infinity, 48),
                                shape: const StadiumBorder(),
                              ),
                              child: const Text("Hủy"),
                            ),
                          ),
                          const SizedBox(width: 16.0),
                          ValueListenableBuilder<bool>(
                            valueListenable: hasErrorsNotifier,
                            builder: (context, hasErrors, child) {
                              return SizedBox(
                                width: 160,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    foregroundColor: Colors.white,
                                    minimumSize: const Size(double.infinity, 48),
                                    shape: const StadiumBorder(),
                                  ),
                                  onPressed: hasErrors ? null : _saveChanges,
                                  child: const Text("Lưu thay đổi"),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
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
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
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
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: controller,
              focusNode: focusNode,
              onEditingComplete: onEditingComplete,
              obscureText: obscureText,
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.withOpacity(0.1),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0 * 1.5, vertical: 16.0),
                border: const OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.all(Radius.circular(50)),
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
                if (error == null) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 4.0, left: 16.0),
                  child: Text(
                    error,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}