import 'package:flutter_application/models/ejercicio_models.dart';
import 'package:flutter_application/models/sesion_models.dart';

class SesionData {
  final Sesion? sesion;
  final List<Ejercicio> ejercicios;

  SesionData({required this.sesion, required this.ejercicios});

  factory SesionData.fromJson(Map<String, dynamic> json) {
    var ejerciciosList = (json['ejercicios'] as List? ?? [])
        .map((e) => Ejercicio.fromJson(e))
        .toList();

    return SesionData(
      sesion: json['sesion'] != null ? Sesion.fromJson(json['sesion']) : null,
      ejercicios: ejerciciosList,
    );
  }
}
