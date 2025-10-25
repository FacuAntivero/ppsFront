import 'package:flutter/material.dart';
import 'package:flutter_application/screens/auth/login/superuser/superuser_login_screen.dart';
import 'package:flutter_application/services/api_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_application/dialogs/add_professional_dialog.dart';
import 'package:flutter_application/utils/auth_utils.dart';

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
  String? _tipoLicencia;
  String? _estadoLicencia;

  @override
  void initState() {
    super.initState();
    api = ApiService();
    _fetchUsuarios();
    _fetchLicense();
  }

  Future<void> _fetchLicense() async {
    try {
      final res = await api.getActiveLicense(widget.superUser);

      if (res['success'] == true) {
        final lic = res['license'];
        if (lic != null && lic is Map) {
          setState(() {
            _tipoLicencia = lic['tipo_licencia']?.toString();
            // Aseguramos aceptar distintas claves por compatibilidad
            _estadoLicencia = lic['estado']?.toString() ??
                lic['status']?.toString() ??
                lic['state']?.toString();
          });
          return;
        }
      }

      // Si no hay licencia activa o error lógico
      setState(() {
        _tipoLicencia = null;
        _estadoLicencia = null;
      });
    } catch (_) {
      // Usamos '_' para indicar que ignoramos el objeto de excepción
      // También podrías usar 'e' y simplemente no referenciarla: 'catch (e)'
      setState(() {
        _tipoLicencia = null;
        _estadoLicencia = null;
      });
    }
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
    final created = await AddProfessionalDialog.show(
      context,
      api: api,
      superUser: widget.superUser,
    );

    if (created == true) {
      await _fetchUsuarios();
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Usuario creado')));
    }
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
              final resp = await api.changePassword(
                superUser: widget.superUser, // enviado en body
                superUserPassword: superPassCtrl.text,
                targetUser: targetUser,
                newPassword: newPassCtrl.text,
              );

              if (!mounted) return;

              if (resp['success'] == true) {
                if (!ctx.mounted) return;

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
          Text(
              'Licencia: ${_tipoLicencia == null ? 'ELIMINADA' : _tipoLicencia.toString().toUpperCase()}',
              style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 2),
          Row(children: [
            Text(
              'Estado: ${_estadoLicencia == null ? 'ELIMINADA' : _estadoLicencia.toString().toUpperCase()}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 2),
            if (_estadoLicencia == 'expirada' || _estadoLicencia == 'revocada')
              const Icon(Icons.warning, size: 14, color: Colors.black),
          ]),
        ]),
        actions: [
          IconButton(
              onPressed: () async {
                await _fetchUsuarios();
                await _fetchLicense();
              },
              tooltip: 'Refrescar',
              icon: const Icon(Icons.refresh)),
          IconButton(
            onPressed: () => logoutAndNavigate(
              context: context,
              storage: _storage,
              loginPage: const SuperUserLoginScreen(),
            ),
            icon: const Icon(Icons.logout),
          )
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
