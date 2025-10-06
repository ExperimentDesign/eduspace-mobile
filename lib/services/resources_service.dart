import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/ApiConfig.dart';
import '../models/resource.dart';

class ResourcesService {
  Future<List<Resource>> getAllResources() async {
    final response = await http.get(Uri.parse(ApiConfig.resources));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Resource.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load resources');
    }
  }

  Future<Resource> createResource(int classroomId, Resource resource) async {
    final url = '${ApiConfig.classrooms}/$classroomId/resources';
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(resource.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Resource.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create resource');
    }
  }

  Future<void> deleteResource(int resourceId) async {
    final url = '${ApiConfig.resources}/$resourceId';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete resource');
    }
  }

  Future<Resource> updateResource(int resourceId, Resource resource) async {
    final url = '${ApiConfig.resources}/$resourceId';
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(resource.toJson(forUpdate: true)),
    );
    if (response.statusCode == 200) {
      return Resource.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update resource');
    }
  }
}
