import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
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
  final String? studentCode;
  final String? hometown;

  const UserEntity({
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

  factory UserEntity.fromJson(Map<String, dynamic> json) {
    return UserEntity(
      userId: json['user_id'] as int?,
      fullname: json['fullname'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      cccd: json['CCCD'] as String?,
      className: json['class_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] as String?,
      isDeleted: json['is_deleted'] as bool? ?? false,
      deletedAt: json['deleted_at'] as String?,
      version: json['version'] as int?,
      studentCode: json['student_code'] as String?,
      hometown: json['hometown'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'fullname': fullname,
      'email': email,
      'phone': phone,
      'date_of_birth': dateOfBirth,
      'CCCD': cccd,
      'class_name': className,
      'avatar_url': avatarUrl,
      'created_at': createdAt,
      'is_deleted': isDeleted,
      'deleted_at': deletedAt,
      'version': version,
      'student_code': studentCode,
      'hometown': hometown,
    };
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
}