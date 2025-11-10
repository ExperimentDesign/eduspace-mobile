import 'teacher.dart';

class Meeting {
  final int? meetingId;
  final String title;
  final String description;
  final String date;
  final String start;
  final String end;
  final int administratorId;
  final int classroomId;
  final List<Teacher>? teachers;

  Meeting({
    this.meetingId,
    required this.title,
    required this.description,
    required this.date,
    required this.start,
    required this.end,
    required this.administratorId,
    required this.classroomId,
    this.teachers,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    // Helper to extract id whether the backend returns an int or a nested object
    int _extractId(dynamic value, List<String> possibleKeys) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      if (value is Map) {
        for (final key in possibleKeys) {
          final candidate = value[key];
          if (candidate is int) return candidate;
          if (candidate is String) {
            final parsed = int.tryParse(candidate);
            if (parsed != null) return parsed;
          }
        }
      }
      return 0;
    }

    final adminId = _extractId(json['administratorId'], ['administratorIdentifier', 'administratorId', 'id']);
    final classId = _extractId(json['classroomId'], ['classroomIdentifier', 'classroomId', 'id']);

    List<Teacher>? parsedTeachers;
    if (json['teachers'] is List) {
      parsedTeachers = (json['teachers'] as List)
          .where((e) => e != null)
          .map<Teacher>((e) => Teacher.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    }

    return Meeting(
      meetingId: json['meetingId'] is int ? json['meetingId'] as int : (json['meetingId'] is String ? int.tryParse(json['meetingId']) : null),
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      date: json['date'] as String? ?? '',
      start: json['start'] as String? ?? '',
      end: json['end'] as String? ?? '',
      administratorId: adminId,
      classroomId: classId,
      teachers: parsedTeachers,
    );
  }

  Map<String, dynamic> toJson() {
    final data = {
      'title': title,
      'description': description,
      'date': date,
      'start': start,
      'end': end,
      'administratorId': administratorId,
      'classroomId': classroomId,
    };
    if (meetingId != null) data['meetingId'] = meetingId as Object;
    if (teachers != null) {
      data['teachers'] = teachers!.map((t) => t.toJson()).toList();
    }
    return data;
  }
}