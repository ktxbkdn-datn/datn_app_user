import '../../domain/entities/area_entity.dart';

class AreaModel extends AreaEntity {
  AreaModel({
    required int areaId,
    required String name,
    String? description,
    String? createdAt,
    String? updatedAt,
  }) : super(
    areaId: areaId,
    name: name,
    description: description,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      areaId: json['area_id'] as int,
      name: json['name'] as String,
      description: json['description']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'area_id': areaId,
      'name': name,
      'description': description,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}