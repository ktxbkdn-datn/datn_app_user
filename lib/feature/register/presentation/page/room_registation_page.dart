import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';

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
  String? _numberOfPeopleError;

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
    return Scaffold(
      body: Stack(
        children: [
          // Glassmorphism Background
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
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Expanded(
                          child: Text(
                            "Đăng ký phòng",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: AppColors.cardBackground,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: AppColors.shadowColor,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
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
                            snackPosition: SnackPosition.BOTTOM,
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
                              const Text(
                                "Thông tin phòng",
                                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                decoration: BoxDecoration(
                                  color: AppColors.inputFill,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Phòng: ${widget.room.name}',
                                      style: const TextStyle(color: AppColors.textPrimary),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Khu vực: ${widget.room.areaDetails?.name ?? 'N/A'}',
                                      style: const TextStyle(color: AppColors.textPrimary),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              _buildFormField(
                                label: "Họ và tên",
                                controller: _nameController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Họ và tên không được để trống";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildFormField(
                                label: "Email",
                                controller: _emailController,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Email không được để trống";
                                  }
                                  if (!RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA.Z0-9-.]+$').hasMatch(value)) {
                                    return "Định dạng email không hợp lệ";
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              _buildFormField(
                                label: "Số điện thoại",
                                controller: _phoneController,
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
                              const Text(
                                "Số lượng người",
                                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: _numberOfPeople.toString(),
                                      keyboardType: TextInputType.number,
                                      style: const TextStyle(color: AppColors.textPrimary),
                                      decoration: InputDecoration(
                                        filled: true,
                                        fillColor: AppColors.inputFill,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide.none,
                                          borderRadius: BorderRadius.circular(50),
                                        ),
                                        errorText: _numberOfPeopleError,
                                      ),
                                      validator: (value) {
                                        if (value == null || value.trim().isEmpty) {
                                          return "Số lượng người không được để trống";
                                        }
                                        int? num = int.tryParse(value);
                                        if (num == null || num < 1) {
                                          return "Số lượng người phải là số nguyên dương";
                                        }
                                        return null;
                                      },
                                      onChanged: (value) {
                                        setState(() {
                                          int? num = int.tryParse(value);
                                          _numberOfPeople = num ?? 1;
                                          int availableSlots = widget.room.capacity - widget.room.currentPersonNumber;
                                          if (_numberOfPeople > availableSlots) {
                                            _numberOfPeopleError = 'Chỉ còn $availableSlots chỗ khả dụng';
                                          } else {
                                            _numberOfPeopleError = null;
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        if (_numberOfPeople > 1) _numberOfPeople--;
                                        int availableSlots = widget.room.capacity - widget.room.currentPersonNumber;
                                        if (_numberOfPeople > availableSlots) {
                                          _numberOfPeopleError = 'Chỉ còn $availableSlots chỗ khả dụng';
                                        } else {
                                          _numberOfPeopleError = null;
                                        }
                                      });
                                    },
                                    icon: const Icon(Icons.remove, color: AppColors.textPrimary),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _numberOfPeople++;
                                        int availableSlots = widget.room.capacity - widget.room.currentPersonNumber;
                                        if (_numberOfPeople > availableSlots) {
                                          _numberOfPeopleError = 'Chỉ còn $availableSlots chỗ khả dụng';
                                        } else {
                                          _numberOfPeopleError = null;
                                        }
                                      });
                                    },
                                    icon: const Icon(Icons.add, color: AppColors.textPrimary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                "Thông tin bổ sung",
                                style: TextStyle(fontSize: 16, color: AppColors.textSecondary),
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                child: TextFormField(
                                  controller: _informationController,
                                  style: const TextStyle(color: AppColors.textPrimary),
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: AppColors.inputFill,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Center(
                                child: state is RegistrationLoading
                                    ? const CircularProgressIndicator()
                                    : ElevatedButton(
                                  onPressed: _submitForm,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.buttonPrimary,
                                    foregroundColor: AppColors.cardBackground,
                                    minimumSize: const Size(double.infinity, 48),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                  child: const Text("Đăng ký"),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              filled: true,
              fillColor: AppColors.inputFill,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              border: OutlineInputBorder(
                borderSide: BorderSide.none,
                borderRadius: BorderRadius.circular(50),
              ),
            ),
            validator: validator,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}