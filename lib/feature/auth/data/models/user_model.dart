import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends Equatable {
  final int? userId;
  final String fullname;
  final String email;
  final String? phone;
  final String? dateOfBirth;
  final String? cccd;
  final String? className;
  final String? avatarUrl;
  final String? createdAt;
  final bool isDeleted;
  final String? deletedAt;
  final int? version;
  final String? studentCode; // thêm
  final String? hometown;    // thêm

  const UserModel({
    required this.userId,
    required this.fullname,
    required this.email,
    this.phone,
    this.dateOfBirth,
    this.cccd,
    this.className,
    this.avatarUrl,
    this.createdAt,
    required this.isDeleted,
    this.deletedAt,
    required this.version,
    this.studentCode,
    this.hometown,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    print('Parsing UserModel: $json');
    try {
      print('Parsing user_id: ${json['user_id']}');
      final userId = json['user_id'] as int?;
      print('Parsing fullname: ${json['fullname']}');
      final fullname = json['fullname'] as String? ?? '';
      print('Parsing email: ${json['email']}');
      final email = json['email'] as String? ?? '';
      print('Parsing phone: ${json['phone']}');
      final phone = json['phone'] as String?;
      print('Parsing date_of_birth: ${json['date_of_birth']}');
      final dateOfBirth = json['date_of_birth'] as String?;
      print('Parsing CCCD: ${json['CCCD']}');
      final cccd = json['CCCD'] as String?;
      print('Parsing class_name: ${json['class_name']}');
      final className = json['class_name'] as String?;
      
      // Transform avatar_url to use getAPIbaseUrl()
      print('Parsing avatar_url: ${json['avatar_url']}');
      String? avatarUrl = json['avatar_url'] as String?;
      /* Comment lại phần xử lý avatar URL để tránh lỗi 404
      if (avatarUrl != null) {
        // Extract the relative path (e.g., "/avatars/avatar_22_1748397724.171344.jpg")
        final baseUrl = getAPIbaseUrl();
        // Assuming the avatar URL follows the pattern: <base_url>/avatars/<filename>
        final relativePath = avatarUrl.split('/api/').last; // Get "avatars/avatar_22_1748397724.171344.jpg"
        avatarUrl = '$baseUrl/$relativePath'; // Construct new URL
        print('Transformed avatar_url: $avatarUrl');
      }
      */
      // Đặt avatarUrl thành null để không tải ảnh
      avatarUrl = null;

      print('Parsing created_at: ${json['created_at']}');
      final createdAt = json['created_at'] as String?;
      print('Parsing is_deleted: ${json['is_deleted']}');
      final isDeleted = json['is_deleted'] as bool? ?? false;
      print('Parsing deleted_at: ${json['deleted_at']}');
      final deletedAt = json['deleted_at'] as String?;
      print('Parsing version: ${json['version']}');
      final version = json['version'] as int?;
      print('Parsing student_code: ${json['student_code']}');
      final studentCode = json['student_code'] as String?;
      print('Parsing hometown: ${json['hometown']}');
      final hometown = json['hometown'] as String?;

      return UserModel(
        userId: userId,
        fullname: fullname,
        email: email,
        phone: phone,
        dateOfBirth: dateOfBirth,
        cccd: cccd,
        className: className,
        avatarUrl: avatarUrl,
        createdAt: createdAt,
        isDeleted: isDeleted,
        deletedAt: deletedAt,
        version: version,
        studentCode: studentCode,
        hometown: hometown,
      );
    } catch (e) {
      print('Error parsing UserModel: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    
    // Chỉ thêm các trường không null vào JSON và trim text values
    if (userId != null) json['user_id'] = userId;
    json['fullname'] = fullname.trim();
    
    // Email không được gửi trong PUT /me, chỉ dùng khi cần thiết
    // (Backend không hỗ trợ đổi email qua /me endpoint)
    // json['email'] = email.trim();
    
    // Chỉ thêm các trường có giá trị
    if (phone != null && phone!.trim().isNotEmpty) json['phone'] = phone!.trim();
    
    // Xử lý đặc biệt cho ngày sinh - có thể gửi theo định dạng dd-MM-yyyy
    // Backend sẽ tự parse và convert thành date object
    if (dateOfBirth != null && dateOfBirth!.trim().isNotEmpty) {
      // Nếu là định dạng yyyy-MM-dd, chuyển về dd-MM-yyyy
      if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(dateOfBirth!.trim())) {
        try {
          final date = DateFormat('yyyy-MM-dd').parse(dateOfBirth!.trim());
          json['date_of_birth'] = DateFormat('dd-MM-yyyy').format(date);
          print('Date converted from $dateOfBirth to ${json['date_of_birth']}');
        } catch (e) {
          print('Error converting date: $e');
          json['date_of_birth'] = dateOfBirth!.trim();
        }
      } else {
        // Nếu đã là định dạng dd-MM-yyyy hoặc định dạng khác, gửi nguyên
        json['date_of_birth'] = dateOfBirth!.trim();
      }
    }
    
    if (cccd != null && cccd!.trim().isNotEmpty) json['CCCD'] = cccd!.trim();
    if (className != null && className!.trim().isNotEmpty) json['class_name'] = className!.trim();
    
    // Không gửi avatar_url để tránh lỗi 404
    // if (avatarUrl != null && avatarUrl!.isNotEmpty) json['avatar_url'] = avatarUrl;
    
    // Các trường này do backend quản lý, không nên gửi khi update
    // if (createdAt != null) json['created_at'] = createdAt;
    // json['is_deleted'] = isDeleted;
    // if (deletedAt != null) json['deleted_at'] = deletedAt;
    
    // Chỉ gửi version nếu cần
    if (version != null) json['version'] = version;
    
    if (studentCode != null && studentCode!.trim().isNotEmpty) json['student_code'] = studentCode!.trim();
    if (hometown != null && hometown!.trim().isNotEmpty) json['hometown'] = hometown!.trim();
    
    // Log để debug
    print('UserModel.toJson: $json');
    
    return json;
  }

  UserEntity toEntity() {
    return UserEntity(
      userId: userId,
      fullname: fullname,
      email: email,
      phone: phone,
      dateOfBirth: dateOfBirth,
      cccd: cccd,
      className: className,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
      isDeleted: isDeleted,
      deletedAt: deletedAt,
      version: version,
      studentCode: studentCode,
      hometown: hometown,
    );
  }

  @override
  List<Object?> get props => [
    userId,
    fullname,
    email,
    phone,
    dateOfBirth,
    cccd,
    className,
    avatarUrl,
    createdAt,
    isDeleted,
    deletedAt,
    version,
    studentCode,
    hometown,
  ];
  
  @override
  String toString() {
    return 'UserModel{userId: $userId, fullname: $fullname, email: $email, phone: $phone, dateOfBirth: $dateOfBirth, cccd: $cccd, className: $className, studentCode: $studentCode, hometown: $hometown}';
  }
}