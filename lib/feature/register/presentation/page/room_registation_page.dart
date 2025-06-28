import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

import 'package:datn_app/common/components/app_background.dart';
import '../../../../common/utils/responsive_utils.dart';
import '../../../../common/widgets/no_spell_check_text.dart';

import '../../../../common/constant/colors.dart';
import '../../../room/domain/entities/room_entity.dart';
import '../bloc/registration_bloc.dart';
import '../bloc/registration_event.dart';
import '../bloc/registration_state.dart';

class RoomRegistrationPage extends StatelessWidget {
  final RoomEntity room;

  const RoomRegistrationPage({
    super.key,
    required this.room,
  });

  @override
  Widget build(BuildContext context) {
    return RoomRegistrationView(room: room);
  }
}

class RoomRegistrationView extends StatefulWidget {
  final RoomEntity room;

  const RoomRegistrationView({super.key, required this.room});

  @override
  State<RoomRegistrationView> createState() => _RoomRegistrationViewState();
}

class _RoomRegistrationViewState extends State<RoomRegistrationView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _informationController = TextEditingController();
  int _numberOfPeople = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _informationController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate()) return;

    context.read<RegistrationBloc>().add(
      CreateRegistrationEvent(
        nameStudent: _nameController.text,
        email: _emailController.text,
        phoneNumber: _phoneController.text,
        roomId: widget.room.roomId,
        information: _informationController.text.isNotEmpty ? _informationController.text : null,
        numberOfPeople: _numberOfPeople,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Stack(
        children: [
          BlocConsumer<RegistrationBloc, RegistrationState>(
            listener: (context, state) {
              if (state is RegistrationSuccess) {
                Get.snackbar(
                  'Thành công',
                  'Đăng ký phòng thành công!',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
                Navigator.of(context).pop();
              } else if (state is RegistrationFailure) {
                Get.snackbar(
                  'Thất bại',
                  state.error,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                  duration: const Duration(seconds: 2),
                );
              }
            },
            builder: (context, state) {
              if (state is RegistrationLoading) {
                return Container(
                  color: Colors.black.withOpacity(0.5),
                  child: Center(
                    child: Card(
                      color: Colors.white,
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: ResponsiveUtils.wp(context, 6),
                          vertical: ResponsiveUtils.hp(context, 2)
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: ResponsiveUtils.wp(context, 6),
                              height: ResponsiveUtils.wp(context, 6),
                              child: CircularProgressIndicator(strokeWidth: 3, color: Colors.blue),
                            ),
                            SizedBox(width: ResponsiveUtils.wp(context, 4)),
                            NoSpellCheckText(
                              text: 'Đang đăng ký...', 
                              style: TextStyle(fontSize: ResponsiveUtils.sp(context, 16))
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }
              return SafeArea(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.wp(context, 4),
                    vertical: ResponsiveUtils.hp(context, 2)
                  ),
                  child: Column(
                    children: [
                      // Đưa Row tiêu đề có nút back lên trên cùng
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: ResponsiveUtils.sp(context, 24)),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          Expanded(
                            child: NoSpellCheckText(
                              text: "Đăng ký phòng",
                              style: TextStyle(
                                fontSize: ResponsiveUtils.sp(context, 20),
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: ResponsiveUtils.hp(context, 2.2)),
                      // Room Info Card
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          gradient: LinearGradient(
                            colors: [Colors.white.withOpacity(0.45), Colors.white.withOpacity(0.25)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                          border: Border.all(color: Colors.white.withOpacity(0.18), width: 1.2),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(ResponsiveUtils.wp(context, 5)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,                     
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: ResponsiveUtils.wp(context, 14),
                                    height: ResponsiveUtils.wp(context, 14),
                                    decoration: BoxDecoration(
                                      color: Colors.blue.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(Icons.meeting_room, color: Colors.blue, size: ResponsiveUtils.sp(context, 28)),
                                  ),
                                  SizedBox(width: ResponsiveUtils.wp(context, 4)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        NoSpellCheckText(
                                          text: "Phòng: ${widget.room.name}", 
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600, 
                                            fontSize: ResponsiveUtils.sp(context, 17), 
                                            color: Colors.black87, 
                                            decoration: TextDecoration.none
                                          )
                                        ),
                                        NoSpellCheckText(
                                          text: "Sức chứa: ${widget.room.capacity} người", 
                                          style: TextStyle(
                                            fontSize: ResponsiveUtils.sp(context, 13), 
                                            color: Colors.black54, 
                                            decoration: TextDecoration.none
                                          )
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: ResponsiveUtils.hp(context, 1.8)),
                              Row(
                                children: [
                                  Container(
                                    width: ResponsiveUtils.wp(context, 14),
                                    height: ResponsiveUtils.wp(context, 14),
                                    decoration: BoxDecoration(
                                      color: Colors.purple.withOpacity(0.18),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Icon(Icons.location_on, color: Colors.purple, size: ResponsiveUtils.sp(context, 28)),
                                  ),
                                  SizedBox(width: ResponsiveUtils.wp(context, 4)),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,                
                                      children: [
                                        NoSpellCheckText(
                                          text: "Khu vực: ${widget.room.areaDetails?.name ?? "N/A"}", 
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600, 
                                            fontSize: ResponsiveUtils.sp(context, 16), 
                                            color: Colors.black87, 
                                            decoration: TextDecoration.none
                                          )
                                        ),
                                        NoSpellCheckText(
                                          text: "Còn trống: ${widget.room.capacity - widget.room.currentPersonNumber} chỗ", 
                                          style: TextStyle(
                                            fontSize: ResponsiveUtils.sp(context, 13), 
                                            color: Colors.black54, 
                                            decoration: TextDecoration.none
                                          )
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.hp(context, 3.5)),
                      Card(
                        color: Colors.white.withOpacity(0.35),
                        elevation: 12,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                            child: Padding(
                              padding: EdgeInsets.all(ResponsiveUtils.wp(context, 6)),
                              child: BlocConsumer<RegistrationBloc, RegistrationState>(
                                listener: (context, state) {
                                  if (state is RegistrationSuccess) {
                                    Get.snackbar(
                                      'Thành công',
                                      state.message,
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor: Colors.green,
                                      colorText: Colors.white,
                                      duration: const Duration(seconds: 3),
                                    );
                                    Navigator.of(context).pop();
                                  } else if (state is RegistrationFailure) {
                                    Get.snackbar(
                                      'Lỗi',
                                      state.error,
                                      snackPosition: SnackPosition.TOP,
                                      backgroundColor: Colors.red,
                                      colorText: Colors.white,
                                      duration: const Duration(seconds: 3),
                                    );
                                  }
                                },
                                builder: (context, state) {
                                  return Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: ResponsiveUtils.hp(context, 2.5)),
                                        _buildModernFormField(
                                          label: "Họ và tên",
                                          controller: _nameController,
                                          icon: Icons.person,
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return "Họ và tên không được để trống";
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        _buildModernFormField(
                                          label: "Email",
                                          controller: _emailController,
                                          icon: Icons.email,
                                          keyboardType: TextInputType.emailAddress,
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return "Email không được để trống";
                                            }
                                            if (!RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$').hasMatch(value)) {
                                              return "Định dạng email không hợp lệ";
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        _buildModernFormField(
                                          label: "Số điện thoại",
                                          controller: _phoneController,
                                          icon: Icons.phone,
                                          keyboardType: TextInputType.phone,
                                          validator: (value) {
                                            if (value == null || value.trim().isEmpty) {
                                              return "Số điện thoại không được để trống";
                                            }
                                            if (value.length < 10 || value.length > 12 || !RegExp(r'^\d+$').hasMatch(value)) {
                                              return "Số điện thoại phải từ 10 đến 12 chữ số";
                                            }
                                            return null;
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        _buildModernFormField(
                                          label: "Thông tin bổ sung (không bắt buộc)",
                                          controller: _informationController,
                                          icon: Icons.info_outline,
                                          maxLines: 3,
                                        ),
                                        const SizedBox(height: 24),
                                        SizedBox(
                                          width: double.infinity,
                                          height: ResponsiveUtils.hp(context, 6),
                                          child: ElevatedButton(
                                            onPressed: state is RegistrationLoading ? null : _submitForm,
                                            style: ElevatedButton.styleFrom(
                                              padding: EdgeInsets.symmetric(vertical: ResponsiveUtils.hp(context, 1.5)),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(32),
                                              ),
                                              // Đổi màu nền nút đăng ký thành màu đặc, không có lớp phủ
                                              backgroundColor: Colors.blueAccent, // màu đặc
                                              elevation: 6,
                                            ),
                                            child: state is RegistrationLoading
                                                ? Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      SizedBox(
                                                        width: ResponsiveUtils.wp(context, 5.5),
                                                        height: ResponsiveUtils.wp(context, 5.5),
                                                        child: CircularProgressIndicator(
                                                          color: Colors.white,
                                                          strokeWidth: 2.5,
                                                        ),
                                                      ),
                                                      SizedBox(width: ResponsiveUtils.wp(context, 3.5)),
                                                      NoSpellCheckText(
                                                        text: "Đang xử lý...", 
                                                        style: TextStyle(fontSize: ResponsiveUtils.sp(context, 16))
                                                      ),
                                                    ],
                                                  )
                                                : NoSpellCheckText(
                                                    text: "Đăng ký",
                                                    style: TextStyle(
                                                      fontSize: ResponsiveUtils.sp(context, 18), 
                                                      fontWeight: FontWeight.w600
                                                    ),
                                                  ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              );
            },
          ),
        ],
      ),
    );
  }

  // Thêm widget hỗ trợ cho form hiện đại
  Widget _buildModernFormField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    int maxLines = 1,
  }) {
    // Define a consistent border radius for both container and input decoration
    final borderRadius = BorderRadius.circular(24);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        NoSpellCheckText(
          text: label,
          style: TextStyle(
            fontSize: ResponsiveUtils.sp(context, 15), 
            color: AppColors.textSecondary, 
            fontWeight: FontWeight.w500
          ),
        ),
        SizedBox(height: ResponsiveUtils.hp(context, 1)),
        // Use a ClipRRect to ensure perfect clipping at the border radius
        ClipRRect(
          borderRadius: borderRadius,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: borderRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              style: TextStyle(
                color: AppColors.textPrimary, 
                fontSize: ResponsiveUtils.sp(context, 16)
              ),
              maxLines: maxLines,
              decoration: InputDecoration(
                prefixIcon: icon != null ? Icon(icon, color: Colors.blueAccent, size: ResponsiveUtils.sp(context, 22)) : null,
                hintText: label,
                hintStyle: TextStyle(
                  color: AppColors.textSecondary, 
                  fontSize: ResponsiveUtils.sp(context, 15)
                ),
                // Use the same border radius for input decoration
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: borderRadius,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: borderRadius,
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.blueAccent.withOpacity(0.5), width: 1.0),
                  borderRadius: borderRadius,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.wp(context, 4.5),
                  vertical: ResponsiveUtils.hp(context, 2.2)
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
              validator: validator,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
