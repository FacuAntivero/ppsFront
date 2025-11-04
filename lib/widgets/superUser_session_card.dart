import 'package:flutter/material.dart';
import 'package:flutter_application/models/ejercicio_models.dart';
import 'package:flutter_application/models/metricas_models.dart';
import 'package:flutter_application/models/sesion_data_models.dart';
import 'package:flutter_application/services/api_service.dart';

class ProfesionalSessionCard extends StatefulWidget {
  final Map<String, dynamic> profesionalData;
  final VoidCallback onChangePassword;
  final ApiService apiService;
  final bool showPatientName;

  const ProfesionalSessionCard({
    super.key,
    required this.profesionalData,
    required this.onChangePassword,
    required this.apiService,
    this.showPatientName = true,
  });

  @override
  State<ProfesionalSessionCard> createState() => _ProfesionalSessionCardState();
}

class _ProfesionalSessionCardState extends State<ProfesionalSessionCard> {
  bool _isLoading = false;
  List<SesionData>? _sesionesData;
  String? _error;

  // Función de ayuda para calcular duración
  String _calculateDuration(String? inicioStr, String? finStr) {
    if (inicioStr == null || finStr == null) return 'En curso';
    try {
      final inicio = DateTime.parse(inicioStr);
      final fin = DateTime.parse(finStr);
      final duration = fin.difference(inicio);
      if (duration.inMinutes > 0) {
        return '${duration.inMinutes}m ${duration.inSeconds.remainder(60)}s';
      } else {
        return '${duration.inSeconds}s';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  /// Carga los datos SÓLO cuando se expande la tarjeta
  Future<void> _loadSessions() async {
    // Si ya cargamos los datos (o si ya está cargando), no hacemos nada
    if (_sesionesData != null || _isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final String profesionalUsername = widget.profesionalData['user'];
      final List<dynamic> jsonList =
          await widget.apiService.fetchSessions(profesionalUsername);

      // Parseamos los datos usando los Modelos
      final parsedList = jsonList
          .map((item) => SesionData.fromJson(item as Map<String, dynamic>))
          .toList();

      setState(() {
        _sesionesData = parsedList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final username = widget.profesionalData['user']?.toString() ?? '';
    final nombreReal = widget.profesionalData['nombreReal']?.toString() ?? '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ExpansionTile(
        leading: CircleAvatar(
            child: Text(username.isNotEmpty ? username[0].toUpperCase() : '?')),
        title: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nombreReal.isNotEmpty ? nombreReal : username,
                      overflow: TextOverflow.ellipsis),
                  if (username != nombreReal)
                    Text(username,
                        style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.vpn_key),
              color: Colors.grey.shade600,
              tooltip: 'Cambiar contraseña',
              onPressed: widget.onChangePassword, // Llama al callback
            ),
          ],
        ),

        // Esta función se llama CADA VEZ que el usuario expande o colapsa
        onExpansionChanged: (isExpanding) {
          if (isExpanding) {
            _loadSessions(); // Cargamos los datos solo si se expande
          }
        },

        children: [
          _buildChildrenContent(),
        ],
      ),
    );
  }

  /// Widget interno para mostrar el contenido de la expansión
  Widget _buildChildrenContent() {
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
          'Error al cargar sesiones: $_error',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_sesionesData == null) {
      // Estado inicial (antes de expandir, no muestra nada)
      return const SizedBox.shrink();
    }

    if (_sesionesData!.isEmpty) {
      return Container(
        color: Colors.grey.shade50,
        padding: const EdgeInsets.all(16.0),
        child: const Center(
          child: Text('Este profesional aún no tiene sesiones registradas.'),
        ),
      );
    }

