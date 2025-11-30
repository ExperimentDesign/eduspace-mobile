// dart
import 'package:flutter/material.dart';
import 'package:eduspace_mobile/models/administratorprofile.dart';
import 'package:eduspace_mobile/services/admin_service.dart';
import 'package:eduspace_mobile/services/auth_service.dart';
import 'package:eduspace_mobile/utils/token_utils.dart';

import '../../widgets/app_drawer.dart';

class AdminProfilePage extends StatefulWidget {
  const AdminProfilePage({super.key});

  @override
  State<AdminProfilePage> createState() => _AdminProfilePageState();
}

class _AdminProfilePageState extends State<AdminProfilePage> {
  final AdminService _adminService = AdminService();
  final AuthService _authService = AuthService();
  AdministratorProfile? _profile;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final profileId = await getProfileIdFromPrefs();
      if (profileId == null) {
        setState(() {
          _error = 'No profile id found in preferences.';
          _loading = false;
        });
        return;
      }

      final admin = await _adminService.getAdminById(profileId);
      if (admin == null) {
        setState(() {
          _error = 'Administrator not found.';
          _loading = false;
        });
        return;
      }

      setState(() {
        _profile = admin;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading profile.';
        _loading = false;
      });
    }
  }

  Widget _buildInfoRow(String label, String? value) {
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(value ?? ''),
    );
  }

  Future<void> _showEditDialog() async {
    if (_profile == null) return;

    final AdministratorProfile? updatedResult = await showDialog<AdministratorProfile?>(
      context: context,
      builder: (dialogContext) {
        final firstNameController = TextEditingController(text: _profile!.firstName);
        final lastNameController = TextEditingController(text: _profile!.lastName);
        final emailController = TextEditingController(text: _profile!.email);
        final dniController = TextEditingController(text: _profile!.dni);
        final addressController = TextEditingController(text: _profile!.address);
        final phoneController = TextEditingController(text: _profile!.phone);
        final formKey = GlobalKey<FormState>();

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.edit, color: Color(0xFF1976D2), size: 28),
                      const SizedBox(width: 10),
                      const Text(
                        'Editar datos',
                        style: TextStyle(
                          color: Color(0xFF1976D2),
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      labelText: 'First name',
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: lastNameController,
                    decoration: InputDecoration(
                      labelText: 'Last name',
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: dniController,
                    decoration: InputDecoration(
                      labelText: 'DNI',
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(
                      labelText: 'Address',
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: phoneController,
                    decoration: InputDecoration(
                      labelText: 'Phone',
                      filled: true,
                      fillColor: const Color(0xFFF5F7FA),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF1976D2),
                          textStyle: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () => Navigator.of(dialogContext).pop(null),
                        child: const Text('Cancelar'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1976D2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          elevation: 2,
                        ),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;
                          try {
                            final updated = AdministratorProfile(
                              id: _profile!.id,
                              firstName: firstNameController.text.trim(),
                              lastName: lastNameController.text.trim(),
                              email: emailController.text.trim(),
                              dni: dniController.text.trim(),
                              address: addressController.text.trim(),
                              phone: phoneController.text.trim(),
                              username: _profile!.username,
                              password: _profile!.password,
                            );

                            final profileId = _profile!.id;
                            if (profileId == null) throw Exception('Profile id missing');

                            final result = await _authService.editAdminProfile(profileId, updated);

                            Navigator.of(dialogContext).pop(result ?? updated);
                          } catch (e) {
                            // Optionally show error in the dialog UI
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

    if (updatedResult != null && mounted) {
      setState(() {
        _profile = updatedResult;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Perfil administrador', style: TextStyle(fontWeight: FontWeight.bold)),
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
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(child: Text(_error!, style: TextStyle(color: Colors.white, fontSize: 18)))
              : Column(
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
                      const Icon(Icons.person, size: 48, color: Color(0xFF1976D2)),
                      const SizedBox(height: 18),
                      Text(
                        '${_profile!.firstName} ${_profile!.lastName}',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1976D2),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('ID: ${_profile!.id ?? '-'}', style: const TextStyle(fontSize: 15, color: Colors.grey)),
                      const Divider(),
                      _buildInfoRow('Email', _profile!.email),
                      _buildInfoRow('DNI', _profile!.dni),
                      _buildInfoRow('Address', _profile!.address),
                      _buildInfoRow('Phone', _profile!.phone),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar Perfil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      elevation: 2,
                    ),
                    onPressed: _showEditDialog,
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.delete),
                    label: const Text('Eliminar Perfil'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      elevation: 2,
                    ),
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Confirmar eliminación'),
                          content: const Text('¿Estás seguro de que deseas eliminar este perfil?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true && _profile?.id != null) {
                        try {
                          await _authService.deleteAdminProfile(_profile!.id!);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Perfil eliminado')),
                            );
                            Navigator.of(context).pop();
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error al eliminar: $e')),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
