import 'package:eduspace_mobile/widgets/teachers_app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:eduspace_mobile/utils/token_utils.dart';
import '../../services/reservations_service.dart';
import '../../services/teachers_service.dart';
import '../../services/sharedspaces_service.dart';
import '../../models/reservation.dart';
import '../../models/sharedspace.dart';

class ReservationsPage extends StatefulWidget {
  const ReservationsPage({super.key});

  @override
  State<ReservationsPage> createState() => _ReservationsPageState();
}

class _ReservationsPageState extends State<ReservationsPage> {
  final ReservationsService _reservationsService = ReservationsService();
  final TeachersService _teachersService = TeachersService();
  final SharedSpacesService _sharedSpacesService = SharedSpacesService();

  Future<List<Map<String, dynamic>>> _fetchReservationsWithDetails() async {
    final reservations = await _reservationsService.getAllReservations();
    List<Map<String, dynamic>> result = [];

    for (var reservation in reservations) {
      String teacherName = '';
      String sharedSpaceName = '';

      if (reservation.teacherId != null) {
        teacherName = await _teachersService.getTeacherFullNameById(reservation.teacherId!);
      }
      if (reservation.areaId != null) {
        final sharedSpace = await _sharedSpacesService.getSharedSpaceById(reservation.areaId!);
        sharedSpaceName = sharedSpace.name;
      }

      result.add({
        'reservation': reservation,
        'teacherName': teacherName,
        'sharedSpaceName': sharedSpaceName,
      });
    }
    return result;
  }

  String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }


  void _showAddReservationDialog(BuildContext context) async {
    final sharedSpaces = await _sharedSpacesService.getAllSharedSpaces();
    final profileId = await getProfileIdFromPrefs();

    String title = '';
    SharedSpace? selectedSpace;
    DateTime? start;
    DateTime? end;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Agregar Reserva'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      decoration: const InputDecoration(labelText: 'Título'),
                      onChanged: (value) => title = value,
                    ),
                    const SizedBox(height: 10),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(start == null
                          ? 'Seleccionar inicio'
                          : DateFormat('dd/MM/yyyy HH:mm').format(start!)),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              start = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                            });
                          }
                        }
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(end == null
                          ? 'Seleccionar fin'
                          : DateFormat('dd/MM/yyyy HH:mm').format(end!)),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: start ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );
                        if (date != null) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (time != null) {
                            setState(() {
                              end = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                            });
                          }
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<SharedSpace>(
                      decoration: const InputDecoration(labelText: 'Espacio compartido'),
                      items: sharedSpaces.map((space) {
                        return DropdownMenuItem(
                          value: space,
                          child: Text(space.name),
                        );
                      }).toList(),
                      onChanged: (space) => setState(() => selectedSpace = space),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text('Cancelar'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                ElevatedButton(
                  child: const Text('Agregar'),
                  onPressed: () async {
                    if (title.isNotEmpty && start != null && end != null && selectedSpace != null && profileId != null) {
                      final newReservation = Reservation(
                        title: title,
                        start: start!,
                        end: end!,
                        areaId: selectedSpace!.id,
                        teacherId: profileId,
                      );
                      await _reservationsService.createReservation(
                        teacherId: profileId,
                        areaId: selectedSpace!.id!,
                        reservation: newReservation,
                      );
                      Navigator.of(context).pop();
                      setState(() {}); // Refresh list
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const TeachersAppDrawer(),
      appBar: AppBar(
        title: const Text('Reservations', style: TextStyle(fontWeight: FontWeight.bold)),
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
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _fetchReservationsWithDetails(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
              }
              final reservations = snapshot.data ?? [];
              if (reservations.isEmpty) {
                return const Center(child: Text('No reservations found.', style: TextStyle(color: Colors.white, fontSize: 18)));
              }
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: reservations.map((data) {
                  final reservation = data['reservation'] as Reservation;
                  final teacherName = data['teacherName'] as String;
                  final sharedSpaceName = data['sharedSpaceName'] as String;

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.event, color: Color(0xFF1976D2)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  reservation.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20,
                                    color: Color(0xFF1976D2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text('Start: ${formatDate(reservation.start)}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                              const SizedBox(width: 6),
                              Text('End: ${formatDate(reservation.end)}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 18, color: Colors.teal),
                              const SizedBox(width: 6),
                              Text('Shared Space: $sharedSpaceName', style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.person, size: 18, color: Colors.deepPurple),
                              const SizedBox(width: 6),
                              Text('Teacher: $teacherName', style: const TextStyle(fontSize: 16)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              );
            },
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
          onPressed: () => _showAddReservationDialog(context),
          backgroundColor: Colors.transparent,
          elevation: 0,
          label: const Text(
            'Agregar Reserva',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 1,
            ),
          ),
          icon: const Icon(Icons.add, color: Colors.white, size: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          extendedPadding: const EdgeInsets.symmetric(horizontal: 24),
          foregroundColor: Colors.white,
        ),
      ),
    );
  }
}
