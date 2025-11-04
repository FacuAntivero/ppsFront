import 'package:flutter/material.dart';
import 'package:flutter_application/services/api_service.dart';
import 'package:flutter_application/widgets/superUser_session_card.dart';

class ResidenciaExpansionCard extends StatefulWidget {
  final ApiService api;
  final Map<String, dynamic> superuserData;
  final String? adminUser;
  final String? adminPass;
  final VoidCallback onChangePassword;
  final VoidCallback onDeleteSuperUser;
  final bool showPatientName;

  const ResidenciaExpansionCard({
    super.key,
    required this.api,
    required this.superuserData,
    required this.adminUser,
    required this.adminPass,
    required this.onChangePassword,
    required this.onDeleteSuperUser,
    this.showPatientName = true,
  });

  @override
  State<ResidenciaExpansionCard> createState() =>
      _ResidenciaExpansionCardState();
}

class _ResidenciaExpansionCardState extends State<ResidenciaExpansionCard> {
  bool _isLoading = false;
  String? _error;
  List<Map<String, dynamic>> _profesionales = []; // Lista de profesionales

  Future<void> _loadProfesionales() async {
    // Si ya cargamos, no lo hacemos de nuevo
    if (_profesionales.isNotEmpty || _isLoading) return;

    setState(() => _isLoading = true);

    // El SuperUser  tiene su propio endpoint para ver sus usuarios
    try {
      final res = await widget.api.getUsuariosSuperUser(
        widget.superuserData['superUser'],
      );

      if (res['success'] == true) {
        final rawList = res['usuarios'] as List<dynamic>;
        _profesionales =
            rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      } else {
        _error = res['error']?.toString() ?? 'Error cargando profesionales';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extraemos los datos de la Residencia (SuperUser)
    final s = widget.superuserData;
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
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        // --- Encabezado de la Residencia  ---
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
              onPressed: isProtectedAdmin ? null : widget.onDeleteSuperUser,
            ),
            IconButton(
              icon: const Icon(Icons.vpn_key, color: Colors.blue),
              tooltip: 'Cambiar contraseña',
              onPressed: widget.onChangePassword,
            ),
          ],
        ),

        // --- Lógica de Expansión ---
        onExpansionChanged: (isExpanding) {
          if (isExpanding) {
            _loadProfesionales();
          }
        },

        // --- Hijos (Contenido Expandido) ---
        children: [_buildProfesionalesList()],
      ),
    );
  }

  /// Widget interno para mostrar la lista de profesionales
  Widget _buildProfesionalesList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          'Error al cargar profesionales: $_error',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }
    if (_profesionales.isEmpty) {
      return Container(
        color: Colors.grey.shade50,
        padding: const EdgeInsets.all(16.0),
        child: const Center(
          child: Text('Esta residencia no tiene profesionales registrados.'),
        ),
      );
    }

    // Creamos la lista de 'ProfesionalSessionCard' (el widget del Canvas)
    return Container(
      color: Colors.grey.shade50,
      constraints: const BoxConstraints(maxHeight: 400),
      child: ListView.builder(
        padding: const EdgeInsets.all(8.0),
        shrinkWrap: true,
        itemCount: _profesionales.length,
        itemBuilder: (context, index) {
          final profesional = _profesionales[index];
          return ProfesionalSessionCard(
            profesionalData: profesional,
            apiService: widget.api,
            onChangePassword: () {
              // NOTA: El Admin no puede cambiar la pass de un Profesional
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text(
                      'La contraseña de un profesional solo puede ser cambiada por su Residencia.')));
            },
            showPatientName: widget.showPatientName,
          );
        },
      ),
    );
  }
}
