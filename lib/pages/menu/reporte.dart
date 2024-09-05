class Reporte {
  final int mascotasPerdidas;
  final int mascotasEncontradas;
  final int usuariosAdministradores;
  final int usuariosPropietarios;
  final int usuariosRefugios;

  Reporte({
    required this.mascotasPerdidas,
    required this.mascotasEncontradas,
    required this.usuariosAdministradores,
    required this.usuariosPropietarios,
    required this.usuariosRefugios,
  });

  factory Reporte.fromJson(Map<String, dynamic> json) {
    return Reporte(
      mascotasPerdidas: json['mascotas_perdidas'] as int,
      mascotasEncontradas: json['mascotas_encontradas'] as int,
      usuariosAdministradores: json['usuarios_administradores'] as int,
      usuariosPropietarios: json['usuarios_propietarios'] as int,
      usuariosRefugios: json['usuarios_refugios'] as int,
    );
  }
}
