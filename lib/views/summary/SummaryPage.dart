import 'package:eduspace_mobile/widgets/teachers_app_drawer.dart';
import 'package:flutter/material.dart';
import '../../services/classroom_service.dart';
import '../../models/classroom.dart';
import '../../utils/token_utils.dart';
import '../classroom-reports/TeacherClassroomPage.dart';

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage> {
  final ClassroomService _classroomService = ClassroomService();

  late Future<List<Classroom>> _classroomsFuture;

  @override
  void initState() {
    super.initState();
    _loadDataForTeacher();
  }

  void _loadDataForTeacher() async {
    final profileId = await getProfileIdFromPrefs();
    print('Using profileId for teacher: $profileId');
    setState(() {
      _classroomsFuture = profileId != null
          ? _classroomService.getClassroomsByTeacherId(profileId)
          : Future.value([]);
    });
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
              const Text('Salones asignados', style: TextStyle(color: Color(
                  0xFF000000), fontWeight: FontWeight.bold, fontSize: 22)),
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
                      children: classrooms.map((classroom) => GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TeacherClassroomPage(classroom: classroom),
                            ),
                          );
                        },
                        child: Card(
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
                        ),
                      )).toList(),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
              const Text('Reuniones asignadas', style: TextStyle(color: Color(
                  0xFF000000), fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
