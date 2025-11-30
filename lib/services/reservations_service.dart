import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/reservation.dart';
import '../config/ApiConfig.dart';

class ReservationsService {
  Future<List<Reservation>> getAllReservations() async {
    final response = await http.get(Uri.parse(ApiConfig.reservations));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Reservation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load reservations');
    }
  }

  Future<Reservation> createReservation({
    required int teacherId,
    required int areaId,
    required Reservation reservation,
  }) async {
    final url = '${ApiConfig.baseUrl}/teachers/$teacherId/areas/$areaId/reservations';
    print('POST $url');
    print('Body: ${json.encode(reservation.toJson(forPost: true))}');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reservation.toJson(forPost: true)),
    );
    print('Status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Reservation.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create reservation: ${response.body}');
    }
  }

  Future<Reservation> editReservation({
    required int id,
    required String title,
    required DateTime start,
    required DateTime end,
  }) async {
    final url = '${ApiConfig.baseUrl}/reservations/$id';
    final body = {
      'title': title,
      'start': start.toIso8601String(),
      'end': end.toIso8601String(),
    };
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(body),
    );
    if (response.statusCode == 200) {
      return Reservation.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to edit reservation: ${response.body}');
    }
  }

  Future<void> deleteReservation(int id) async {
    final url = '${ApiConfig.baseUrl}/reservations/$id';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to delete reservation: ${response.body}');
    }
  }
}
