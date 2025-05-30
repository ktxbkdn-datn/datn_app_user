

import '../../domain/entity/report_image_entity.dart';

class ReportImageModel extends ReportImageEntity {
  ReportImageModel({
    required int imageId,
    int? reportId,
    required String imageUrl,
    String? altText,
    String? uploadedAt,
    required bool isPrimary,
    required int sortOrder,
    required bool isDeleted,
    String? deletedAt,
    required String fileType,
  }) : super(
    imageId: imageId,
    reportId: reportId,
    imageUrl: imageUrl,
    altText: altText,
    uploadedAt: uploadedAt,
    isPrimary: isPrimary,
    sortOrder: sortOrder,
    isDeleted: isDeleted,
    deletedAt: deletedAt,
    fileType: fileType,
  );

  factory ReportImageModel.fromJson(Map<String, dynamic> json) {
    return ReportImageModel(
      imageId: json['imageId'] as int? ?? 0,  // Gán giá trị mặc định nếu null
      reportId: json['reportId'] as int?,  // Có thể là null
      imageUrl: json['imageUrl'] as String? ?? '',  // Gán giá trị mặc định nếu null
      altText: json['altText'] as String?,  // Có thể là null
      uploadedAt: json['uploadedAt'] as String?,  // Có thể là null
      isPrimary: json['isPrimary'] as bool? ?? false,  // Gán giá trị mặc định nếu null
      sortOrder: json['sortOrder'] as int? ?? 0,  // Gán giá trị mặc định nếu null
      isDeleted: json['isDeleted'] as bool? ?? false,  // Gán giá trị mặc định nếu null
      deletedAt: json['deletedAt'] as String?,  // Có thể là null
      fileType: json['fileType'] as String? ?? '',  // Gán giá trị mặc định nếu null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageId': imageId,
      'reportId': reportId,
      'imageUrl': imageUrl,
      'altText': altText,
      'uploadedAt': uploadedAt,
      'isPrimary': isPrimary,
      'sortOrder': sortOrder,
      'isDeleted': isDeleted,
      'deletedAt': deletedAt,
      'fileType': fileType,
    };
  }
}