    return Container(
      color: Colors.grey.shade50, // Un fondo ligero para el área expandida
      constraints: const BoxConstraints(maxHeight: 400),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
        shrinkWrap: true,
        itemCount: _sesionesData!.length,
        itemBuilder: (context, index) {
          final sesionData = _sesionesData![index];
          if (sesionData.sesion == null) return const SizedBox.shrink();

          // Reutilizamos la lógica del otro dashboard
          return _buildSessionCard(sesionData);
        },
      ),
    );
  }

  /// Crea una tarjeta expandible para UNA sesión
  Widget _buildSessionCard(SesionData sesionData) {
    final sesion = sesionData.sesion!;

    final bool hasExtraData =
        (sesion.estadoInicial.isNotEmpty && sesion.estadoInicial != "N/A") ||
            (sesion.estadoFinal != null &&
                sesion.estadoFinal!.isNotEmpty &&
                sesion.estadoFinal != "N/A") ||
            (sesion.comentarios != null && sesion.comentarios!.isNotEmpty);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: ExpansionTile(
        leading:
            Icon(Icons.folder_shared, color: Theme.of(context).primaryColor),
        title: Text(
          widget.showPatientName
              ? 'Paciente: ${sesion.paciente}'
              : 'Paciente: (Confidencial)',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          'Sesión #${sesion.id} • ${_calculateDuration(sesion.inicio, sesion.fin)}',
          style: const TextStyle(fontSize: 12),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasExtraData)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (sesion.estadoInicial.isNotEmpty &&
                            sesion.estadoInicial != "N/A")
                          _buildInfoRow(Icons.sentiment_neutral,
                              'Estado Inicial', sesion.estadoInicial),
                        if (sesion.estadoFinal != null &&
                            sesion.estadoFinal!.isNotEmpty &&
                            sesion.estadoFinal != "N/A")
                          _buildInfoRow(Icons.sentiment_satisfied_alt,
                              'Estado Final', sesion.estadoFinal!),
                        if (sesion.comentarios != null &&
                            sesion.comentarios!.isNotEmpty)
                          _buildInfoRow(Icons.comment_outlined, 'Comentarios',
                              sesion.comentarios!),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                  child: Text('Ejercicios:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700)),
                ),
                const Divider(),
                _buildExerciseList(sesionData.ejercicios),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Widget de ayuda para filas de info (Estado Inicial, etc.)
  Widget _buildInfoRow(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Devuelve una Columna de Ejercicios
  Widget _buildExerciseList(List<Ejercicio> ejercicios) {
    if (ejercicios.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No se registraron ejercicios en esta sesión.'),
      );
    }

    return Column(
      children: ejercicios.map((ejercicio) {
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 8),
            leading: const Icon(Icons.fitness_center, size: 20),
            title: Text(ejercicio.escena,
                style:
                    const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            subtitle: Text(
              'Duración: ${_calculateDuration(ejercicio.inicio, ejercicio.fin)}',
              style: const TextStyle(fontSize: 12),
            ),
            children: [
              _buildMetricsList(ejercicio.metricas),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Muestra la lista de métricas
  Widget _buildMetricsList(List<Metrica> metricas) {
    if (metricas.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child:
            Text('Sin métricas registradas.', style: TextStyle(fontSize: 12)),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
      child: Column(
        children: metricas.map((metrica) {
          // Asumimos que 'metrica.data' ya es un List<String> gracias al Modelo
          final List<String> dataLines = metrica.data;

          if (dataLines.isEmpty ||
              (dataLines.length == 1 && dataLines[0].isEmpty)) {
            return const SizedBox.shrink();
          }

          return ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 10),
            leading: const Icon(Icons.analytics_outlined,
                color: Colors.teal, size: 18),
            title: Text(metrica.nombre, style: const TextStyle(fontSize: 13)),
            children: [
              Container(
                color: Colors.grey.shade100,
                constraints: const BoxConstraints(maxHeight: 200),
                child: ListView(
                  padding: const EdgeInsets.all(12),
                  shrinkWrap: true,
                  children: dataLines
                      .map((linea) => Text(linea,
                          style: const TextStyle(
                              fontSize: 12, fontFamily: 'monospace')))
                      .toList(),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
