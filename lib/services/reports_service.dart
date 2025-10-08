import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/ApiConfig.dart';
import '../models/report.dart';

class ReportsService {
  Future<List<Report>> getAllReports() async {
    final response = await http.get(Uri.parse(ApiConfig.reports));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Report.fromJson(json)).toList();
    } else {
      throw Exception('Error fetching all classroom-reports');
    }
  }

  Future<bool> createReport(Report report) async {
    final body = json.encode(report.toJson());
    final response = await http.post(
      Uri.parse(ApiConfig.reports),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Error creating report');
    }
  }

  Future<List<Report>> getReportByResourceId(int resourceId) async {
    final url = '${ApiConfig.reports}/resources/$resourceId';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => Report.fromJson(json)).toList();
    } else {
      throw Exception('Error fetching classroom-reports for resource $resourceId');
    }
  }
}
