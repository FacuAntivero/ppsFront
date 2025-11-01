import 'package:flutter/material.dart';
import 'package:flutter_application/dialogs/change_password.dialog.dart';
import 'package:flutter_application/dialogs/delete_license_dialog.dart';
import 'package:flutter_application/dialogs/configure_license_dialog.dart';
import 'package:flutter_application/screens/auth/login/superuser/superuser_login_screen.dart';
import 'package:flutter_application/services/api_service.dart';
import 'package:flutter_application/utils/auth_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/services.dart';

class AdminDashboard extends StatefulWidget {
  static const routeName = '/admin-dashboard';
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final ApiService api = ApiService();
  final storage = const FlutterSecureStorage();
  bool loading = true;
  String? error;
  List<Map<String, dynamic>> superusers = [];
  List<Map<String, dynamic>> licenses = [];

  String? adminUser;
  String? adminPass;

  @override
  void initState() {
    super.initState();
    _loadAdminAndFetch();
  }

  Future<void> _loadAdminAndFetch() async {
    adminUser = await storage.read(key: 'superUser');
    adminPass = await storage.read(key: 'admin_pass');

    if (adminUser == null || adminPass == null) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error =
            'Error de autenticación: Credenciales de administrador no cargadas. Por favor, asegúrate de haber iniciado sesión como administrador.';
      });
      return;
    }

    await _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() {
      loading = true;
      error = null;
    });

    if (adminUser == null || adminPass == null) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error =
            'Faltan credenciales de administrador para realizar la consulta. Vuelve a iniciar sesión si el problema persiste.';
      });
      return;
    }

    try {
      final sres = await api.adminGetSuperusers(
        adminUser: adminUser!,
        adminPass: adminPass!,
      );
      final lres = await api.licenseList(
        adminUser: adminUser!,
        adminPass: adminPass!,
      );

      if (sres['success'] == true) {
        superusers = List<Map<String, dynamic>>.from(sres['superusers'] ?? []);
      } else {
        error = sres['error']?.toString() ?? 'Error cargando residencias';
      }

      if (lres['success'] == true) {
        licenses = List<Map<String, dynamic>>.from(lres['licenses'] ?? []);
      } else {
        error = (error == null)
            ? (lres['error']?.toString() ?? 'Error cargando licencias')
            : error;
      }

      final mapBySuper = <String, Map<String, dynamic>>{};
      for (final lic in licenses) {
        final su = lic['superUser'] as String?;
        if (su != null) mapBySuper[su] = Map<String, dynamic>.from(lic);
      }

      superusers = superusers.map((s) {
        final suName = (s['superUser'] ?? '') as String;
        final lic = mapBySuper[suName];
        return {
          ...s,
          'id_license': lic != null ? lic['id_license'] : null,
          'tipo_licencia': lic != null ? lic['tipo_licencia'] : null,
          'licencia_estado': lic != null ? lic['estado'] : null,
          'fecha_expiracion': lic != null ? lic['fecha_expiracion'] : null,
        };
      }).toList();
    } catch (e) {
      error = e.toString();
    } finally {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> _onChangeSuperuserPassword(String su) async {
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => ReusablePasswordDialog(
        title: 'Cambiar contraseña de: $su',
        description:
            'Introduce la nueva contraseña para esta Residencia y confírmala.',
        submitButtonText: 'Cambiar',
        requireCurrentPassword:
            false, // <-- CLAVE: Admin no necesita pass actual
      ),
    );

    if (result == null) return; // Usuario canceló

    final newPass = result['new']; // Solo nos interesa la 'new'

    if (newPass == null || newPass.isEmpty) {
      return;
    }

    if (adminUser == null || adminPass == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Error: Credenciales de administrador no disponibles para realizar el cambio.')));
      return;
    }

    if (!mounted) return;
    setState(() => loading = true);

    try {
      final resp = await api.adminChangeSuperuserPassword(
        superUser: su,
        newPassword: newPass,
        adminUser: adminUser!,
        adminPass: adminPass!,
      );

      if (!mounted) return;
      if (resp['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('✅ Contraseña del Superusuario actualizada con éxito')));
      } else {
        final errorMessage =
            resp['error']?.toString() ?? 'Error desconocido del servidor';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('❌ Error al cambiar la contraseña: $errorMessage')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('⚠️ Fallo en la conexión o API: $e.toString()')));
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  // FUNCIÓN AUXILIAR: Muestra el diálogo con la clave de licencia
  Future<void> _showLicenseKeyDialog(String key) async {
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¡Licencia Generada con Éxito!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Guarda esta clave:'),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(26),
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: Theme.of(context).colorScheme.primary),
              ),
              child: SelectableText(
                key,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  letterSpacing: 1.5,
                ),
              ),
            )
          ],
        ),
        actions: [
          // Botón para copiar automáticamente al portapapeles
          TextButton.icon(
            icon: const Icon(Icons.copy),
            onPressed: () {
              // Copia el texto al portapapeles
              Clipboard.setData(ClipboardData(text: key));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Clave copiada al portapapeles.')));
            },
            label: const Text('Copiar y Cerrar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<void> _onDeleteSuperUser(String su) async {
    // 1. Pedir Confirmación (¡MUY IMPORTANTE!)
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 10),
              Text('Confirmar eliminación'),
            ],
          ),
          content: Text(
              '¿Estás seguro de que quieres eliminar a "$su"?\n\nEsta acción también eliminará todas sus licencias asociadas y no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child:
                  const Text('Eliminar', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );

    // Si el usuario presiona "Cancelar", confirmed será false o null
    if (confirmed != true) return;

    // 2. Verificación de credenciales (tu lógica)
    if (adminUser == null || adminPass == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Error: Credenciales de administrador no disponibles.')));
      return;
    }

    if (!mounted) return;
    setState(() => loading = true);

    // 3. Lógica de API
    try {
      final resp = await api.deleteSuperUser(
        superUser: su,
        adminUser: adminUser!,
        adminPass: adminPass!,
      );

      if (!mounted) return;
      if (resp['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('✅ Residencia eliminada correctamente'),
          backgroundColor: Colors.green,
        ));
        await _fetchAll(); // Recargar la lista de residencias
      } else {
        final errorMessage = resp['error']?.toString() ?? 'Error desconocido';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('❌ Error al eliminar: $errorMessage'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('⚠️ Fallo en la conexión o API: $e.toString()'),
        backgroundColor: Colors.red,
      ));
    } finally {
      if (!mounted) return;
      setState(() => loading = false);
    }
  }

  Future<void> _onGenerateLicense() async {
    if (adminUser == null || adminPass == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Error: Credenciales de administrador no cargadas. ¡Inicia sesión!')));
      return;
    }
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const ConfigureLicenseDialog(
        title: 'Generar licencia de Acceso',
        submitButtonText: 'Generar',
      ),
    );

    if (result == null) return; // Usuario canceló

    final String selectedTipo = result['tipo'] ?? 'basica';
    final String maxText = result['max'] ?? '';
    int? maxUsuarios;

    if (maxText.trim().isNotEmpty) {
      maxUsuarios = int.tryParse(maxText.trim());
    } else {
      maxUsuarios = null;
    }

    setState(() => loading = true);

    final resp = await api.licenseGenerate(
        tipoLicencia: selectedTipo,
        maxUsuarios: maxUsuarios,
        adminUser: adminUser,
        adminPass: adminPass);

    if (!mounted) return;
    setState(() => loading = false);

    if (resp['success'] == true) {
      final key = resp['licenseKey'] ?? 'ERROR_SIN_KEY';
      await _showLicenseKeyDialog(key);
      if (!mounted) return;
      await _fetchAll();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content:
              Text(resp['error']?.toString() ?? 'Error generando licencia')));
    }
  }

  Widget _buildSuperuserCard(Map<String, dynamic> s) {
    final name = s['superUser'] ?? '';
    final max = s['cant_usuarios_permitidos'] == null
        ? 'ilimitado'
        : s['cant_usuarios_permitidos'].toString();
    final idLicense = s['id_license']?.toString() ?? '-';
    final tipo = s['tipo_licencia'] ?? '-';
    var estado = s['licencia_estado'] ?? 'revocada';
    final fechaExp = s['fecha_expiracion'] as String?;
    final bool isProtectedAdmin = (name == "admin");

    if (estado == 'revocada' && name == 'admin') {
      estado = "-";
    }

    Color estadoColor;
    switch (estado) {
      case 'activa':
        estadoColor = Colors.green;
        break;
      case 'expirada':
        estadoColor = Colors.orange;
        break;
      case 'revocada':
        estadoColor = Colors.red;
        break;
      case 'pendiente':
        estadoColor = Colors.blueGrey;
        break;
      default:
        estadoColor = Colors.grey;
    }

    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('Max usuarios: $max'),
            Row(
              children: [
                Text('Licencia ID: $idLicense'),
                const SizedBox(width: 12),
                Text('Tipo: $tipo'),
                const SizedBox(width: 12),
                Chip(
                  label:
                      Text(estado, style: const TextStyle(color: Colors.white)),
                  backgroundColor: estadoColor,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            if (fechaExp != null)
              Text('Vence: $fechaExp', style: const TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                Icons.delete_forever,
                color: isProtectedAdmin ? Colors.grey : Colors.red,
              ),
              tooltip: isProtectedAdmin
                  ? 'No se puede eliminar la cuenta de admin'
                  : 'Borrar Residencia',
              onPressed:
                  isProtectedAdmin ? null : () => _onDeleteSuperUser(name),
            ),
            IconButton(
              icon: const Icon(Icons.vpn_key, color: Colors.blue),
              tooltip: 'Cambiar contraseña',
              onPressed: () => _onChangeSuperuserPassword(name),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLicenseCard(Map<String, dynamic> l) {
    final tipo = l['tipo_licencia'] ?? '-';
    final estado = l['estado'] ?? '-';
    final id = l['id_license'];
    final exp = l['fecha_expiracion'] ?? '-';
    final int? maxUsers = l['max_usuarios'];
    return Card(
      child: ListTile(
        title: Text('ID $id — ${tipo.toString().toUpperCase()}'),
        subtitle: Text(
            'Estado: ${estado.toString().toUpperCase()}\nVence: ${exp.toString().toUpperCase()}'),
        isThreeLine: true,
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
              tooltip: 'Borrar licencia',
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: () async {
                final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => DeleteLicenseDialog(
                          licenseId: id,
                          licenseType: tipo,
                        ));
                if (ok == true) {
                  if (adminUser == null || adminPass == null) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            'Error: No se puede borrar la licencia sin credenciales de admin.')));
                    return;
                  }

                  final resp = await api.licenseDelete(
                      id: id, adminUser: adminUser, adminPass: adminPass);
                  if (!mounted) return;

                  if (resp['success'] == true) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Licencia borrada')));
                    await _fetchAll();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(resp['error']?.toString() ?? 'Error')));
                  }
                }
              }),
          IconButton(
              tooltip: 'Caducar licencia',
              icon: const Icon(Icons.hourglass_disabled),
              onPressed: () async {
                if (adminUser == null || adminPass == null) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Error: No se puede expirar la licencia sin credenciales de admin.')));
                  return;
                }

                if (estado == 'expirada') {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('La licencia ya está expirada.')));
                  return;
                }

                final resp = await api.licenseExpire(
                    id: id, adminUser: adminUser, adminPass: adminPass);
                if (!mounted) return;
                if (resp['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Licencia expirada')));
                  await _fetchAll();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(resp['error']?.toString() ?? 'Error')));
                }
              }),

