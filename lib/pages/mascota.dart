class Mascota {
  final int id;
  final String nombre;
  final String especie;
  final String raza;
  final String sexo;
  final String fechaPerdida;
  final String lugarPerdida;
  final String estado;
  final String descripcion;
  final String foto;
  final double? latitud;
  final double? longitud;
  final String nombreDueno;
  final String emailDueno;
  final String telefonoDueno;

  Mascota({
    required this.id,
    required this.nombre,
    required this.especie,
    required this.raza,
    required this.sexo,
    required this.fechaPerdida,
    required this.lugarPerdida,
    required this.estado,
    required this.descripcion,
    required this.foto,
    this.latitud,
    this.longitud,
    required this.nombreDueno,
    required this.emailDueno,
    required this.telefonoDueno,
  });

  factory Mascota.fromJson(Map<String, dynamic> json) {
    return Mascota(
      id: json['id'] != null ? json['id'] as int : 0, // Proveer un valor predeterminado si es null
      nombre: json['nombre'] ?? 'Desconocido',
      especie: json['especie'] ?? 'Desconocida',
      raza: json['raza'] ?? 'Desconocida',
      sexo: json['sexo'] ?? 'Desconocido',
      fechaPerdida: json['fecha_perdida'] ?? 'Desconocida',
      lugarPerdida: json['lugar_perdida'] ?? 'Desconocido',
      estado: json['estado'] ?? 'Desconocido',
      descripcion: json['descripcion'] ?? 'Sin descripción',
      foto: json['foto'] ?? '',
      latitud: json['latitud'] != null ? (json['latitud'] is double ? json['latitud'] : double.tryParse(json['latitud'].toString())) : null,
      longitud: json['longitud'] != null ? (json['longitud'] is double ? json['longitud'] : double.tryParse(json['longitud'].toString())) : null,
      nombreDueno: json['nombre_dueno'] ?? 'Desconocido',
      emailDueno: json['email_dueno'] ?? '',
      telefonoDueno: json['telefono_dueno'] ?? '',
    );
  }
}
