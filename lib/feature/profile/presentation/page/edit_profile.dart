import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../common/constant/colors.dart';
import '../../../../common/utils/responsive_utils.dart';
import '../../../../common/utils/responsive_widget_extension.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';


// Widget chính để chỉnh sửa hồ sơ người dùng
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

// Trạng thái của EditProfileScreen
class _EditProfileScreenState extends State<EditProfileScreen> {

  // Biến lưu giới tính, mặc định là "man"
  String gender = "man";
  // Các controller để quản lý dữ liệu nhập vào
  TextEditingController phoneController = TextEditingController();
  TextEditingController birthdateController = TextEditingController();
  TextEditingController cccdController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController studentCodeController = TextEditingController();
  TextEditingController hometownController = TextEditingController();
  // Trạng thái đang tải dữ liệu
  bool isFetching = false;

  // ValueNotifier để quản lý lỗi số điện thoại và CCCD
  final ValueNotifier<String?> phoneError = ValueNotifier<String?>(null);
  final ValueNotifier<String?> cccdError = ValueNotifier<String?>(null);

  // FocusNode để quản lý focus của các trường nhập liệu
  FocusNode phoneFocusNode = FocusNode();
  FocusNode cccdFocusNode = FocusNode();

  bool _phoneTouched = false;
  bool _cccdTouched = false;

  // FocusNode listener for phone field
  void _phoneFocusListener() {
    try {
      if (phoneFocusNode.hasFocus) {
        if (mounted) {
          setState(() {
            _phoneTouched = true;
          });
        }
      }
      if (!phoneFocusNode.hasFocus && _phoneTouched) {
        _validatePhone(phoneController.text);
      }
    } catch (e) {
      debugPrint('Error in _phoneFocusListener: $e');
    }
  }
  
