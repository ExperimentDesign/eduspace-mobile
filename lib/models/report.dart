// lib/models/report.dart
class Report {
  final int? id;
  final String kindOfReport;
  final String description;
  final int resourceId;
  final DateTime createdAt;
  final String? status;

  Report({
    this.id,
    required this.kindOfReport,
    required this.description,
    required this.resourceId,
    required this.createdAt,
    this.status,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      id: json['id'],
      kindOfReport: json['kindOfReport'],
      description: json['description'],
      resourceId: json['resourceId'],
      createdAt: DateTime.parse(json['createdAt']),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'kindOfReport': kindOfReport,
      'description': description,
      'resourceId': resourceId,
      'createdAt': createdAt.toIso8601String(),
    };
    if (id != null) map['id'] = id as Object;
    if (status != null) map['status'] = status as Object;
    return map;
  }
}
