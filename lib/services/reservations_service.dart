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
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(reservation.toJson(forPost: true)),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return Reservation.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create reservation');
    }
  }
}
