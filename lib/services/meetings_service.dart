import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/ApiConfig.dart';
import '../models/meeting.dart';

class MeetingsService {
  Future<List<Meeting>> getAllMeetings() async {
    final response = await http.get(Uri.parse(ApiConfig.meetings));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Meeting.fromJson(json)).toList();
    } else {
      throw Exception('Error al obtener las reuniones');
    }
  }

  Future<Meeting> getMeetingById(int meetingId) async {
    final url = '${ApiConfig.meetings}/$meetingId';
    print('GET $url');
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Meeting.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Meeting not found: $meetingId');
    } else {
      throw Exception('Error fetching meeting $meetingId: ${response.statusCode}');
    }
  }

  Future<List<Meeting>> getAllMeetingsByTeacherId(int teacherId) async {
    final url = '${ApiConfig.baseUrl}/teachers/$teacherId/meetings';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Meeting.fromJson(json)).toList();
    } else {
      throw Exception('Error fetching meetings for teacher $teacherId');
    }
  }


  Future<void> createMeeting(Meeting meeting) async {
    // Construir la URL con los IDs
    final url = '${ApiConfig.baseUrl}/administrators/${meeting.administratorId}/classrooms/${meeting.classroomId}/meetings';

    // Solo los campos requeridos en el body
    final body = json.encode({
      'title': meeting.title,
      'description': meeting.description,
      'date': meeting.date,
      'start': meeting.start,
      'end': meeting.end,
    });

    print('POST $url body: $body');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Error al crear la reunión');
    }
  }

  Future<void> deleteMeeting(int meetingId) async {
    final url = '${ApiConfig.meetings}/$meetingId';
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error deleting meeting');
    }
  }

  Future<void> updateMeeting(Meeting meeting) async {
    final url = '${ApiConfig.meetings}/${meeting.meetingId}';
    final body = json.encode(meeting.toJson());
    print('PUT $url body: $body');
    final response = await http.put(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error updating meeting');
    }
  }

  Future<void> addTeacherToMeeting(int meetingId, int teacherId) async {
    final url = '${ApiConfig.meetings}/$meetingId/teachers/$teacherId';
    print('POST $url');
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: null,
    );
    if (response.statusCode != 200 && response.statusCode != 201 && response.statusCode != 204) {
      throw Exception('Error adding teacher $teacherId to meeting $meetingId: ${response.statusCode} ${response.body}');
    }
  }

  Future<void> deleteTeacherFromMeeting(int meetingId, int teacherId) async {
    final url = '${ApiConfig.meetings}/$meetingId/teachers/$teacherId';
    print('DELETE $url');
    final response = await http.delete(Uri.parse(url));
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error removing teacher $teacherId from meeting $meetingId: ${response.statusCode} ${response.body}');
    }
  }

}
