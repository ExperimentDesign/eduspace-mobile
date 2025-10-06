import 'package:eduspace_mobile/widgets/teachers_app_drawer.dart';
import 'package:flutter/material.dart';
import '../../services/classroom_service.dart';
import '../../services/meetings_service.dart';
import '../../models/classroom.dart';
import '../../models/meeting.dart';
import '../../widgets/app_drawer.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final ClassroomService _classroomService = ClassroomService();
  final MeetingsService _meetingsService = MeetingsService();

  late Future<List<Classroom>> _classroomsFuture;
  late Future<List<Meeting>> _meetingsFuture;

  @override
  void initState() {
    super.initState();
    _classroomsFuture = _classroomService.getAllClassrooms();
    _meetingsFuture = _meetingsService.getAllMeetings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const TeachersAppDrawer(),
      appBar: AppBar(
        title: const Text('Bienvenido docente', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF43E97B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              const Text('Salones', style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 10),
              FutureBuilder<List<Classroom>>(
                future: _classroomsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay salones disponibles.', style: TextStyle(color: Colors.white, fontSize: 18)));
                  } else {
                    final classrooms = snapshot.data!;
                    return Column(
                      children: classrooms.map((classroom) => Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 6,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          title: Text(
                            classroom.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                          subtitle: Text(classroom.description, style: const TextStyle(fontSize: 16)),
                        ),
                      )).toList(),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              const Text('Reuniones', style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 10),
              FutureBuilder<List<Meeting>>(
                future: _meetingsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay reuniones disponibles.', style: TextStyle(color: Colors.white, fontSize: 18)));
                  } else {
                    final meetings = snapshot.data!;
                    return Column(
                      children: meetings.map((meeting) => Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        elevation: 6,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          title: Text(
                            meeting.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(meeting.description, style: const TextStyle(fontSize: 16)),
                              const SizedBox(height: 4),
                              Text('Fecha: ${meeting.date}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                              Text('Inicio: ${meeting.start}  Fin: ${meeting.end}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                        ),
                      )).toList(),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
