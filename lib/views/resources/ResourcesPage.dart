import 'package:flutter/material.dart';
import '../../models/classroom.dart';
import '../../services/classroom_service.dart';
import '../../services/resources_service.dart';
import '../../models/resource.dart';
import '../../widgets/app_drawer.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  final ResourcesService _resourcesService = ResourcesService();
  late Future<List<Resource>> _resourcesFuture;

  @override
  void initState() {
    super.initState();
    _resourcesFuture = _resourcesService.getAllResources();
  }

  Future<void> _showAddResourceDialog() async {
    final _formKey = GlobalKey<FormState>();
    String name = '';
    String kindOfResource = '';
    int? selectedClassroomId;
    List<Classroom> classrooms = [];

    await showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<Classroom>>(
          future: ClassroomService().getAllClassrooms(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('No se pudieron cargar los salones:\n${snapshot.error}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ],
              );
            }
            classrooms = snapshot.data ?? [];
            if (classrooms.isEmpty) {
              return AlertDialog(
                title: const Text('Sin salones'),
                content: const Text('No hay salones disponibles para asignar.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ],
              );
            }
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.inventory, color: Color(0xFF1976D2), size: 28),
                          SizedBox(width: 10),
                          Text('Agregar Recurso', style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold, fontSize: 22)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onChanged: (v) => name = v,
                        validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Tipo de recurso',
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onChanged: (v) => kindOfResource = v,
                        validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: 'Salón',
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        items: classrooms.map((classroom) {
                          return DropdownMenuItem<int>(
                            value: classroom.id!,
                            child: Text(classroom.name),
                          );
                        }).toList(),
                        onChanged: (value) => selectedClassroomId = value,
                        validator: (v) => v == null ? 'Seleccione un salón' : null,
                      ),
                      const SizedBox(height: 10),
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
                              if (_formKey.currentState!.validate() && selectedClassroomId != null) {
                                try {
                                  await _resourcesService.createResource(
                                    selectedClassroomId!,
                                    Resource(name: name, kindOfResource: kindOfResource),
                                  );
                                  if (mounted) Navigator.of(context).pop();
                                  setState(() {
                                    _resourcesFuture = _resourcesService.getAllResources();
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
    );
  }

  Future<void> _showEditResourceDialog(Resource resource) async {
    final _formKey = GlobalKey<FormState>();
    String name = resource.name;
    String kindOfResource = resource.kindOfResource;
    int? selectedClassroomId = resource.classroom?.id;
    List<Classroom> classrooms = [];

    await showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<Classroom>>(
          future: ClassroomService().getAllClassrooms(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const AlertDialog(
                content: SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: const Text('Error'),
                content: Text('No se pudieron cargar los salones:\n${snapshot.error}'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ],
              );
            }
            classrooms = snapshot.data ?? [];
            if (classrooms.isEmpty) {
              return AlertDialog(
                title: const Text('Sin salones'),
                content: const Text('No hay salones disponibles para asignar.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cerrar'),
                  ),
                ],
              );
            }
            return Dialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.edit, color: Color(0xFF1976D2), size: 28),
                          SizedBox(width: 10),
                          Text('Editar Recurso', style: TextStyle(color: Color(0xFF1976D2), fontWeight: FontWeight.bold, fontSize: 22)),
                        ],
                      ),
                      const SizedBox(height: 18),
                      TextFormField(
                        initialValue: name,
                        decoration: InputDecoration(
                          labelText: 'Nombre',
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onChanged: (v) => name = v,
                        validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        initialValue: kindOfResource,
                        decoration: InputDecoration(
                          labelText: 'Tipo de recurso',
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onChanged: (v) => kindOfResource = v,
                        validator: (v) => v == null || v.isEmpty ? 'Requerido' : null,
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        value: selectedClassroomId,
                        decoration: InputDecoration(
                          labelText: 'Salón',
                          filled: true,
                          fillColor: const Color(0xFFF5F7FA),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        items: classrooms.map((classroom) {
                          return DropdownMenuItem<int>(
                            value: classroom.id!,
                            child: Text(classroom.name),
                          );
                        }).toList(),
                        onChanged: (value) => selectedClassroomId = value,
                        validator: (v) => v == null ? 'Seleccione un salón' : null,
                      ),
                      const SizedBox(height: 10),
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
                              if (_formKey.currentState!.validate() && selectedClassroomId != null) {
                                try {
                                  await _resourcesService.updateResource(
                                    resource.id!,
                                    Resource(
                                      id: resource.id,
                                      name: name,
                                      kindOfResource: kindOfResource,
                                      classroom: Classroom(id: selectedClassroomId, name: '', description: '', teacherId: 0),
                                    ),
                                  );
                                  if (mounted) Navigator.of(context).pop();
                                  setState(() {
                                    _resourcesFuture = _resourcesService.getAllResources();
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              }
                            },
                            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
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
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Recursos', style: TextStyle(fontWeight: FontWeight.bold)),
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
          child: FutureBuilder<List<Resource>>(
            future: _resourcesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('No hay recursos disponibles.', style: TextStyle(color: Colors.white, fontSize: 18)),
                );
              } else {
                final resources = snapshot.data!;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: resources.length,
                  itemBuilder: (context, index) {
                    final resource = resources[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 6,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Color(0xFF1976D2)),
                              onPressed: () {
                                _showEditResourceDialog(resource);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                try {
                                  await _resourcesService.deleteResource(resource.id!);
                                  setState(() {
                                    _resourcesFuture = _resourcesService.getAllResources();
                                  });
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error al eliminar: $e')),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        title: Text(
                          resource.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text('Tipo: ${resource.kindOfResource}', style: const TextStyle(fontSize: 16)),
                            const SizedBox(height: 6),
                            Text(
                              'Salón: ${resource.classroom?.name ?? "Desconocido"}',
                              style: const TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
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
          onPressed: () {
            _showAddResourceDialog();
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
