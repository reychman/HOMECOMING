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
  final double? latitud; // Nuevo campo
  final double? longitud; // Nuevo campo
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
    this.latitud, // Nuevo campo
    this.longitud, // Nuevo campo
    required this.nombreDueno,
    required this.emailDueno,
    required this.telefonoDueno,
  });

  factory Mascota.fromJson(Map<String, dynamic> json) {
    return Mascota(
      id: json['id'],
      nombre: json['nombre'],
      especie: json['especie'],
      raza: json['raza'],
      sexo: json['sexo'],
      fechaPerdida: json['fecha_perdida'],
      lugarPerdida: json['lugar_perdida'],
      estado: json['estado'],
      descripcion: json['descripcion'],
      foto: json['foto'],
      latitud: json['latitud'] != null ? json['latitud'].toDouble() : null,
      longitud: json['longitud'] != null ? json['longitud'].toDouble() : null,
      nombreDueno: json['nombre_dueno'],
      emailDueno: json['email_dueno'],
      telefonoDueno: json['telefono_dueno'],
    );
  }
}
