import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sharedspace.dart';
import '../config/ApiConfig.dart';

class SharedSpacesService {
  Future<List<SharedSpace>> getAllSharedSpaces() async {
    final response = await http.get(Uri.parse(ApiConfig.sharedSpaces));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SharedSpace.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener los espacios compartidos');
    }
  }

  Future<SharedSpace> getSharedSpaceById(int id) async {
    final response = await http.get(Uri.parse('${ApiConfig.sharedSpaces}/$id'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return SharedSpace.fromJson(data);
    } else {
      throw Exception('Error al obtener el espacio compartido');
    }
  }

  Future<void> createSharedSpace(SharedSpace sharedSpace) async {
    final response = await http.post(
      Uri.parse(ApiConfig.sharedSpaces),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(sharedSpace.toJson()),
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al crear el espacio compartido');
    }
  }

  Future<void> deleteSharedSpace(int id) async {
    final response = await http.delete(Uri.parse('${ApiConfig.sharedSpaces}/$id'));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar el espacio compartido');
    }
  }

  Future<void> updateSharedSpace(SharedSpace sharedSpace) async {
    final response = await http.put(
      Uri.parse('${ApiConfig.sharedSpaces}/${sharedSpace.id}'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(sharedSpace.toJson()),
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al actualizar el espacio compartido');
    }
  }
}