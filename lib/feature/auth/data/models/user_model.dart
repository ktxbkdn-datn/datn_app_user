import 'package:equatable/equatable.dart';
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
      print('Parsing avatar_url: ${json['avatar_url']}');
      final avatarUrl = json['avatar_url'] as String?;
      print('Parsing created_at: ${json['created_at']}');
      final createdAt = json['created_at'] as String?;
      print('Parsing is_deleted: ${json['is_deleted']}');
      final isDeleted = json['is_deleted'] as bool? ?? false;
      print('Parsing deleted_at: ${json['deleted_at']}');
      final deletedAt = json['deleted_at'] as String?;
      print('Parsing version: ${json['version']}');
      final version = json['version'] as int?;

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
      );
    } catch (e) {
      print('Error parsing UserModel: $e');
      rethrow;
    }
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
    };
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
  ];
}