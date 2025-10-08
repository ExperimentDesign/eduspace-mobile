class Reservation {
  final int? id;
  final String title;
  final DateTime start;
  final DateTime end;
  final int? areaId;
  final int? teacherId;

  Reservation({
    this.id,
    required this.title,
    required this.start,
    required this.end,
    this.areaId,
    this.teacherId,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    int? parseInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return Reservation(
      id: parseInt(json['id']),
      title: json['title'] as String,
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
      areaId: parseInt(json['areaId']),
      teacherId: parseInt(json['teacherId']),
    );
  }

  Map<String, dynamic> toJson({bool forPost = false}) {
    final map = {
      'title': title,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
    if (!forPost) {
      if (id != null) map['id'] = id as String;
      if (areaId != null) map['areaId'] = areaId as String;
      if (teacherId != null) map['teacherId'] = teacherId as String;
    }
    return map;
  }
}
