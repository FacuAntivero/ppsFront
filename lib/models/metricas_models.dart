import 'dart:convert';

class Metrica {
  final int id;
  final int ejercicio;
  final String nombre;
  final List<String> data;

  Metrica({
    required this.id,
    required this.ejercicio,
    required this.nombre,
    required this.data,
  });

  factory Metrica.fromJson(Map<String, dynamic> json) {
    List<String> dataList = [];

    if (json['data'] != null &&
        json['data'] is String &&
        (json['data'] as String).isNotEmpty) {
      try {
        final List<dynamic> parsedData = jsonDecode(json['data']);
        dataList = parsedData.map((item) => item.toString()).toList();
      } catch (e) {
        dataList = [json['data']];
      }
    }

    return Metrica(
      id: int.parse(json['id'].toString()),
      ejercicio: int.parse(json['ejercicio'].toString()),
      nombre: json['nombre'],
      data: dataList,
    );
  }
}
