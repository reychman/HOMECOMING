import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:homecoming/ip.dart';
import 'package:http/http.dart' as http;

class Usuario {
  int? id;
  String nombre;
  String primerApellido;
  String segundoApellido;
  String telefono;
  String email;
  String contrasena;
  String tipoUsuario;
  String? fotoPortada;
  String? nombreRefugio;
  String? emailRefugio;
  String? ubicacionRefugio;
  String? telefonoRefugio;
  int? estado;
  DateTime? fechaCreacion;
  DateTime? fechaModificacion;

  // Constructor principal
  Usuario({
    this.id,
    required this.nombre,
    required this.primerApellido,
    required this.segundoApellido,
    required this.telefono,
    required this.email,
    required this.contrasena,
    required this.tipoUsuario,
    this.fotoPortada,
    this.nombreRefugio,
    this.emailRefugio,
    this.ubicacionRefugio,
    this.telefonoRefugio,
    this.estado,
    this.fechaCreacion,
    this.fechaModificacion,
  });

  // Constructor vacío
  Usuario.vacio()
      : id = null,
        nombre = '',
        primerApellido = '',
        segundoApellido = '',
        telefono = '',
        email = '',
        contrasena = '',
        tipoUsuario = 'visitante',
        fotoPortada = null,
        nombreRefugio = null,
        emailRefugio = null,
        ubicacionRefugio = null,
        telefonoRefugio = null,
        estado = null,
        fechaCreacion = null,
        fechaModificacion = null;

  // Crear usuario
static Future<bool> createUsuario(Usuario usuario) async {
  const url = 'http://$serverIP/homecoming/homecomingbd_v2/crear_usuario.php';

  try {
    final response = await http.post(
      Uri.parse(url),
      body: {
        'nombre': usuario.nombre,
        'primerApellido': usuario.primerApellido,
        'segundoApellido': usuario.segundoApellido,
        'telefono': usuario.telefono,
        'email': usuario.email,
        'contrasena': usuario.contrasena,
        'tipo_usuario': usuario.tipoUsuario,
        // Agregar campos de refugio si es del tipo refugio
        if (usuario.tipoUsuario == 'refugio') ...{
          'nombreRefugio': usuario.nombreRefugio,
          'emailRefugio': usuario.emailRefugio,
          'ubicacionRefugio': usuario.ubicacionRefugio,
          'telefonoRefugio': usuario.telefonoRefugio,
        },
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    } else {
      return false;
    }
  } catch (e) {
    print('Error: $e');
    return false;
  }
}

  // Método para iniciar sesión
  static Future<Usuario?> iniciarSesion(String nombre, String contrasena) async {
    final passwordHash = sha1.convert(utf8.encode(contrasena)).toString();
    const url = 'http://$serverIP/homecoming/homecomingbd_v2/login.php'; 

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'nombre': nombre,
        'contrasena': passwordHash,
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data.containsKey('error')) {
        return null;
      } else {
        return Usuario.fromJson(data);
      }
    } else {
      return null;
    }
  }
  // Mostrar usuarios
  static Future<List<Usuario>> fetchUsuariosPorEstado(String tipo, int estado) async {
    String url;

    // Construir la URL basada en el tipo y estado
    url = 'http://$serverIP/homecoming/homecomingbd_v2/lista_usuarios.php?tipo=$tipo';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((json) => Usuario.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load users');
    }
  }

  // Actualizar usuario
  Future<Map<String, dynamic>> updateUsuario() async {
    const url = 'http://$serverIP/homecoming/homecomingbd_v2/actualizar_usuario.php';

    final response = await http.post(
      Uri.parse(url),
      body: {
        'id': id.toString(),
        'nombre': nombre,
        'primerApellido': primerApellido,
        'segundoApellido': segundoApellido,
        'telefono': telefono,
        'email': email,
        'contrasena': contrasena,
        'tipo_usuario': tipoUsuario,
        'estado': estado.toString(),
        // Agregar campos de refugio
        'nombreRefugio': nombreRefugio ?? '',
        'emailRefugio': emailRefugio ?? '',
        'ubicacionRefugio': ubicacionRefugio ?? '',
        'telefonoRefugio': telefonoRefugio ?? '',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data; // Asegúrate de que esto devuelva el mapa completo
    } else {
      return {'error': 'Error en la conexión con el servidor'};
    }
  }

  Future<bool> actualizarPerfil() async {
    final response = await http.post(
      Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/actualizar_usuario.php'),
      body: {
        'id': id.toString(),
        'nombre': nombre.toUpperCase(),
        'primerApellido': primerApellido.toUpperCase(),
        'segundoApellido': segundoApellido.toUpperCase(),
        'telefono': telefono,
        'email': email,
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      print('Response data: $responseData');
      return responseData['success'] == 'Perfil actualizado exitosamente';
    } else {
      return false;
    }
  }

  // Eliminar (lógicamente) usuario
  Future<bool> deleteUsuario() async {
    const url = 'http://$serverIP/homecoming/homecomingbd_v2/eliminar_usuario.php';

    final response = await http.post(
      Uri.parse(url),
      body: {
        'id': id.toString(),
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == 'Usuario eliminado correctamente';
    } else {
      return false;
    }
  }

  // Convertir de JSON a objeto Usuario
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      nombre: json['nombre'] != null ? json['nombre'].toString() : '',
      primerApellido: json['primerApellido'] != null ? json['primerApellido'].toString() : '',
      segundoApellido: json['segundoApellido'] != null ? json['segundoApellido'].toString() : '',
      telefono: json['telefono'] != null ? json['telefono'].toString() : '',
      email: json['email'] != null ? json['email'].toString() : '',
      contrasena: json['contrasena'] != null ? json['contrasena'].toString() : '',
      tipoUsuario: json['tipo_usuario'] != null ? json['tipo_usuario'].toString() : '',
      fotoPortada: json['foto_portada'] != null ? json['foto_portada'].toString() : '',
      nombreRefugio: json['nombreRefugio'] != null ? json['nombreRefugio'].toString() : '',
      emailRefugio: json['emailRefugio'] != null ? json['emailRefugio'].toString() : '',
      ubicacionRefugio: json['ubicacionRefugio'] != null ? json['ubicacionRefugio'].toString() : '',
      telefonoRefugio: json['telefonoRefugio'] != null ? json['telefonoRefugio'].toString() : '',
      estado: json['estado'] != null ? int.tryParse(json['estado'].toString()) : null,
      fechaCreacion: json['fecha_creacion'] != null ? DateTime.parse(json['fecha_creacion']) : null,
      fechaModificacion: json['fecha_modificacion'] != null ? DateTime.parse(json['fecha_modificacion']) : null,
    );
  }

  // Convertir de objeto Usuario a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'primerApellido': primerApellido,
      'segundoApellido': segundoApellido,
      'telefono': telefono,
      'email': email,
      'contrasena': contrasena,
      'tipo_usuario': tipoUsuario,
      'foto_portada': fotoPortada,
      'nombreRefugio': nombreRefugio,
      'emailRefugio': emailRefugio,
      'ubicacionRefugio': ubicacionRefugio,
      'telefonoRefugio': telefonoRefugio,
      'estado': estado,
      'fecha_creacion': fechaCreacion?.toIso8601String(),
      'fecha_modificacion': fechaModificacion?.toIso8601String(),
    };
  }
}