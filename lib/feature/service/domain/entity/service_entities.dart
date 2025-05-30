import 'package:equatable/equatable.dart';

class Service extends Equatable {
  final int serviceId;
  final String name;
  final String unit;

  const Service({
    required this.serviceId,
    required this.name,
    required this.unit,
  });

  @override
  List<Object> get props => [serviceId, name, unit];
}