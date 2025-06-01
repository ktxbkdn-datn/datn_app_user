import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../common/widgets/custom_materialbutton.dart';
import '../../../../src/core/di/injection.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isObscure = true;

  // ValueNotifier để quản lý thông báo lỗi
  final ValueNotifier<String?> emailError = ValueNotifier<String?>(null);
  final ValueNotifier<String?> passwordError = ValueNotifier<String?>(null);
  final ValueNotifier<bool> hasErrorsNotifier = ValueNotifier<bool>(false);

  // FocusNode để kiểm tra khi field mất focus
  FocusNode emailFocusNode = FocusNode();
  FocusNode passwordFocusNode = FocusNode();

  // Regex cho định dạng email
  final RegExp emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');

  @override
  void initState() {
    super.initState();

    // Thêm listener cho FocusNode
    emailFocusNode.addListener(() {
      if (!emailFocusNode.hasFocus) {
        _validateEmail(emailController.text);
      }
    });
    passwordFocusNode.addListener(() {
      if (!passwordFocusNode.hasFocus) {
        _validatePassword(passwordController.text);
      }
    });

    // Thêm listener để cập nhật hasErrorsNotifier khi lỗi thay đổi
    emailError.addListener(_updateHasErrors);
    passwordError.addListener(_updateHasErrors);

    // Kiểm tra ban đầu
    _validateEmail(emailController.text);
    _validatePassword(passwordController.text);
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    emailError.removeListener(_updateHasErrors);
    passwordError.removeListener(_updateHasErrors);
    emailError.dispose();
    passwordError.dispose();
    hasErrorsNotifier.dispose();
    super.dispose();
  }

  // Hàm kiểm tra email
  void _validateEmail(String value) {
    if (value.isEmpty) {
      emailError.value = "Email không được để trống";
    } else if (!emailRegex.hasMatch(value)) {
      emailError.value = "Email không hợp lệ";
    } else {
      emailError.value = null;
    }
  }

  // Hàm kiểm tra mật khẩu
  void _validatePassword(String value) {
    if (value.isEmpty) {
      passwordError.value = "Mật khẩu không được để trống";
    } else {
      passwordError.value = null;
    }
  }

  // Hàm cập nhật hasErrorsNotifier khi lỗi thay đổi
  void _updateHasErrors() {
    hasErrorsNotifier.value = _hasErrors;
  }

  // Kiểm tra xem có lỗi nào không
  bool get _hasErrors {
    return emailError.value != null || passwordError.value != null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<AuthBloc>(),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.grey[100],
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 20,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) async {
            if (state is AuthError) {
              Get.snackbar(
                "Lỗi",
                state.message,
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: const Duration(seconds: 3),
                margin: const EdgeInsets.all(16),
                borderRadius: 10,
              );
            }
            if (state is Authenticated) {
              // Lưu accessToken vào SharedPreferences
              try {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                await prefs.setString('access_token', state.accessToken);
                print('Saved access token to SharedPreferences: ${state.accessToken}');
              } catch (e) {
                print('Error saving access token to SharedPreferences: $e');
              }
              // Chuyển hướng sang /login_bottom_bar
              Navigator.of(context).pushReplacementNamed('/login_bottom_bar');
            }
            if (state is LoggedOut) {
              Navigator.of(context).pushReplacementNamed('/welcome');
            }
            if (state is ForgotPasswordSent) {
              Get.snackbar(
                "Thông báo",
                'Mã xác nhận đã được gửi qua email: ${state.userType}',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.blue,
                colorText: Colors.white,
                duration: const Duration(seconds: 3),
                margin: const EdgeInsets.all(16),
                borderRadius: 10,
              );
              Navigator.of(context).pushNamed('/reset_password');
            }
            if (state is PasswordResetSuccess) {
              Get.snackbar(
                "Thành công",
                'Đặt lại mật khẩu thành công',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green,
                colorText: Colors.white,
                duration: const Duration(seconds: 3),
                margin: const EdgeInsets.all(16),
                borderRadius: 10,
              );
            }
            if (state is UserProfileLoaded) {
              print('User profile loaded: ${state.user.fullname}');
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(40, 1.2 * kToolbarHeight, 40, 20),
                child: SizedBox(
                  child: Stack(
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height - 100,
                        width: double.infinity,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                const SizedBox(height: 30),
                                const Column(
                                  children: <Widget>[
                                    Text(
                                      "Đăng nhập",
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Đăng nhập vào tài khoản được cấp của bạn",
                                      style: TextStyle(
                                        fontSize: 15,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 30),
                                Column(
                                  children: [
                                    InputField(
                                      label: "Email",
                                      controller: emailController,
                                      focusNode: emailFocusNode,
                                      errorNotifier: emailError,
                                      onEditingComplete: () {
                                        _validateEmail(emailController.text);
                                        FocusScope.of(context).nextFocus();
                                      },
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        InputField(
                                          label: "Mật khẩu",
                                          controller: passwordController,
                                          focusNode: passwordFocusNode,
                                          obscureText: _isObscure,
                                          errorNotifier: passwordError,
                                          onEditingComplete: () {
                                            _validatePassword(passwordController.text);
                                            FocusScope.of(context).nextFocus();
                                          },
                                          suffixIcon: IconButton(
                                            icon: Icon(
                                              _isObscure
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _isObscure = !_isObscure;
                                              });
                                            },
                                          ),
                                        ),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          children: [
                                            TextButton(
                                              onPressed: state is AuthLoading
                                                  ? null
                                                  : () {
                                                      Navigator.of(context)
                                                          .pushNamed('/forgot_password');
                                                    },
                                              child: const Text(
                                                'Quên mật khẩu ?',
                                                style: TextStyle(
                                                  color: Colors.blueAccent,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                if (state is AuthLoading)
                                  const CircularProgressIndicator(),
                                Container(
                                  padding: const EdgeInsets.only(top: 3, left: 3),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(50),
                                    border: const Border(
                                      bottom: BorderSide(color: Colors.black),
                                      top: BorderSide(color: Colors.black),
                                      left: BorderSide(color: Colors.black),
                                      right: BorderSide(color: Colors.black),
                                    ),
                                  ),
                                  child: KtxButton(
                                    onTap: (state is AuthLoading || _hasErrors)
                                        ? null
                                        : () {
                                            context.read<AuthBloc>().add(
                                                  LoginEvent(
                                                    email: emailController.text.trim(),
                                                    password: passwordController.text.trim(),
                                                  ),
                                                );
                                          },
                                    buttonColor: Colors.lightGreenAccent,
                                    nameButton: 'Đăng nhập',
                                    textColor: Colors.black,
                                    borderSideColor: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget InputField({
    required String label,
    required TextEditingController controller,
    required FocusNode focusNode,
    required ValueNotifier<String?> errorNotifier,
    required VoidCallback onEditingComplete,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          focusNode: focusNode,
          onEditingComplete: onEditingComplete,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade400,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade600,
              ),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.red,
              ),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.red,
              ),
            ),
            border: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.grey.shade400,
              ),
            ),
            suffixIcon: suffixIcon,
          ),
        ),
        ValueListenableBuilder<String?>(
          valueListenable: errorNotifier,
          builder: (context, error, child) {
            if (error == null) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.only(top: 4.0, left: 10.0),
              child: Text(
                error,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            );
          },
        ),
        const SizedBox(height: 30),
      ],
    );
  }
}