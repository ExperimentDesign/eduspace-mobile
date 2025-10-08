// Dart
import 'package:flutter/material.dart';
import '../../models/classroom.dart';
import '../../models/resource.dart';
import '../../services/resources_service.dart';

class ClassroomDetails extends StatefulWidget {
  final Classroom classroom;
  const ClassroomDetails({super.key, required this.classroom});

  @override
  State<ClassroomDetails> createState() => _ClassroomDetailsState();
}

class _ClassroomDetailsState extends State<ClassroomDetails> {
  late Future<List<Resource>> _resourcesFuture;

  @override
  void initState() {
    super.initState();
    _resourcesFuture = ResourcesService().getResourcesByClassroomId(widget.classroom.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.classroom.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1976D2), Color(0xFFFCDE5B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height,
                ),
                child: Column(
                  children: [
                Card(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.meeting_room, size: 48, color: Color(0xFF1976D2)),
                        const SizedBox(height: 18),
                        Text(
                          widget.classroom.name,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.classroom.description,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Teacher ID: ${widget.classroom.teacherId}',
                          style: const TextStyle(fontSize: 15, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                FutureBuilder<List<Resource>>(
                  future: _resourcesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('No resources found.', style: TextStyle(color: Colors.white)),
                      );
                    }
                    final resources = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: resources.length,
                      itemBuilder: (context, index) {
                        final resource = resources[index];
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
                                  resource.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF1976D2),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  resource.kindOfResource,
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'ID: ${resource.id ?? '-'}',
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
          onPressed: () async {
            final _formKey = GlobalKey<FormState>();
            String name = '';
            String kindOfResource = '';
            await showDialog(
              context: context,
              builder: (context) {
                return Dialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('Agregar Recurso', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF1976D2))),
                          const SizedBox(height: 18),
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Nombre'),
                            onChanged: (v) => name = v,
                            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Tipo de Recurso'),
                            onChanged: (v) => kindOfResource = v,
                            validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                          ),
                          const SizedBox(height: 18),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text('Cancelar', style: TextStyle(color: Color(0xFF1976D2))),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1976D2),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    try {
                                      await ResourcesService().createResource(
                                        widget.classroom.id!,
                                        Resource(name: name, kindOfResource: kindOfResource),
                                      );
                                      if (mounted) Navigator.of(context).pop();
                                      setState(() {
                                        _resourcesFuture = ResourcesService().getResourcesByClassroomId(widget.classroom.id!);
                                      });
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  }
                                },
                                child: const Text('Agregar', style: TextStyle(color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          label: const Text(
            'Agregar Recursos',
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
