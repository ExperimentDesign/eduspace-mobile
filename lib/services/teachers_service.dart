import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/ApiConfig.dart';
import '../models/teacher.dart';

class TeachersService {
  Future<List<Teacher>> getAllTeachers() async {
    final response = await http.get(Uri.parse(ApiConfig.teachersProfiles));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Teacher.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los profesores');
    }
  }

  Future<Teacher> getTeacherById(int id) async {
    final response = await http.get(Uri.parse('${ApiConfig.teachersProfiles}/$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Teacher.fromJson(data);
    } else {
      throw Exception('Error al obtener el profesor');
    }
  }

  Future<void> createTeacher(Teacher teacher) async {
    final jsonBody = json.encode(teacher.toJson());
    print('Sending teacher data: $jsonBody');
    final response = await http.post(
      Uri.parse(ApiConfig.teachersProfiles),
      headers: {'Content-Type': 'application/json'},
      body: jsonBody,
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al crear el profesor');
    }
  }

  Future<String> getTeacherFullNameById(int id) async {
    try {
      final teacher = await getTeacherById(id);
      return '${teacher.firstName} ${teacher.lastName}';
    } catch (e) {
      return 'Desconocido';
    }
  }


}