import 'package:flutter/material.dart';
import '../../utils/token_utils.dart';
import '../../services/admin_service.dart';
import '../../services/reports_service.dart';
import '../../models/administratorprofile.dart';
import '../../models/report.dart';
import '../../widgets/app_drawer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<AdministratorProfile?>? _adminProfileFuture;
  Future<List<Report>>? _reportsFuture;

  @override
  void initState() {
    super.initState();
    _adminProfileFuture = _loadAdminProfile();
    _reportsFuture = ReportsService().getAllReports();
  }

  Future<AdministratorProfile?> _loadAdminProfile() async {
    final adminId = await getProfileIdFromPrefs();
    if (adminId == null) return null;
    return await AdminService().getAdminById(adminId);
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
                    FutureBuilder<List<Report>>(
                      future: _reportsFuture,
                      builder: (context, reportSnapshot) {
                        if (reportSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (reportSnapshot.hasError || !reportSnapshot.hasData || reportSnapshot.data!.isEmpty) {
                          return const Center(child: Text('No hay reportes disponibles', style: TextStyle(color: Colors.white)));
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
