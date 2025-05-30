class AreaEntity {
  final int areaId;
  final String name;
  final String? description;
  final String? createdAt;
  final String? updatedAt;

  const AreaEntity({
    required this.areaId,
    required this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  // Chuyển đổi thành JSON
  Map<String, dynamic> toJson() {
    return {
      'area_id': areaId, // Đồng bộ với AreaModel
      'name': name,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  // Tạo đối tượng từ JSON
  factory AreaEntity.fromJson(Map<String, dynamic> json) {
    return AreaEntity(
      areaId: json['area_id'] as int, // Đồng bộ với AreaModel
      name: json['name'] as String,
      description: json['description'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}