  // FocusNode listener for CCCD field
  void _cccdFocusListener() {
    try {
      if (cccdFocusNode.hasFocus) {
        if (mounted) {
          setState(() {
            _cccdTouched = true;
          });
        }
      }
      if (!cccdFocusNode.hasFocus && _cccdTouched) {
        _validateCccd(cccdController.text);
      }
    } catch (e) {
      debugPrint('Error in _cccdFocusListener: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    // Lấy trạng thái từ AuthBloc để điền dữ liệu ban đầu
    try {
      final state = BlocProvider.of<AuthBloc>(context, listen: false).state;
      if (state is UserProfileLoaded) {
        phoneController.text = state.user.phone ?? "";
        if (state.user.dateOfBirth != null && state.user.dateOfBirth!.isNotEmpty) {
          try {
            // Try both formats
            DateTime date;
            if (RegExp(r'^\d{4}-\d{2}-\d{2} ?$').hasMatch(state.user.dateOfBirth!)) {
              date = DateFormat('yyyy-MM-dd').parse(state.user.dateOfBirth!);
            } else if (RegExp(r'^\d{2}-\d{2}-\d{4} ?$').hasMatch(state.user.dateOfBirth!)) {
              date = DateFormat('dd-MM-yyyy').parse(state.user.dateOfBirth!);
            } else {
              date = DateTime.tryParse(state.user.dateOfBirth!) ?? DateTime.now();
            }
            birthdateController.text = DateFormat('dd-MM-yyyy').format(date);
          } catch (e) {
            birthdateController.text = state.user.dateOfBirth!;
          }
        } else {
          birthdateController.text = "";
        }
        cccdController.text = state.user.cccd ?? "";
        nameController.text = state.user.fullname;
        emailController.text = state.user.email;
        studentCodeController.text = state.user.studentCode ?? "";
        hometownController.text = state.user.hometown ?? "";
      }
    } catch (e) {
      debugPrint('Error initializing fields: $e');
    }

    // Add listeners to FocusNodes using named methods - safely with try-catch
    try {
      phoneFocusNode.addListener(_phoneFocusListener);
      cccdFocusNode.addListener(_cccdFocusListener);
    } catch (e) {
      debugPrint('Error adding focus listeners: $e');
    }

    // Kiểm tra lỗi ban đầu cho số điện thoại và CCCD
    _validatePhone(phoneController.text);
    _validateCccd(cccdController.text);
  }

  @override
  void dispose() {
    try {
      // Remove the specific listeners before disposing
      phoneFocusNode.removeListener(_phoneFocusListener);
      cccdFocusNode.removeListener(_cccdFocusListener);
    } catch (e) {
      debugPrint('Error removing FocusNode listeners: $e');
    }
    // Dispose all resources safely with try-catch
    try {
      phoneController.dispose();
      birthdateController.dispose();
      cccdController.dispose();
      nameController.dispose();
      emailController.dispose();
      studentCodeController.dispose();
      hometownController.dispose();
      phoneFocusNode.dispose();
      cccdFocusNode.dispose();
      phoneError.dispose();
      cccdError.dispose();
    } catch (e) {
      debugPrint('Error disposing resources: $e');
    }
    super.dispose();
  }

  // Hàm kiểm tra số điện thoại
  void _validatePhone(String value) {
    if (!_phoneTouched) return;
    if (value.isEmpty) {
      phoneError.value = "Số điện thoại không được để trống";
    } else if (value.length < 10 || value.length > 12 || !RegExp(r'^\d+$').hasMatch(value)) {
      phoneError.value = "Số điện thoại phải từ 10 đến 12 chữ số";
    } else {
      phoneError.value = null;
    }
  }

  // Hàm kiểm tra CCCD
  void _validateCccd(String value) {
    if (!_cccdTouched) return;
    if (value.isEmpty) {
      cccdError.value = "CCCD không được để trống";
    } else if (value.length != 12 || !RegExp(r'^\d{12}$').hasMatch(value)) {
      cccdError.value = "CCCD phải đúng 12 chữ số";
    } else {
      cccdError.value = null;
    }
  }

  // Kiểm tra xem có lỗi nào trong các trường nhập liệu
  bool get _hasErrors {
    return phoneError.value != null || cccdError.value != null;
  }

  // Hàm mở date picker để chọn ngày sinh
  Future<void> _pickBirthdate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    // Cập nhật ngày sinh vào controller
    if (pickedDate != null && mounted) {
      String formattedDate = DateFormat('dd-MM-yyyy').format(pickedDate);
      setState(() {
        birthdateController.text = formattedDate;
      });
    }
  }

  // Hàm lưu thay đổi hồ sơ
  Future<void> _saveChanges() async {
    setState(() {
      _phoneTouched = true;
      _cccdTouched = true;
    });
    _validatePhone(phoneController.text);
    _validateCccd(cccdController.text);

    // Ngăn lưu nếu có lỗi
    if (_hasErrors) return;

    // Kiểm tra ngày sinh không được để trống
    if (birthdateController.text.isEmpty) {
      _showCustomDialog(
        isSuccess: false,
        title: "Error",
        message: "Ngày sinh không được để trống",
      );
      return;
    }
    
    // Validate ngày sinh
    String formattedDate;
    try {
      // Kiểm tra xem ngày sinh có đúng định dạng dd-MM-yyyy không
      final dateText = birthdateController.text.trim();
      DateTime date;
      
      if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(dateText)) {
        // Đã là định dạng dd-MM-yyyy (định dạng hiển thị và gửi cho BE)
        date = DateFormat('dd-MM-yyyy').parse(dateText);
        formattedDate = dateText;
      } else if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateText)) {
        // Định dạng yyyy-MM-dd cần chuyển sang dd-MM-yyyy
        date = DateFormat('yyyy-MM-dd').parse(dateText);
        formattedDate = DateFormat('dd-MM-yyyy').format(date);
      } else {
        // Thử parse các định dạng khác
        date = DateTime.parse(dateText);
        formattedDate = DateFormat('dd-MM-yyyy').format(date);
      }
      
      // Kiểm tra ngày sinh không được là tương lai
      final today = DateTime.now();
      if (date.isAfter(today)) {
        _showCustomDialog(
          isSuccess: false,
          title: "Error",
          message: "Ngày sinh không được là ngày trong tương lai",
        );
        return;
      }
      
