import 'package:flutter_application/models/metricas_models.dart';

class Ejercicio {
  final int id;
  final String escena;
  final String? inicio;
  final String? fin;
  final int sesion;
  final List<Metrica> metricas;

  Ejercicio({
    required this.id,
    required this.escena,
    required this.sesion,
    this.inicio,
    this.fin,
    required this.metricas,
  });

  factory Ejercicio.fromJson(Map<String, dynamic> json) {
    var metricasList = (json['metricas'] as List? ?? [])
        .map((m) => Metrica.fromJson(m as Map<String, dynamic>))
        .toList();

    return Ejercicio(
      id: int.parse(json['id'].toString()),
      sesion: int.parse(json['sesion'].toString()),
      escena: json['escena'],
      inicio: json['inicio'],
      fin: json['fin'],
      metricas: metricasList,
    );
  }
}
