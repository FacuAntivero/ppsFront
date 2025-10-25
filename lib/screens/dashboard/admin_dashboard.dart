import 'package:flutter/material.dart';
import 'package:flutter_application/dialogs/change_password.dialog.dart';
import 'package:flutter_application/dialogs/delete_license_dialog.dart';
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
    final newPass = await showDialog<String>(
      context: context,
      builder: (ctx) => ChangePasswordDialog(superUser: su),
    );

    // Si el usuario canceló o la validación interna falló
    if (newPass == null || newPass.isEmpty) {
      return;
    }

    if (newPass.length < 6) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('Error: La contraseña debe tener al menos 6 caracteres')));
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
        // Manejo de errores específicos del servidor
        final errorMessage =
            resp['error']?.toString() ?? 'Error desconocido del servidor';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('❌ Error al cambiar la contraseña: $errorMessage')));
      }
    } catch (e) {
      // Manejo de errores de red o excepciones
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('⚠️ Fallo en la conexión o API: ${e.toString()}')));
    } finally {
      if (!mounted) return;
      setState(() => loading = false); // Desactiva el indicador de carga
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

  Future<void> _onGenerateLicense() async {
    if (adminUser == null || adminPass == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Error: Credenciales de administrador no cargadas. ¡Inicia sesión!')));
      return; // Detiene la función si faltan credenciales
    }

    String selectedTipo = 'basica';
    int? maxUsuarios;

    // Usamos una clave para el formulario del diálogo para validación
    final dialogFormKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        String tipo = 'basica';
        final ctrlMax = TextEditingController();

        return AlertDialog(
          // Estilo de diálogo más moderno
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Generar licencia de Acceso',
              style:
                  TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
          content: Form(
            key: dialogFormKey, // Adjuntamos la clave de validación aquí
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dropdown con acento visual
                DropdownButtonFormField<String>(
                  initialValue: tipo,
                  decoration: InputDecoration(
                    labelText: 'Tipo de Licencia',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.star, color: Colors.amber),
                  ),
                  items: const [
                    DropdownMenuItem(
                        value: 'basica', child: Text('Básica (3 usuarios)')),
                    DropdownMenuItem(
                        value: 'mediana', child: Text('Mediana (7 usuarios)')),
                    DropdownMenuItem(
                        value: 'pro', child: Text('Pro (10 usuarios)')),
                    DropdownMenuItem(
                        value: 'custom', child: Text('Personalizada (Custom)')),
                  ],
                  onChanged: (v) {
                    if (v != null) tipo = v;
                  },
                ),
                const SizedBox(height: 16),

                // Campo de texto con validación y estilo mejorado
                TextFormField(
                  controller: ctrlMax,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Máx. Usuarios (Opcional)',
                    hintText: 'Ej. 25 o déjalo vacío',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.people),
                  ),
                  // Validación simple para asegurar que es un número entero positivo o vacío
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    if (int.tryParse(v.trim()) == null) {
                      return 'Debe ser un número entero.';
                    }
                    if (int.parse(v.trim()) < 1) {
                      return 'Mínimo 1 usuario.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: const Text('Cancelar',
                    style: TextStyle(color: Colors.grey))),
            ElevatedButton(
                // Solo se permite presionar si el formulario es válido (solo aplica al TextFormField)
                onPressed: () {
                  if (dialogFormKey.currentState!.validate()) {
                    Navigator.pop(ctx, {'tipo': tipo, 'max': ctrlMax.text});
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, // Color de acento
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Generar',
                    style: TextStyle(color: Colors.white))),
          ],
        );
      },
    );
    if (result == null) return;

    selectedTipo = (result['tipo'] as String?) ?? 'basica';
    final maxText = (result['max'] as String?) ?? '';
    if (maxText.trim().isNotEmpty) {
      maxUsuarios = int.tryParse(maxText.trim());
    } else {
      maxUsuarios = null; // Mantiene el valor por defecto del backend
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
      final key = resp['licenseKey'];

      await _showLicenseKeyDialog(key);

      if (!mounted) return;
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
            const SizedBox(height: 4),
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
        trailing: IconButton(
          icon: const Icon(Icons.vpn_key),
          tooltip: 'Cambiar contraseña',
          onPressed: () => _onChangeSuperuserPassword(name),
        ),
      ),
    );
  }

  Widget _buildLicenseCard(Map<String, dynamic> l) {
    final tipo = l['tipo_licencia'] ?? '-';
    final estado = l['estado'] ?? '-';
    final id = l['id_license'];
    final exp = l['fecha_expiracion'] ?? '-';
    return Card(
      child: ListTile(
        title: Text('ID $id — ${tipo.toString().toUpperCase()}'),
        subtitle: Text(
            'Estado: ${estado.toString().toUpperCase()}\nVence: ${exp.toString().toUpperCase()}'),
        isThreeLine: true,
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
              tooltip: 'Borrar licencia',
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final ok = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => DeleteLicenseDialog(
                          licenseId: id,
                          licenseType: tipo,
                        ));
                if (ok == true) {
                  // Verificación de credenciales
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
                // Verificación de credenciales
                if (adminUser == null || adminPass == null) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(
                          'Error: No se puede expirar la licencia sin credenciales de admin.')));
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
