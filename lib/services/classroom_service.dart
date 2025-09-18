import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/ApiConfig.dart';
import '../models/classroom.dart';

class ClassroomService {
  Future<List<Classroom>> getAllClassrooms() async {
    final response = await http.get(Uri.parse(ApiConfig.classrooms));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Classroom.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los salones');
    }
  }

  static Future<bool> createClassroom(Classroom classroom) async {
    final jsonBody = json.encode({
      'name': classroom.name,
      'description': classroom.description,
    });
    final url = '${ApiConfig.classrooms}/teachers/${classroom.teacherId}';
    print('Enviando classroom: $jsonBody a $url');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonBody,
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error al crear el salón');
    }
  }

  Future<bool> deleteClassroom(String classroomId) async {
    final url = '${ApiConfig.classrooms}/$classroomId';
    final response = await http.delete(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Error al eliminar el salón');
    }
  }

  Future<bool> updateClassroom(String classroomId, Classroom classroom) async {
    final url = '${ApiConfig.classrooms}/$classroomId';
    final jsonBody = json.encode({
      'id': classroom.id,
      'name': classroom.name,
      'description': classroom.description,
      'teacherId': classroom.teacherId,
    });
    print('Recibiendo: $jsonBody a $url');
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonBody,
    );
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    } else {
      throw Exception('Error al actualizar el salón');
    }
  }
}
