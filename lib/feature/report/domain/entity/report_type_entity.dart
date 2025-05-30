
class ReportTypeEntity {
  final int reportTypeId;
  final String name;

  const ReportTypeEntity({
    required this.reportTypeId,
    required this.name,
  });

  Map<String, dynamic> toJson() {
    return {
      'report_type_id': reportTypeId,
      'name': name,
    };
  }

  factory ReportTypeEntity.fromJson(Map<String, dynamic> json) {
    return ReportTypeEntity(
      reportTypeId: json['report_type_id'] as int,
      name: json['name'] as String,
    );
  }
}