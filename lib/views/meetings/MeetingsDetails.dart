// dart
// File: `lib/views/meetings/MeetingsDetails.dart`
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../config/ApiConfig.dart';
import '../../models/meeting.dart';
import '../../models/teacher.dart';
import '../../services/meetings_service.dart';
import '../../widgets/app_drawer.dart';

class MeetingsDetails extends StatefulWidget {
  final Meeting? meeting;
  final int? meetingId;

  const MeetingsDetails({super.key, this.meeting, this.meetingId})
      : assert(meeting != null || meetingId != null, 'Provide meeting or meetingId');

  @override
  State<MeetingsDetails> createState() => _MeetingsDetailsState();
}

class _MeetingsDetailsState extends State<MeetingsDetails> {
  Meeting? _meeting;
  bool _loading = false;
  String? _error;

  bool _addingInProgress = false;
  bool _removingInProgress = false;

  @override
  void initState() {
    super.initState();
    _meeting = widget.meeting;
    if (_meeting == null && widget.meetingId != null) {
      _fetchMeeting(widget.meetingId!);
    }
  }

  Future<void> _fetchMeeting(int id) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final m = await MeetingsService().getMeetingById(id);
      setState(() {
        _meeting = m;
      });
    } catch (e) {
      setState(() {
        _error = 'Error: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<List<Teacher>> _fetchAllTeachers() async {
    final response = await http.get(Uri.parse(ApiConfig.teachersProfiles));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .where((e) => e != null)
          .map<Teacher>((e) => Teacher.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } else {
      throw Exception('Error fetching teachers: ${response.statusCode}');
    }
  }

  Future<void> _openAddTeacherDialog() async {
    if (_meeting == null || _meeting!.meetingId == null) return;

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<Teacher>>(
          future: _fetchAllTeachers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('Could not load teachers: ${snapshot.error}'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))
                ],
              );
            } else {
              final allTeachers = snapshot.data ?? [];
              final assignedIds = (_meeting!.teachers ?? []).map((t) => t.id).whereType<int>().toSet();
              final available = allTeachers.where((t) => !(assignedIds.contains(t.id))).toList();

              return AlertDialog(
                title: const Text('Agregar profesor'),
                content: SizedBox(
                  width: double.maxFinite,
                  child: available.isEmpty
                      ? const Text('No hay profesores disponibles para asignar.')
                      : ListView.separated(
                    shrinkWrap: true,
                    itemCount: available.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final teacher = available[index];
                      return ListTile(
                        title: Text('${teacher.firstName} ${teacher.lastName}'),
                        subtitle: (teacher.email ?? '').isNotEmpty ? Text(teacher.email!) : null,
                        onTap: () {
                          Navigator.pop(context);
                          _addTeacherToMeeting(teacher);
                        },
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ],
              );
            }
          },
        );
      },
    );
  }

  Future<void> _addTeacherToMeeting(Teacher teacher) async {
    if (_meeting == null || _meeting!.meetingId == null || teacher.id == null) return;
    setState(() {
      _addingInProgress = true;
    });
    try {
      await MeetingsService().addTeacherToMeeting(_meeting!.meetingId!, teacher.id!);

      final updatedTeachers = List<Teacher>.from(_meeting!.teachers ?? [])..add(teacher);
      setState(() {
        _meeting = Meeting(
          meetingId: _meeting!.meetingId,
          title: _meeting!.title,
          description: _meeting!.description,
          date: _meeting!.date,
          start: _meeting!.start,
          end: _meeting!.end,
          administratorId: _meeting!.administratorId,
          classroomId: _meeting!.classroomId,
          teachers: updatedTeachers,
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profesor agregado: ${teacher.firstName} ${teacher.lastName}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al agregar profesor: $e')),
        );
      }
    } finally {
      setState(() {
        _addingInProgress = false;
      });
    }
  }

  Future<void> _removeTeacherFromMeeting(Teacher teacher) async {
    if (_meeting == null || _meeting!.meetingId == null || teacher.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar profesor'),
        content: Text('¿Eliminar a ${teacher.firstName} ${teacher.lastName} de la reunión?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirmed != true) return;

    setState(() {
      _removingInProgress = true;
    });
    try {
      await MeetingsService().deleteTeacherFromMeeting(_meeting!.meetingId!, teacher.id!);

      final updatedTeachers = List<Teacher>.from(_meeting!.teachers ?? [])..removeWhere((t) => t.id == teacher.id);
      setState(() {
        _meeting = Meeting(
          meetingId: _meeting!.meetingId,
          title: _meeting!.title,
          description: _meeting!.description,
          date: _meeting!.date,
          start: _meeting!.start,
          end: _meeting!.end,
          administratorId: _meeting!.administratorId,
          classroomId: _meeting!.classroomId,
          teachers: updatedTeachers,
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profesor removido: ${teacher.firstName} ${teacher.lastName}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al remover profesor: $e')),
        );
      }
    } finally {
      setState(() {
        _removingInProgress = false;
      });
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTeacherCard(Teacher t) {
    final fullName = '${t.firstName} ${t.lastName}';
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).primaryColorLight,
          child: Text(fullName.isNotEmpty ? fullName[0] : '', style: const TextStyle(color: Colors.white)),
        ),
        title: Text(fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if ((t.email ?? '').isNotEmpty) Text(t.email!, style: const TextStyle(fontSize: 13)),
            if ((t.dni ?? '').isNotEmpty) Text('DNI: ${t.dni!}', style: const TextStyle(fontSize: 13)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: _removingInProgress ? null : () => _removeTeacherFromMeeting(t),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.transparent,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Detalles de Reunión', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFFFCDE5B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.white)))
              : _meeting == null
              ? const Center(child: Text('No meeting data', style: TextStyle(color: Colors.white)))
              : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 6,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundColor: theme.primaryColorLight,
                              child: Text(
                                '${_meeting!.title.isNotEmpty ? _meeting!.title[0] : ''}',
                                style: const TextStyle(color: Colors.white, fontSize: 24),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _meeting!.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                      color: Color(0xFF1976D2),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('ID: ${_meeting!.meetingId ?? '-'}', style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoRow('Descripción:', _meeting!.description),
                        const Divider(),
                        _buildInfoRow('Fecha:', _meeting!.date),
                        _buildInfoRow('Inicio:', _meeting!.start),
                        _buildInfoRow('Fin:', _meeting!.end),
                        const Divider(),
                        _buildInfoRow('Administrador ID:', _meeting!.administratorId.toString()),
                        _buildInfoRow('Classroom ID:', _meeting!.classroomId.toString()),
                        const SizedBox(height: 18),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            style: TextButton.styleFrom(foregroundColor: const Color(0xFF1976D2)),
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cerrar'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 18),
                const Text('Profesores asignados', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 8),

                if (_meeting!.teachers == null || _meeting!.teachers!.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text('No hay profesores asignados', style: TextStyle(color: Colors.white)),
                  )
                else
                  Column(
                    children: _meeting!.teachers!.map((t) => _buildTeacherCard(t)).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1976D2), Color(0xFF43E97B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: _addingInProgress ? null : _openAddTeacherDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: _addingInProgress
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
          )
              : const Icon(Icons.person_add, color: Colors.white),
          label: const Text(
            'Agregar profesor',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1,
            ),
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
