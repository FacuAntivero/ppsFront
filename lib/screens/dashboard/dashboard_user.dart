import 'package:flutter/material.dart';
import 'package:flutter_application/models/ejercicio_models.dart';
import 'package:flutter_application/models/metricas_models.dart';
import 'package:flutter_application/models/sesion_data_models.dart';
import 'package:flutter_application/screens/auth/login/superUser/superuser_login_screen.dart';
import 'package:flutter_application/services/api_service.dart';
import 'package:flutter_application/utils/auth_utils.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserDashboard extends StatefulWidget {
  static const String routeName = '/user-dashboard';

  final String usuario;
  final String superUser;

  const UserDashboard({
    required this.usuario,
    required this.superUser,
    super.key,
  });

  @override
  State<UserDashboard> createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  final _storage = const FlutterSecureStorage();

  // 💡 Instancia de tu servicio de API
  final ApiService _apiService = ApiService();

  // Lista de datos de sesión
  List<SesionData> _sesionesData = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchSessionData();
  }

  /// Llama a la API para obtener los datos
  Future<void> _fetchSessionData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final List<SesionData> loadedSessions = [];
    String? firstError;

    try {
      final List<dynamic> decodedList =
          await _apiService.fetchSessions(widget.usuario);

      // Parsea la lista de JSONs UNO POR UNO
      for (var item in decodedList) {
        try {
          final sesionData = SesionData.fromJson(item as Map<String, dynamic>);
          loadedSessions.add(sesionData);
        } catch (e) {
          firstError ??=
              "Error al parsear la sesión ID: ${item['sesion']?['id'] ?? '??'} - $e";
        }
      }

      setState(() {
        _sesionesData = loadedSessions;
        _error = firstError;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = "Error al cargar los datos: $e";
        _isLoading = false;
      });
    }
  }

  /// Calcula la duración entre dos fechas
  String _calculateDuration(String? inicioStr, String? finStr) {
    if (inicioStr == null || finStr == null) return 'En curso';
    try {
      final inicio = DateTime.parse(inicioStr);
      final fin = DateTime.parse(finStr);
      final duration = fin.difference(inicio);

      if (duration.inMinutes > 0) {
        return '${duration.inMinutes} min ${duration.inSeconds.remainder(60)} seg';
      } else {
        return '${duration.inSeconds} segundos';
      }
    } catch (e) {
      return 'N/A';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido ${widget.usuario}',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              'Residencia: ${widget.superUser}',
              style: TextStyle(
                fontSize: 15,
                color: const Color.fromARGB(255, 59, 59, 59),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _fetchSessionData,
            tooltip: 'Refrescar',
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () => logoutAndNavigate(
              context: context,
              storage: _storage,
              loginPage: const SuperUserLoginScreen(),
            ),
            tooltip: 'Cerrar sesión',
            icon: const Icon(Icons.logout),
          )
        ],
      ),
      body: _buildBody(),
    );
  }

  /// Construye el cuerpo principal
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_sesionesData.isEmpty) {
      return Center(
        child: Text(
          _error ?? 'No se encontraron datos de sesión.',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _error != null ? Colors.red : Colors.black),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Muestra la lista de sesiones
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: _sesionesData.length,
      itemBuilder: (context, index) {
        final sesionData = _sesionesData[index];
        return _buildSessionCard(sesionData);
      },
    );
  }

  Widget _buildSessionCard(SesionData sesionData) {
    if (sesionData.sesion == null) return const SizedBox.shrink();

    final sesion = sesionData.sesion!;

    // (Verifica si hay datos extra para mostrar)
    final bool hasExtraData =
        (sesion.estadoInicial.isNotEmpty && sesion.estadoInicial != "N/A") ||
            (sesion.estadoFinal != null &&
                sesion.estadoFinal!.isNotEmpty &&
                sesion.estadoFinal != "N/A") ||
            (sesion.comentarios != null && sesion.comentarios!.isNotEmpty);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        // Encabezado de la Sesión
        leading:
            Icon(Icons.folder_shared, color: Theme.of(context).primaryColor),
        title: Text(
          'Paciente: ${sesion.paciente}',
          style: Theme.of(context)
              .textTheme
              .titleLarge
              ?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text(
            'Sesión #${sesion.id}  •  Duración: ${_calculateDuration(sesion.inicio, sesion.fin)}'),

        // Contenido (Hijos): La lista de ejercicios
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mostramos esta sección solo si hay datos que mostrar
                if (hasExtraData)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Mostramos solo los campos que no son nulos ni están vacíos
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
                  child: Text('Ejercicios Realizados en esta Sesión:',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700)),
                ),
                const Divider(),
                // Llamamos a la función que construye la lista de ejercicios
                _buildExerciseList(sesionData.ejercicios),
              ],
            ),
          )
        ],
      ),
    );
  }

  /// Crea una fila de información (Icono + Título + Descripción)
  Widget _buildInfoRow(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14),
                ),
                Text(
                  description,
                  style: const TextStyle(fontSize: 14),
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
          elevation: 1,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          child: ExpansionTile(
            leading: const Icon(Icons.fitness_center),
            title: Text(ejercicio.escena,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                'Duración: ${_calculateDuration(ejercicio.inicio, ejercicio.fin)}'),
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
        child: Text('Sin métricas registradas.'),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
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
            leading: const Icon(Icons.analytics_outlined, color: Colors.teal),
            title: Text(metrica.nombre, style: const TextStyle(fontSize: 14)),
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
