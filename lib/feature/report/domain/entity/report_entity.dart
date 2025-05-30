import 'package:equatable/equatable.dart';

class ReportEntity extends Equatable {
  final int reportId;
  final int roomId;
  final int userId;
  final String title;
  final String status;
  final String? description;
  final int? reportTypeId;
  final String? createdAt;
  final String? updatedAt;
  final String? resolvedAt;
  final String? closedAt;
  final Map<String, dynamic>? roomDetails;
  final Map<String, dynamic>? userDetails;

  const ReportEntity({
    required this.reportId,
    required this.roomId,
    required this.userId,
    required this.title,
    required this.status,
    this.description,
    this.reportTypeId,
    this.createdAt,
    this.updatedAt,
    this.resolvedAt,
    this.closedAt,
    this.roomDetails,
    this.userDetails,
  });

  @override
  List<Object?> get props => [
    reportId,
    roomId,
    userId,
    title,
    status,
    description,
    reportTypeId,
    createdAt,
    updatedAt,
    resolvedAt,
    closedAt,
    roomDetails,
    userDetails,
  ];

  Map<String, dynamic> toJson() {
    return {
      'report_id': reportId,
      'room_id': roomId,
      'user_id': userId,
      'title': title,
      'status': status,
      'description': description,
      'report_type_id': reportTypeId,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'resolved_at': resolvedAt,
      'closed_at': closedAt,
      'room_details': roomDetails,
      'user_details': userDetails,
    };
  }

  factory ReportEntity.fromJson(Map<String, dynamic> json) {
    return ReportEntity(
      reportId: json['report_id'] as int,
      roomId: json['room_id'] as int,
      userId: json['user_id'] as int,
      title: json['title'] as String,
      status: json['status'] as String,
      description: json['description'] as String?,
      reportTypeId: json['report_type_id'] as int?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      resolvedAt: json['resolved_at'] as String?,
      closedAt: json['closed_at'] as String?,
      roomDetails: json['room_details'] as Map<String, dynamic>?,
      userDetails: json['user_details'] as Map<String, dynamic>?,
    );
  }
}