      debugPrint('Date formatted as: $formattedDate');
    } catch (e) {
      // Hiển thị lỗi nếu ngày sinh không hợp lệ
      _showCustomDialog(
        isSuccess: false,
        title: "Error",
        message: "Ngày sinh không hợp lệ: ${e.toString()}",
      );
      return;
    }

    // Trim và validate tất cả dữ liệu trước khi gửi đi
    final phone = phoneController.text.trim();
    final cccd = cccdController.text.trim();
    final fullname = nameController.text.trim();
    final email = emailController.text.trim();
    final studentCode = studentCodeController.text.trim();
    final hometown = hometownController.text.trim();
    
    // Kiểm tra các trường bắt buộc không được để trống sau khi trim
    if (fullname.isEmpty) {
      _showCustomDialog(isSuccess: false, title: "Error", message: "Họ và tên không được để trống");
      return;
    }
    if (email.isEmpty) {
      _showCustomDialog(isSuccess: false, title: "Error", message: "Email không được để trống");
      return;
    }
    if (phone.isEmpty) {
      _showCustomDialog(isSuccess: false, title: "Error", message: "Số điện thoại không được để trống");
      return;
    }
    if (cccd.isEmpty) {
      _showCustomDialog(isSuccess: false, title: "Error", message: "CCCD không được để trống");
      return;
    }
    if (studentCode.isEmpty) {
      _showCustomDialog(isSuccess: false, title: "Error", message: "Mã sinh viên không được để trống");
      return;
    }
    if (hometown.isEmpty) {
      _showCustomDialog(isSuccess: false, title: "Error", message: "Quê quán không được để trống");
      return;
    }

    // In log để debug
    debugPrint('Sending profile update with:');
    debugPrint('dateOfBirth: $formattedDate');
    debugPrint('phone: $phone, cccd: $cccd');
    debugPrint('fullname: $fullname, email: $email');
    debugPrint('studentCode: $studentCode, hometown: $hometown');

    // Hiển thị dialog đang xử lý
    _showCustomDialog(
      isSuccess: true,
      title: "Đang xử lý",
      message: "Đang cập nhật thông tin hồ sơ...",
      showLoading: true,
    );

    // Gửi sự kiện cập nhật hồ sơ người dùng với dữ liệu đã được chuẩn hóa
    context.read<AuthBloc>().add(UpdateUserProfileEvent(
      phone: phone,
      dateOfBirth: formattedDate, // Sử dụng định dạng dd-MM-yyyy cho BE
      cccd: cccd,
      fullname: fullname,
      email: email,
      studentCode: studentCode,
      hometown: hometown,
    ));
  }

  // Hàm hiển thị dialog thông báo
  void _showCustomDialog({
    required bool isSuccess,
    required String title,
    required String message,
    bool showLoading = false,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !showLoading,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        contentPadding: EdgeInsets.all(ResponsiveUtils.wp(context, 5)),
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
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hiển thị loading hoặc biểu tượng thành công/lỗi
              showLoading
                  ? const CircularProgressIndicator()
                  : Icon(
                      isSuccess ? Icons.check_circle : Icons.error,
                      color: isSuccess ? Colors.green : Colors.red,
                      size: ResponsiveUtils.sp(context, 50),
                    ),
              const SizedBox(height: 20),
              // Tiêu đề dialog
              Text(
                title,
                style: TextStyle(
                  fontSize: ResponsiveUtils.sp(context, 22),
                  fontWeight: FontWeight.bold,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 10),
              // Nội dung thông báo
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: ResponsiveUtils.sp(context, 16),
                  color: Colors.black87,
                ),
              ),
              if (!showLoading) ...[
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Nút "Thử lại" cho lỗi kết nối
                    if (message.contains("kết nối") || message.contains("server")) ...[
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
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
                    // Nút "OK" để đóng dialog
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        if (isSuccess) {
                          Get.back();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSuccess ? Colors.green : Colors.red,
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
      // Tự động đóng dialog sau 5 giây nếu không phải lỗi kết nối
      if (!showLoading && !message.contains("kết nối") && !message.contains("server")) {
        Future.delayed(const Duration(seconds: 5), () {
          if (mounted && Navigator.of(context).canPop()) {
            Navigator.of(context).pop();
            if (isSuccess) {
              Get.back();
            }
          }
        });
      }
    });
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

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          // Xử lý lỗi từ AuthBloc
          if (state is AuthError) {
            _showCustomDialog(
              isSuccess: false,
              title: "Lỗi",
              message: state.message,
            );
          }
          // Xử lý khi cập nhật hồ sơ thành công
          if (state is UserProfileUpdated) {
            final user = state.user;
            debugPrint('Profile updated: avatar_url=${user.avatarUrl}');
            debugPrint('Profile updated: date_of_birth=${user.dateOfBirth}');
            debugPrint('Profile updated: phone=${user.phone}, cccd=${user.cccd}');
            debugPrint('Profile updated: fullname=${user.fullname}');
            debugPrint('Profile updated: studentCode=${user.studentCode}, hometown=${user.hometown}');
            
            if (mounted) {
              setState(() {
                isFetching = true;
              });
            }
            
            // AuthBloc đã tự động gọi GetUserProfileEvent trong _onUpdateUserProfile
            // Chúng ta chỉ cần đợi UserProfileLoaded state
          }
          // Đóng dialog và quay lại khi dữ liệu được tải
          if (state is UserProfileLoaded && isFetching) {
            debugPrint('UserProfile loaded: avatar_url=${state.user.avatarUrl}');
            if (mounted) {
              setState(() {
                isFetching = false;
              });
            }
            
            // Cập nhật lại các controller với dữ liệu mới từ server
            phoneController.text = state.user.phone ?? "";
            nameController.text = state.user.fullname;
            emailController.text = state.user.email;
            studentCodeController.text = state.user.studentCode ?? "";
            hometownController.text = state.user.hometown ?? "";
            cccdController.text = state.user.cccd ?? "";
            
            // Kiểm tra và log thay đổi
            debugPrint('UserProfile loaded: studentCode=${state.user.studentCode}, hometown=${state.user.hometown}');
            
            if (state.user.dateOfBirth != null && state.user.dateOfBirth!.isNotEmpty) {
              try {
                // Try both formats
                DateTime date;
                if (RegExp(r'^\d{4}-\d{2}-\d{2} ?$').hasMatch(state.user.dateOfBirth!)) {
                  date = DateFormat('yyyy-MM-dd').parse(state.user.dateOfBirth!);
                } else if (RegExp(r'^\d{2}-\d{2}-\d{4} ?$').hasMatch(state.user.dateOfBirth!)) {
                  date = DateFormat('dd-MM-yyyy').parse(state.user.dateOfBirth!);
                } else {
                  date = DateTime.tryParse(state.user.dateOfBirth!) ?? DateTime.now();
                }
                birthdateController.text = DateFormat('dd-MM-yyyy').format(date);
              } catch (e) {
                birthdateController.text = state.user.dateOfBirth!;
              }
            }
            
            // Hiển thị thông báo thành công chỉ khi thực sự được cập nhật
            Navigator.of(context).pop(); // Đóng dialog loading
            if (state.user.studentCode == null || state.user.hometown == null) {
              _showCustomDialog(
                isSuccess: false, 
                title: "Lưu ý",
                message: "Dữ liệu không được cập nhật đầy đủ trên server. Hãy kiểm tra lại hoặc liên hệ admin.",
              );
            } else {
              _showCustomDialog(
                isSuccess: true,
                title: "Thành công",
                message: "Hồ sơ đã được cập nhật thành công.",
              );
            }
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          // Final safety check - remove unused variable
          return Stack(
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
                  constraints: const BoxConstraints(maxWidth: 600),
                  margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.90),
                    borderRadius: BorderRadius.circular(28),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                    child: SingleChildScrollView(
                      child: Column(
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
                                'Chỉnh sửa hồ sơ',
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
                          _buildUserInfoEditField(
                            text: 'Họ và tên',
                            child: TextFormField(
                              controller: nameController,
                              style: const TextStyle(color: Colors.black87),
                              decoration: _inputDecoration('Nhập họ và tên'),
                            ),
                          ),
                          _buildUserInfoEditField(
                            text: 'Email',
                            child: TextFormField(
                              controller: emailController,
                              style: const TextStyle(color: Colors.black87),
                              decoration: _inputDecoration('Nhập email'),
                            ),
                          ),
                          _buildUserInfoEditField(
                            text: 'Số điện thoại',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: phoneController,
                                  style: const TextStyle(color: Colors.black87),
                                  focusNode: phoneFocusNode,
                                  onEditingComplete: () {
                                    _validatePhone(phoneController.text);
                                    FocusScope.of(context).nextFocus();
                                  },
                                  decoration: _inputDecoration('Nhập số điện thoại'),
                                ),
                                ValueListenableBuilder<String?>(
                                  valueListenable: phoneError,
                                  builder: (context, error, child) {
                                    if (error == null) return const SizedBox.shrink();
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                                      child: Text(error, style: const TextStyle(color: Colors.red, fontSize: 13)),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          _buildUserInfoEditField(
                            text: 'Ngày sinh',
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    enabled: false,
                                    controller: birthdateController,
                                    style: const TextStyle(color: Colors.black87),
                                    decoration: _inputDecoration('Chọn ngày sinh'),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _pickBirthdate,
                                  icon: const Icon(Icons.calendar_today, color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                          _buildUserInfoEditField(
                            text: 'CCCD',
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextFormField(
                                  controller: cccdController,
                                  style: const TextStyle(color: Colors.black87),
                                  focusNode: cccdFocusNode,
                                  onEditingComplete: () {
                                    _validateCccd(cccdController.text);
                                    FocusScope.of(context).nextFocus();
                                  },
                                  decoration: _inputDecoration('Nhập số CCCD'),
                                ),
                                ValueListenableBuilder<String?>(
                                  valueListenable: cccdError,
                                  builder: (context, error, child) {
                                    if (error == null) return const SizedBox.shrink();
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 4.0, left: 8.0),
                                      child: Text(error, style: const TextStyle(color: Colors.red, fontSize: 13)),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                          _buildUserInfoEditField(
                            text: 'Mã sinh viên',
                            child: TextFormField(
                              controller: studentCodeController,
                              style: const TextStyle(color: Colors.black87),
                              decoration: _inputDecoration('Nhập mã sinh viên'),
                            ),
                          ),
                          _buildUserInfoEditField(
                            text: 'Quê quán',
                            child: TextFormField(
                              controller: hometownController,
                              style: const TextStyle(color: Colors.black87),
                              decoration: _inputDecoration('Nhập quê quán'),
                            ),
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
                                child: ElevatedButton(
                                  onPressed: _hasErrors ? null : _saveChanges,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                    elevation: 0,
                                    backgroundColor: _hasErrors
                                      ? Colors.grey
                                      : const Color(0xFF3B82F6), // fallback to blue
                                  ),
                                  child: state is AuthLoading
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
          );
        },
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.7),
      contentPadding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.wp(context, 5), 
        vertical: ResponsiveUtils.hp(context, 2)
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(ResponsiveUtils.wp(context, 3.5)),
        borderSide: BorderSide.none,
      ),
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey,
        fontSize: ResponsiveUtils.sp(context, 14)
      ),
    );
  }

  // Hàm xây dựng trường nhập liệu
  Widget _buildUserInfoEditField({
    required String text,
    required Widget child,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.hp(context, 1)),
      child: Container(
        padding: EdgeInsets.all(ResponsiveUtils.wp(context, 4)),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.withOpacity(0.2), width: 1.5),
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
            // Nhãn của trường
            Text(
              text,
              style: TextStyle(
                fontSize: ResponsiveUtils.sp(context, 16),
                color: Colors.grey,
              ),
            ),
            SizedBox(height: ResponsiveUtils.hp(context, 1)),
            // Widget con (TextFormField hoặc Row)
            child,
          ],
        ),
      ),
    );
  }
}