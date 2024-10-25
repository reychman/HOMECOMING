import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/usuario.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UsuarioProvider with ChangeNotifier {
  Usuario? _usuario;
  static const String _userKey = 'current_user';

  Usuario? get usuario => _usuario;

  // Constructor que inicializa el estado desde SharedPreferences
  UsuarioProvider() {
    _initializeUser();
  }

  // Inicializar usuario desde SharedPreferences
  Future<void> _initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(_userKey);
    
    if (userData != null) {
      try {
        final Map<String, dynamic> userMap = json.decode(userData);
        final userId = userMap['id'];
        
        // Obtener datos actualizados del servidor
        final usuarioActual = await getUsuarioActual(userId);
        if (usuarioActual != null) {
          setUsuario(usuarioActual);
        }
      } catch (e) {
        print('Error al inicializar usuario: $e');
        await prefs.remove(_userKey); // Limpiar datos inválidos
      }
    }
  }

  // Actualizar usuario y persistir en SharedPreferences
  Future<void> setUsuario(Usuario? usuario) async {
    _usuario = usuario;
    final prefs = await SharedPreferences.getInstance();
    
    if (usuario != null) {
      // Guardar datos del usuario en SharedPreferences
      await prefs.setString(_userKey, json.encode({
        'id': usuario.id,
        'nombre': usuario.nombre,
        'primerApellido': usuario.primerApellido,
        'segundoApellido': usuario.segundoApellido,
        'telefono': usuario.telefono,
        'email': usuario.email,
        'tipo_usuario': usuario.tipoUsuario,
        'foto_portada': usuario.fotoPortada,
        'estado': usuario.estado,
      }));
    } else {
      // Si el usuario es null, eliminar datos guardados
      await prefs.remove(_userKey);
    }
    
    notifyListeners();
  }

  // Cerrar sesión
  Future<void> logout() async {
    await setUsuario(null);
  }

  // Obtener usuario del servidor
  static Future<Usuario?> getUsuarioActual(int userId) async {
    try {
      final response = await http.post(
        Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/get_usuario_actual.php'),
        body: {'user_id': userId.toString()},
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
      }
    } catch (e) {
      print('Error en getUsuarioActual: $e');
    }
    return null;
  }
}