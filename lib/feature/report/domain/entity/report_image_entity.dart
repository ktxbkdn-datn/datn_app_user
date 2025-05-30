
class ReportImageEntity {
  final int imageId;
  final int? reportId;
  final String imageUrl;
  final String? altText;
  final String? uploadedAt;
  final bool isPrimary;
  final int sortOrder;
  final bool isDeleted;
  final String? deletedAt;
  final String fileType;

  const ReportImageEntity({
    required this.imageId,
    this.reportId,
    required this.imageUrl,
    this.altText,
    this.uploadedAt,
    required this.isPrimary,
    required this.sortOrder,
    required this.isDeleted,
    this.deletedAt,
    required this.fileType,
  });

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

  factory ReportImageEntity.fromJson(Map<String, dynamic> json) {
    return ReportImageEntity(
      imageId: json['imageId'] as int,
      reportId: json['reportId'] as int?,
      imageUrl: json['imageUrl'] as String,
      altText: json['altText'] as String?,
      uploadedAt: json['uploadedAt'] as String?,
      isPrimary: json['isPrimary'] as bool,
      sortOrder: json['sortOrder'] as int,
      isDeleted: json['isDeleted'] as bool,
      deletedAt: json['deletedAt'] as String?,
      fileType: json['fileType'] as String,
    );
  }
}