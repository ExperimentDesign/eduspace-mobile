import 'package:flutter/material.dart';
import '../../utils/token_utils.dart';
import '../../services/admin_service.dart';
import '../../services/reports_service.dart';
import '../../services/meetings_service.dart';
import '../../models/administratorprofile.dart';
import '../../models/report.dart';
import '../../models/meeting.dart';
import '../../widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<AdministratorProfile?>? _adminProfileFuture;
  Future<List<Report>>? _reportsFuture;
  Future<List<Meeting>>? _meetingsTodayFuture;

  @override
  void initState() {
    super.initState();
    _adminProfileFuture = _loadAdminProfile();
    _reportsFuture = ReportsService().getAllReports();
    _meetingsTodayFuture = _loadMeetingsForToday();
  }

  Future<AdministratorProfile?> _loadAdminProfile() async {
    final adminId = await getProfileIdFromPrefs();
    if (adminId == null) return null;
    return await AdminService().getAdminById(adminId);
  }

  // Fetch all meetings and keep only those that fall on today's date
  Future<List<Meeting>> _loadMeetingsForToday() async {
    final all = await MeetingsService().getAllMeetings();
    final now = DateTime.now();
    return all.where((m) {
      if (m.date.isEmpty) return false;
      // Try parsing ISO-like strings; if parsing fails, compare raw string to formatted date
      DateTime? parsed;
      try {
        parsed = DateTime.tryParse(m.date);
      } catch (_) {
        parsed = null;
      }
      if (parsed != null) {
        return parsed.year == now.year && parsed.month == now.month && parsed.day == now.day;
      }
      // fallback: compare only date portion as yyyy-MM-dd
      final formattedNow = '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
      return m.date.startsWith(formattedNow);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Inicio', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFFFCDE5B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FutureBuilder<AdministratorProfile?>(
            future: _adminProfileFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
                return const Center(child: Text('No se pudo cargar el perfil', style: TextStyle(color: Colors.white)));
              }
              final admin = snapshot.data!;
              return SingleChildScrollView(
                child: Container(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Column(
                    children: [
                      Center(
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          elevation: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.account_circle, size: 64, color: Color(0xFF1976D2)),
                                const SizedBox(height: 18),
                                Text(
                                  'Bienvenido',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  '${admin.firstName} ${admin.lastName}',
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1976D2),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Reportes recientes',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                          ),
                        ),
                      ),
                      FutureBuilder<List<Report>>(
                        future: _reportsFuture,
                        builder: (context, reportSnapshot) {
                          if (reportSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (reportSnapshot.hasError || !reportSnapshot.hasData || reportSnapshot.data!.isEmpty) {
                            return const Center(child: Text('No hay reportes registrados', style: TextStyle(color: Colors.white)));
                          }
                          final reports = reportSnapshot.data!;
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: reports.length,
                            itemBuilder: (context, index) {
                              final report = reports[index];
                              return Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 5,
                                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(18),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        report.kindOfReport ?? 'Sin tipo de reporte',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18,
                                          color: Color(0xFF1976D2),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        report.description ?? 'Sin descripción',
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'ID: ${report.id ?? '-'}',
                                        style: const TextStyle(fontSize: 13, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Reuniones de hoy',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800]),
                          ),
                        ),
                      ),
                      FutureBuilder<List<Meeting>>(
                        future: _meetingsTodayFuture,
                        builder: (context, meetingSnapshot) {
                          if (meetingSnapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (meetingSnapshot.hasError) {
                            return Center(child: Text('Error al cargar reuniones: ${meetingSnapshot.error}', style: const TextStyle(color: Colors.white)));
                          }
                          final meetings = meetingSnapshot.data ?? [];
                          if (meetings.isEmpty) {
                            return const Center(child: Text('No hay reuniones para hoy', style: TextStyle(color: Colors.white)));
                          }
                          return ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: meetings.length,
                            itemBuilder: (context, index) {
                              final meeting = meetings[index];
                              return Card(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.all(14),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        meeting.title,
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        meeting.description,
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text('Hora: ${meeting.start} - ${meeting.end}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                          Text('Aula ID: ${meeting.classroomId}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
