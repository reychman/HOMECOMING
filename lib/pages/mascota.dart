
class Mascota {
  final int id;
  final String nombre;
  final String especie;
  final String raza;
  final String sexo;
  final String fechaPerdida;
  final String lugarPerdida;
  final String fechaEncontrado;
  final String estado;
  final String descripcion;
  final List<String> fotos; // Cambiamos foto por una lista de fotos
  final double? latitud;
  final double? longitud;
  final String nombreDueno;
  final String primerApellidoDueno;
  final String segundoApellidoDueno;
  final String emailDueno;
  final String telefonoDueno;
  final String estadoRegistro;
  

  Mascota({
    required this.id,
    required this.nombre,
    required this.especie,
    required this.raza,
    required this.sexo,
    required this.fechaPerdida,
    required this.lugarPerdida,
    required this.fechaEncontrado,
    required this.estado,
    required this.descripcion,
    required this.fotos, // Lista de fotos
    this.latitud,
    this.longitud,
    required this.nombreDueno,
    required this.primerApellidoDueno,
    required this.segundoApellidoDueno,
    required this.emailDueno,
    required this.telefonoDueno,
    required this.estadoRegistro,
  });

factory Mascota.fromJson(Map<String, dynamic> json) {
    return Mascota(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0, // Convertir el id a int
      nombre: json['nombre'] ?? 'Desconocido',
      especie: json['especie'] ?? 'Desconocida',
      raza: json['raza'] ?? 'Desconocida',
      sexo: json['sexo'] ?? 'Desconocido',
      fechaPerdida: json['fecha_perdida'] ?? 'Desconocido',
      lugarPerdida: json['lugar_perdida'] ?? 'Desconocido',
      fechaEncontrado: json['fechaEncontrado'] ?? 'Desconocido',
      estado: json['estado'] ?? 'Desconocido',
      descripcion: json['descripcion'] ?? 'Sin descripción',
      fotos: json['fotos'] != null ? List<String>.from(json['fotos']) : [], // Convertir fotos en una lista
latitud: json['latitud'] != null && json['latitud'] is num ? (json['latitud'] as num).toDouble() : null,
longitud: json['longitud'] != null && json['longitud'] is num ? (json['longitud'] as num).toDouble() : null,
      nombreDueno: json['nombre_dueno'] ?? 'Desconocido',
      primerApellidoDueno: json['primer_apellido_dueno'] ?? '',
      segundoApellidoDueno: json['segundo_apellido_dueno'] ?? '',
      emailDueno: json['email_dueno'] ?? '',
      telefonoDueno: json['telefono_dueno'] ?? '',
      estadoRegistro: json['estado_registro'] ?? '',
    );
  }
  /*factory Mascota.fromJson(Map<String, dynamic> json) {
    return Mascota(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) ?? 0 : 0, // Convertir el id a int
      nombre: json['nombre'] ?? 'Desconocido',
      especie: json['especie'] ?? 'Desconocida',
      raza: json['raza'] ?? 'Desconocida',
      sexo: json['sexo'] ?? 'Desconocido',
      fechaPerdida: json['fecha_perdida'] ?? 'Desconocido',
      lugarPerdida: json['lugar_perdida'] ?? 'Desconocido',
      fechaEncontrado: json['fechaEncontrado'] ?? 'Desconocido',
      estado: json['estado'] ?? 'Desconocido',
      descripcion: json['descripcion'] ?? 'Sin descripción',
      fotos: json['fotos'] != null ? List<String>.from(json['fotos']) : [], // Convertir fotos en una lista
      latitud: json['latitud'] != null ? (json['latitud'] is double ? json['latitud'] : double.tryParse(json['latitud'].toString())) : null,
      longitud: json['longitud'] != null ? (json['longitud'] is double ? json['longitud'] : double.tryParse(json['longitud'].toString())) : null,
      nombreDueno: json['nombre_dueno'] ?? 'Desconocido',
      primerApellidoDueno: json['primer_apellido_dueno'] ?? '',
      segundoApellidoDueno: json['segundo_apellido_dueno'] ?? '',
      emailDueno: json['email_dueno'] ?? '',
      telefonoDueno: json['telefono_dueno'] ?? '',
      estadoRegistro: json['estado_registro'] ?? '',
    );
  }*/
}
