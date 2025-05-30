import '../../domain/entity/report_entity.dart';

class ReportModel extends ReportEntity {
  ReportModel({
    required int reportId,
    required int roomId,
    required int userId,
    required String title,
    required String status,
    String? description,
    int? reportTypeId,
    String? createdAt,
    String? updatedAt,
    String? resolvedAt,
    String? closedAt,
    Map<String, dynamic>? roomDetails,
    Map<String, dynamic>? userDetails,
  }) : super(
    reportId: reportId,
    roomId: roomId,
    userId: userId,
    title: title,
    status: status,
    description: description,
    reportTypeId: reportTypeId,
    createdAt: createdAt,
    updatedAt: updatedAt,
    resolvedAt: resolvedAt,
    closedAt: closedAt,
    roomDetails: roomDetails,
    userDetails: userDetails,
  );

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
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

  @override
  Map<String, dynamic> toJson() {
    return super.toJson();
  }
}