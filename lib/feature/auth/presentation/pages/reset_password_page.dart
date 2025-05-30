import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart'; // Thêm import này

import '../../../../common/widgets/custom_materialbutton.dart';
import '../../../../src/core/di/injection.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController codeController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  bool _isObscure = true;

  @override
  void initState() {
    super.initState();
    // Nhận email từ arguments và điền sẵn vào emailController
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final email = ModalRoute.of(context)?.settings.arguments as String?;
      if (email != null) {
        emailController.text = email;
      }
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    codeController.dispose();
    newPasswordController.dispose();
    super.dispose();
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
          listener: (context, state) {
            if (state is AuthError) {
              Get.snackbar(
                'Error',
                state.message,
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red,
                colorText: Colors.white,
              );
            }
            if (state is PasswordResetSuccess) {
              Get.snackbar(
                'Success',
                'Đặt lại mật khẩu thành công',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
              // Điều hướng về trang đăng nhập và xóa stack điều hướng
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                    (Route<dynamic> route) => false, // Xóa toàn bộ stack
              );
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
                                      "Reset Password",
                                      style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "Enter your email, code, and new password",
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
                                    ),
                                    InputField(
                                      label: "Verification Code",
                                      controller: codeController,
                                    ),
                                    InputField(
                                      label: "New Password",
                                      controller: newPasswordController,
                                      obscureText: _isObscure,
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
                                    onTap: state is AuthLoading
                                        ? null
                                        : () {
                                      context.read<AuthBloc>().add(
                                        ResetPasswordEvent(
                                          email: emailController.text,
                                          newPassword:
                                          newPasswordController.text,
                                          code: codeController.text,
                                        ),
                                      );
                                    },
                                    buttonColor: Colors.lightGreenAccent,
                                    nameButton: 'Reset Password',
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
        const SizedBox(height: 30),
      ],
    );
  }
}