// Botón Renovar (Icono azul)
          IconButton(
            icon: const Icon(Icons.autorenew, color: Colors.blue),
            tooltip: 'Renovar (+1 Año)',
            onPressed: () async {
              if (adminUser == null || adminPass == null) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content:
                        Text('Error: Credenciales de admin no disponibles.')));
                return;
              }

              final resp = await api.licenseRenew(
                  id: id, adminUser: adminUser, adminPass: adminPass);

              if (!mounted) return;
              if (resp['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Licencia renovada por 1 año')));
                await _fetchAll(); // Recargar datos
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text(resp['error']?.toString() ?? 'Error al renovar')));
              }
            },
          ),

// Botón Modificar Tipo (Icono morado)
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.purple),
            tooltip: 'Modificar Tipo/Usuarios',
            onPressed: () async {
              final result = await showDialog<Map<String, String>>(
                context: context,
                builder: (context) => ConfigureLicenseDialog(
                  title: 'Modificar Licencia',
                  submitButtonText: 'Guardar',
                  initialType: tipo,
                  initialMaxUsers: maxUsers,
                ),
              );

              if (result == null) return;

              if (adminUser == null || adminPass == null) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content:
                        Text('Error: Credenciales de admin no disponibles.')));
                return;
              }

              final String newType = result['tipo'] ?? 'basica';
              final String maxText = result['max'] ?? '';

              int? newMaxUsers;
              if (maxText.trim().isNotEmpty) {
                newMaxUsers = int.tryParse(maxText.trim());
              } else {
                newMaxUsers = null;
              }

              final resp = await api.licenseModifyType(
                id: id,
                newType: newType,
                maxUsers: newMaxUsers,
                adminUser: adminUser,
                adminPass: adminPass,
              );

              if (!mounted) return;
              if (resp['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Tipo de licencia modificado')));
                await _fetchAll(); // Recargar datos
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(
                        resp['error']?.toString() ?? 'Error al modificar')));
              }
            },
          ),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Dashboard Administrador'),
            Text('Gestión de residencias y licencias',
                style: TextStyle(fontSize: 14)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _fetchAll,
            tooltip: 'Refrescar datos',
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => logoutAndNavigate(
              context: context,
              storage: storage,
              loginPage: const SuperUserLoginScreen(),
            ),
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onGenerateLicense,
        icon: const Icon(Icons.add),
        label: const Text('Generar licencia'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : (error != null)
                ? Center(child: Text('Error: $error'))
                : RefreshIndicator(
                    onRefresh: _fetchAll,
                    child: ListView(
                      children: [
                        const SizedBox(height: 8),
                        const Text('Residencias',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        ...superusers.map(_buildSuperuserCard),
                        const SizedBox(height: 16),
                        const Text('Licencias',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold)),
                        ...licenses.map(_buildLicenseCard),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
      ),
    );
  }
}
