import 'package:flutter/material.dart';
import '../../models/classroom.dart';
import '../../models/resource.dart';
import '../../services/resources_service.dart';
import '../../services/reports_service.dart';
import '../../models/report.dart';

class TeacherClassroomPage extends StatefulWidget {
  final Classroom classroom;

  const TeacherClassroomPage({Key? key, required this.classroom}) : super(key: key);

  @override
  State<TeacherClassroomPage> createState() => _TeacherClassroomPageState();
}

class _TeacherClassroomPageState extends State<TeacherClassroomPage> {
  late Future<List<Resource>> _resourcesFuture;

  @override
  void initState() {
    super.initState();
    _resourcesFuture = _fetchResources();
  }

  Future<List<Resource>> _fetchResources() async {
    return await ResourcesService().getResourcesByClassroomId(
        widget.classroom.id!);
  }

  void _showCreateReportDialog(Resource resource) async {
    final _kindController = TextEditingController();
    final _descController = TextEditingController();
    DateTime? _selectedDate;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) =>
              Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                elevation: 16,
                backgroundColor: Colors.white,
                child: Container(
                  padding: const EdgeInsets.all(24),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.report, color: Color(0xFF1976D2), size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Crear reporte para ${resource.name}',
                                style: const TextStyle(
                                  color: Color(0xFF1976D2),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                                softWrap: true,
                                overflow: TextOverflow.visible, // or TextOverflow.ellipsis
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        TextField(
                          controller: _kindController,
                          decoration: InputDecoration(
                            labelText: 'Tipo de reporte',
                            filled: true,
                            fillColor: const Color(0xFFF5F7FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: Color(0xFF1976D2), width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: Color(0xFF1976D2), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        TextField(
                          controller: _descController,
                          decoration: InputDecoration(
                            labelText: 'Descripción',
                            filled: true,
                            fillColor: const Color(0xFFF5F7FA),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: Color(0xFF1976D2), width: 1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                  color: Color(0xFF1976D2), width: 2),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Text(
                              _selectedDate == null
                                  ? 'Seleccionar fecha'
                                  : 'Fecha: ${_selectedDate!
                                  .toLocal()
                                  .toString()
                                  .split(' ')[0]}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: const Icon(Icons.calendar_today,
                                  color: Color(0xFF1976D2)),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  setState(() {
                                    _selectedDate = picked;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              style: TextButton.styleFrom(
                                foregroundColor: const Color(0xFF1976D2),
                                textStyle: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () => Navigator.of(context).pop(),
                              child: const Text('Cancelar'),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1976D2),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                                elevation: 2,
                              ),
                              onPressed: () async {
                                if (_kindController.text.isNotEmpty &&
                                    _descController.text.isNotEmpty &&
                                    _selectedDate != null) {
                                  await ReportsService().createReport(
                                    Report(
                                      kindOfReport: _kindController.text,
                                      description: _descController.text,
                                      resourceId: resource.id!,
                                      createdAt: _selectedDate!,
                                    ),
                                  );
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Reporte creado')),
                                  );
                                }
                              },
                              child: const Text('Crear',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
            'Detalles del aula', style: TextStyle(fontWeight: FontWeight.bold)),
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
          child: Column(
            children: [
              Center(
                child: Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  elevation: 10,
                  margin: const EdgeInsets.all(24),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                                Icons.meeting_room, color: Color(0xFF1976D2),
                                size: 28),
                            const SizedBox(width: 10),
                            Text(
                              widget.classroom.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(widget.classroom.description,
                            style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 12),
                        Text('Teacher ID: ${widget.classroom.teacherId}',
                            style: const TextStyle(fontSize: 16)),
                        if (widget.classroom.id != null)
                          Text('Classroom ID: ${widget.classroom.id}',
                              style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: FutureBuilder<List<Resource>>(
                  future: _resourcesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text(
                          'Error al cargar recursos', style: TextStyle(
                          color: Colors.white)));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No hay recursos para este salón',
                            style: TextStyle(
                                color: Colors.white, fontSize: 18)),
                      );
                    }
                    final resources = snapshot.data!;
                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24),
                      itemCount: resources.length,
                      itemBuilder: (context, index) {
                        final resource = resources[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18)),
                          elevation: 6,
                          margin: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 8),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 12),
                            title: Text(
                              resource.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                            subtitle: Text('Tipo: ${resource.kindOfResource}',
                                style: const TextStyle(fontSize: 16)),
                            trailing: const Icon(
                                Icons.report, color: Color(0xFF1976D2)),
                            onTap: () => _showCreateReportDialog(resource),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}