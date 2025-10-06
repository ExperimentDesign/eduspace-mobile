import 'classroom.dart';

class Resource {
  final int? id;
  final String name;
  final String kindOfResource;
  final Classroom? classroom;

  Resource({
    this.id,
    required this.name,
    required this.kindOfResource,
    this.classroom,
  });

  factory Resource.fromJson(Map<String, dynamic> json) => Resource(
    id: json['id'] as int?,
    name: json['name'] as String,
    kindOfResource: json['kindOfResource'] as String,
    classroom: json['classroom'] != null
        ? Classroom.fromJson(json['classroom'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson({bool forUpdate = false}) {
    final data = {
      'name': name,
      'kindOfResource': kindOfResource,
    };
    if (forUpdate && classroom?.id != null) {
      data['classroomId'] = classroom!.id.toString(); // or classroom!.id!.toString() if needed
    }
    if (forUpdate && id != null) {
      data['id'] = id.toString();
    }
    return data;
  }

}
