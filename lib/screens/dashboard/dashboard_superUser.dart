// lib/screens/dashboard/superuser_dashboard.dart
import 'package:flutter/material.dart';
import 'package:flutter_application/screens/auth/login/superuser/superuser_login_screen.dart';
import 'package:flutter_application/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Pantalla principal del dashboard para SuperUser (residencia).
class SuperUserDashboard extends StatefulWidget {
  static const String routeName = '/superuser-dashboard';

  final String superUser;
  final String? tipoLicencia;

  const SuperUserDashboard({
    required this.superUser,
    this.tipoLicencia,
    super.key,
  });

  @override
  State<SuperUserDashboard> createState() => _SuperUserDashboardState();
}

class _SuperUserDashboardState extends State<SuperUserDashboard> {
  late final ApiService api;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> usuarios = []; // cada item: { user, nombreReal }
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    // puedes pasar baseUrl si lo necesitas: ApiService(baseUrl: 'http://...')
    api = ApiService();
    _fetchUsuarios();
  }

  Future<void> _logoutAndGoToLogin() async {
    // (opcional) confirmación
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Seguro que querés cerrar sesión?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancelar')),
          TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Cerrar sesión')),
        ],
      ),
    );
    if (ok != true) return;

    // 1) limpiar credenciales / token
    await _storage.delete(key: 'superUser');
    await _storage.delete(key: 'tipo_licencia');
    // await _storage.deleteAll(); // si querés borrar todo

    // 2) navegar al login y eliminar todas las rutas anteriores
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const UserLoginScreen()),
      (route) => false,
    );
  }

  Future<void> _fetchUsuarios() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final res = await api.getUsuariosSuperUser(widget.superUser);
      if (res['success'] == true) {
        final rawList = res['usuarios'] as List<dynamic>;
        usuarios =
            rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } else {
        _error = res['error']?.toString() ?? 'Error cargando usuarios';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _showCreateUserDialog() async {
    final userCtrl = TextEditingController();
    final nombreCtrl = TextEditingController();
    final passCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool submitting = false;
    String? remoteError;
    bool passwordVisible = false;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setStateDialog) {
          // helper to submit
          Future<void> submit() async {
            if (!formKey.currentState!.validate()) return;
            setStateDialog(() {
              submitting = true;
              remoteError = null;
            });
            try {
              final resp = await api.createUsuario(
                user: userCtrl.text.trim(),
                superUser: widget.superUser,
                nombreReal: nombreCtrl.text.trim(),
                password: passCtrl.text,
              );
              if (resp['success'] == true) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Usuario creado')));
                await _fetchUsuarios();
                return;
              } else {
                final err =
                    resp['error'] ?? resp['message'] ?? 'Error creando usuario';
                setStateDialog(() => remoteError = err.toString());
              }
            } catch (e) {
              setStateDialog(() => remoteError = 'Error: $e');
            } finally {
              setStateDialog(() => submitting = false);
            }
          }

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Agregar profesional',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                          IconButton(
                            onPressed: submitting
                                ? null
                                : () => Navigator.of(ctx).pop(),
                            icon: const Icon(Icons.close),
                          )
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Form
                      Form(
                        key: formKey,
                        child: AutofillGroup(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: userCtrl,
                                autofocus: true,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.person_outline),
                                  labelText: 'Usuario (login)',
                                  hintText: 'ej: licgonzalez',
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().length < 3)
                                        ? 'Min 3 caracteres'
                                        : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: nombreCtrl,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.badge_outlined),
                                  labelText: 'Nombre real',
                                  hintText: 'Nombre completo',
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (v) =>
                                    (v == null || v.trim().length < 3)
                                        ? 'Min 3 caracteres'
                                        : null,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: passCtrl,
                                obscureText: !passwordVisible,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  labelText: 'Contraseña',
                                  hintText: 'Min 6 caracteres',
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 14),
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  suffixIcon: IconButton(
                                    icon: Icon(passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () => setStateDialog(() =>
                                        passwordVisible = !passwordVisible),
                                  ),
                                ),
                                validator: (v) => (v == null || v.length < 6)
                                    ? 'Min 6 caracteres'
                                    : null,
                                onFieldSubmitted: (_) => submit(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Remote / validation error
                      if (remoteError != null) ...[
                        const SizedBox(height: 12),
                        Text(remoteError!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center),
                      ],

                      const SizedBox(height: 16),

                      // Actions
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: submitting
                                  ? null
                                  : () => Navigator.of(ctx).pop(),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: submitting ? null : submit,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                              ),
                              child: submitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text('Crear'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );
  }

  Future<void> _showChangePasswordDialog(String targetUser) async {
    final superPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool submitting = false;
    bool showSuperPass = false;
    bool showNewPass = false;
    bool showConfirm = false;
    String? remoteError;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setStateDialog) {
          Future<void> submit() async {
            if (!formKey.currentState!.validate()) return;

            // Validación de igualdad en frontend
            if (newPassCtrl.text != confirmCtrl.text) {
              setStateDialog(() => remoteError =
                  'La nueva contraseña y su confirmación no coinciden');
              return;
            }

            setStateDialog(() {
              submitting = true;
              remoteError = null;
            });

            try {
              // Llamada al API - enviamos superUser en el body (compatibilidad)
              final resp = await api.changePassword(
                superUser: widget.superUser, // enviado en body
                superUserPassword: superPassCtrl.text,
                targetUser: targetUser,
                newPassword: newPassCtrl.text,
              );

              if (resp['success'] == true) {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Contraseña actualizada correctamente')),
                );
                return;
              }

              // Mostrar mensaje del backend si existe
              setStateDialog(() {
                remoteError = resp['error']?.toString() ??
                    resp['message']?.toString() ??
                    'Error cambiando contraseña';
                submitting = false;
              });
            } catch (e) {
              setStateDialog(() {
                remoteError = 'Error inesperado: $e';
                submitting = false;
              });
            }
          }

          return Dialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18.0, vertical: 14.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Cambiar contraseña',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                          ),
                          IconButton(
                            onPressed: submitting
                                ? null
                                : () => Navigator.of(ctx).pop(),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),

                      // Contexto
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Usuario: $targetUser',
                            style: TextStyle(
                                fontSize: 15, color: Colors.grey[700])),
                      ),
                      const SizedBox(height: 12),

                      // Formulario
                      Form(
                        key: formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              height: 60,
                              child: TextFormField(
                                controller: superPassCtrl,
                                obscureText: !showSuperPass,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.key),
                                  labelText: 'Tu contraseña (SuperUser)',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  suffixIcon: IconButton(
                                    icon: Icon(showSuperPass
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () => setStateDialog(
                                        () => showSuperPass = !showSuperPass),
                                  ),
                                ),
                                validator: (v) => (v == null || v.length < 6)
                                    ? 'Min 6 caracteres'
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 60,
                              child: TextFormField(
                                controller: newPassCtrl,
                                obscureText: !showNewPass,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock_outline),
                                  labelText: 'Nueva contraseña',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  suffixIcon: IconButton(
                                    icon: Icon(showNewPass
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () => setStateDialog(
                                        () => showNewPass = !showNewPass),
                                  ),
                                ),
                                validator: (v) => (v == null || v.length < 6)
                                    ? 'Min 6 caracteres'
                                    : null,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              height: 60,
                              child: TextFormField(
                                controller: confirmCtrl,
                                obscureText: !showConfirm,
                                decoration: InputDecoration(
                                  prefixIcon: const Icon(Icons.lock),
                                  labelText: 'Confirmar nueva contraseña',
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  suffixIcon: IconButton(
                                    icon: Icon(showConfirm
                                        ? Icons.visibility
                                        : Icons.visibility_off),
                                    onPressed: () => setStateDialog(
                                        () => showConfirm = !showConfirm),
                                  ),
                                ),
                                validator: (v) => (v == null || v.length < 6)
                                    ? 'Min 6 caracteres'
                                    : null,
                                onFieldSubmitted: (_) => submit(),
                              ),
                            ),
                            if (remoteError != null) ...[
                              const SizedBox(height: 12),
                              Text(remoteError!,
                                  style: const TextStyle(color: Colors.red),
                                  textAlign: TextAlign.center),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Acciones
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: submitting
                                  ? null
                                  : () => Navigator.of(ctx).pop(),
                              style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14)),
                              child: const Text('Cancelar'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: submitting ? null : submit,
                              style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14)),
                              child: submitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2))
                                  : const Text('Cambiar contraseña'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );

    // limpiar controllers
    superPassCtrl.dispose();
    newPassCtrl.dispose();
    confirmCtrl.dispose();
  }

  Widget _buildUserCard(Map<String, dynamic> u) {
    final username = u['user']?.toString() ?? '';
    final nombreReal = u['nombreReal']?.toString() ?? '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: CircleAvatar(
            child: Text(username.isNotEmpty ? username[0].toUpperCase() : '?')),
        title: Text(nombreReal.isNotEmpty ? nombreReal : username,
            overflow: TextOverflow.ellipsis),
        subtitle: username != nombreReal ? Text(username) : null,
        trailing: IconButton(
          icon: const Icon(Icons.vpn_key),
          tooltip: 'Cambiar contraseña',
          onPressed: () => _showChangePasswordDialog(username),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.superUser,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          if (widget.tipoLicencia != null)
            Text('Licencia: ${widget.tipoLicencia}',
                style: const TextStyle(fontSize: 12)),
        ]),
        actions: [
          IconButton(
            onPressed: _fetchUsuarios,
            tooltip: 'Refrescar',
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: _logoutAndGoToLogin,
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateUserDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Agregar usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(child: Text('Error: $_error'))
                : RefreshIndicator(
                    onRefresh: _fetchUsuarios,
                    child: usuarios.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 120),
                              Center(
                                  child: Text('No hay usuarios registrados')),
                            ],
                          )
                        : ListView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: usuarios.length,
                            itemBuilder: (context, index) {
                              final u = usuarios[index];
                              return _buildUserCard(u);
                            },
                          ),
                  ),
      ),
    );
  }
}
