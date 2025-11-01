// En lib/models/sesion_models.dart

class Sesion {
  final int id;
  final String paciente;
  final String profesional;
  final String superUser;
  final String inicio;
  final String estadoInicial;
  final String? fin;
  final String? estadoFinal;
  final String? comentarios;

  Sesion({
    required this.id,
    required this.paciente,
    required this.profesional,
    required this.superUser,
    required this.inicio,
    required this.estadoInicial,
    this.fin,
    this.estadoFinal,
    this.comentarios,
  });

  factory Sesion.fromJson(Map<String, dynamic> json) {
    return Sesion(
      id: int.parse(json['id'].toString()),
      
      paciente: json['paciente'] ?? 'Paciente Desconocido',
      profesional: json['profesional'] ?? 'N/A',
      superUser: json['superUser'] ?? 'N/A',
      inicio: json['inicio'] ?? 'Fecha desconocida',
      estadoInicial: json['estadoInicial'] ?? 'N/A',
      fin: json['fin'],
      estadoFinal: json['estadoFinal'],
      comentarios: json['comentarios'],
    );
  }
}