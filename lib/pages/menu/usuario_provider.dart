import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/menu/usuario.dart';
import 'package:http/http.dart' as http;

class UsuarioProvider with ChangeNotifier {
  Usuario? _usuario;

  Usuario? get usuario => _usuario;

  void setUsuario(Usuario? usuario) {
    _usuario = usuario;
    notifyListeners();
  }   
static Future<Usuario?> getUsuarioActual(int userId) async {
  try {
    final response = await http.post(
      Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/get_usuario_actual.php'),
      body: {'user_id': userId.toString()}, // Enviar el user_id en el cuerpo de la solicitud
    );
    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);

      if (jsonResponse != null) {
        return Usuario(
          id: jsonResponse['id'],
          nombre: jsonResponse['nombre'],
          primerApellido: jsonResponse['primerApellido'],
          segundoApellido: jsonResponse['segundoApellido'],
          telefono: jsonResponse['telefono'],
          email: jsonResponse['email'],
          contrasena: '', 
          tipoUsuario: jsonResponse['tipo_usuario'],
          fotoPortada: jsonResponse['foto_portada'],
          estado: jsonResponse['estado'],
        );
      }
    } else {
      print('Error en la solicitud: ${response.statusCode}');
    }
  } catch (e) {
    print('Error en getUsuarioActual: $e');
  }

  return null; // Retorna null si ocurre algún error o si no se encuentra el usuario
}


  static Future<void> actualizarFotoPortada(int id, String fotoPortada) async {
    await http.post(
      Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/update_foto_portada.php'),
      body: jsonEncode({
        'id': id,
        'foto_portada': fotoPortada,
      }),
      headers: {'Content-Type': 'application/json'},
    );
    // En este caso, no usamos la respuesta y la variable 'response' se elimina
  }
}