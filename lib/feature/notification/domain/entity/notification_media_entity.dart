class NotificationMedia {
  final int mediaId;
  final int notificationId;
  final String mediaUrl;
  final String? altText;
  final String? uploadedAt;
  final bool isPrimary;
  final int sortOrder;
  final bool isDeleted;
  final String? deletedAt;
  final String fileType;
  final int? fileSize;

  NotificationMedia({
    required this.mediaId,
    required this.notificationId,
    required this.mediaUrl,
    this.altText,
    this.uploadedAt,
    required this.isPrimary,
    required this.sortOrder,
    required this.isDeleted,
    this.deletedAt,
    required this.fileType,
    this.fileSize,
  });

  NotificationMedia copyWith({
    int? mediaId,
    int? notificationId,
    String? mediaUrl,
    String? altText,
    String? uploadedAt,
    bool? isPrimary,
    int? sortOrder,
    bool? isDeleted,
    String? deletedAt,
    String? fileType,
    int? fileSize,
  }) {
    return NotificationMedia(
      mediaId: mediaId ?? this.mediaId,
      notificationId: notificationId ?? this.notificationId,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      altText: altText ?? this.altText,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      isPrimary: isPrimary ?? this.isPrimary,
      sortOrder: sortOrder ?? this.sortOrder,
      isDeleted: isDeleted ?? this.isDeleted,
      deletedAt: deletedAt ?? this.deletedAt,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
    );
  }
}