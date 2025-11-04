import 'package:flutter/material.dart';
import 'package:flutter_application/dialogs/change_password.dialog.dart';
import 'package:flutter_application/screens/auth/login/superuser/superuser_login_screen.dart';
import 'package:flutter_application/services/api_service.dart';
import 'package:flutter_application/widgets/superUser_session_card.dart';
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
  List<Map<String, dynamic>> usuarios = [];
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
    } catch (e) {
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
    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ReusablePasswordDialog(
        title: 'Cambiar contraseña de: $targetUser',
        description:
            'Ingresa tu contraseña de Residencia actual para autorizar el cambio.',
        submitButtonText: 'Cambiar Contraseña',
        requireCurrentPassword:
            true, // <-- CLAVE: Residencia SÍ necesita pass actual
      ),
    );

    if (result == null) return; // Usuario canceló

    final currentPass = result['current'];
    final newPass = result['new'];

    if (currentPass == null || newPass == null) {
      return;
    }

    setState(() => _loading = true);
    try {
      final resp = await api.changePassword(
        superUser: widget.superUser,
        superUserPassword: currentPass,
        targetUser: targetUser,
        newPassword: newPass,
      );

      if (!mounted) return;

      if (resp['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contraseña actualizada correctamente')),
        );

        return;
      }

      final remoteError = resp['error']?.toString() ??
          resp['message']?.toString() ??
          'Error cambiando contraseña';

      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(remoteError)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error inesperado: $e')));
    } finally {
      if (!mounted) return;
      setState(() => _loading = false);
    }
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

                              // Llamamos al widget 'ProfesionalSessionCard'
                              return ProfesionalSessionCard(
                                profesionalData: u,
                                onChangePassword: () =>
                                    _showChangePasswordDialog(u['user']),
                                apiService: api,
                              );
                            },
                          ),
                  ),
      ),
    );
  }
}
