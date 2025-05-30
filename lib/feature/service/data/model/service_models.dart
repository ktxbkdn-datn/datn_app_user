import 'package:equatable/equatable.dart';
import '../../domain/entity/service_entities.dart';

class ServiceModel extends Equatable {
  final int serviceId;
  final String name;
  final String unit;

  const ServiceModel({
    required this.serviceId,
    required this.name,
    required this.unit,
  });

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    return ServiceModel(
      serviceId: json['service_id'] as int,
      name: json['name'] as String,
      unit: json['unit'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'service_id': serviceId,
      'name': name,
      'unit': unit,
    };
  }

  Service toEntity() {
    return Service(
      serviceId: serviceId,
      name: name,
      unit: unit,
    );
  }

  @override
  List<Object> get props => [serviceId, name, unit];
}