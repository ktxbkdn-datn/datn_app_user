import 'package:equatable/equatable.dart';
import '../../domain/entity/notification_type_entity.dart';

class NotificationTypeModel extends Equatable {
  final int id;
  final String name;
  final String? description;
  final String status;
  final String? createdAt;

  NotificationTypeModel({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    this.createdAt,
  });

  factory NotificationTypeModel.fromJson(Map<String, dynamic> json) {
    return NotificationTypeModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'ROOM',
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'status': status,
      'created_at': createdAt,
    };
  }

  NotificationType toEntity() {
    return NotificationType(
      id: id,
      name: name,
      description: description,
      status: status,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, description, status, createdAt];
}