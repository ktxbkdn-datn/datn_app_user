

import '../../domain/entity/report_type_entity.dart';

class ReportTypeModel extends ReportTypeEntity {
  ReportTypeModel({
    required int reportTypeId,
    required String name,
  }) : super(reportTypeId: reportTypeId, name: name);

  factory ReportTypeModel.fromJson(Map<String, dynamic> json) {
    return ReportTypeModel(
      reportTypeId: json['report_type_id'] as int,
      name: json['name'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'report_type_id': reportTypeId,
      'name': name,
    };
  }
}