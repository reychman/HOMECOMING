import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class IniciarSesionPage extends StatefulWidget {
  const IniciarSesionPage({Key? key}) : super(key: key);

  @override
  State<IniciarSesionPage> createState() => _IniciarSesionPageState();
}

class _IniciarSesionPageState extends State<IniciarSesionPage> {
  TextEditingController controllerUser = TextEditingController();
  TextEditingController controllerPass = TextEditingController();
  bool _passwordVisible = false; 
  String mensaje = "";

  Future<void> login() async {
  final passwordHash = sha1.convert(utf8.encode(controllerPass.text)).toString();
  print('Nombre: ${controllerUser.text}');
  print('Contraseña: $passwordHash');
  print('Datos enviados: ${jsonEncode({"nombre": controllerUser.text, "contrasena": passwordHash})}');

  final response = await http.post(
    Uri.parse("http://$serverIP/homecomingbd_v2/login.php"),
    headers: {
      "Content-Type": "application/json"
    },
    body: jsonEncode({
      "nombre": controllerUser.text,
      "contrasena": passwordHash,
    }),
  );

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');
  
  try {
    var datauser = json.decode(response.body);

    if (datauser.containsKey('error')) {
      setState(() {
        mensaje = datauser['error'];
      });
    } else {
      final tipoUsuario = datauser['tipo_usuario'];
      final nombreUsuario = datauser['nombre'];
      final email = datauser['email'];
      final userId = datauser['id'];
      final primerApellido = datauser['primerApellido'];
      final segundoApellido = datauser['segundoApellido'];
      final telefono = datauser['telefono'];  // Asegúrate de que el ID esté en la respuesta

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('nombre', nombreUsuario);
      await prefs.setString('primerApellido', primerApellido);
      await prefs.setString('segundoApellido', segundoApellido);
      await prefs.setString('telefono', telefono);
      await prefs.setString('tipo_usuario', tipoUsuario);
      await prefs.setString('email', email);
      await prefs.setInt('id', userId); // Guardar el ID del usuario

      switch (tipoUsuario) {
        case 'administrador':
          Navigator.of(context).pushReplacementNamed('/administrador');
          break;
        case 'propietario':
          Navigator.of(context).pushReplacementNamed('/propietario');
          break;
        case 'refugio':
          Navigator.of(context).pushReplacementNamed('/refugio');
          break;
        default:
          break;
      }
    }
  } catch (e) {
    print('Error decoding JSON: $e');
    setState(() {
      mensaje = 'Error en el servidor. Intente nuevamente más tarde.';
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio de Sesión'),
      ),
      drawer: MenuWidget(),
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                radius: 50.0,
                child: Icon(Icons.person, size: 50.0),
              ),
              SizedBox(height: 20.0),
              Text(
                'Inicio de Sesión',
                style: TextStyle(fontSize: 24.0, color: Colors.white),
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: TextField(
                  key: Key('usernameField'),
                  controller: controllerUser,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.person),
                    hintText: 'Nombre de usuario',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: TextField(
                  key: Key('passwordField'),
                  controller: controllerPass,
                  obscureText: !_passwordVisible,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.lock),
                    hintText: 'Contraseña',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _passwordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _passwordVisible = !_passwordVisible;
                        });
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () async {
                  if (controllerUser.text.isEmpty || controllerPass.text.isEmpty) {
                    setState(() {
                      mensaje = "Todos los campos son obligatorios";
                    });
                  } else {
                    await login();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 100.0, vertical: 15.0),
                ),
                child: Text(
                  'Iniciar Sesión',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 10.0),
              Text(
                mensaje,
                style: TextStyle(fontSize: 20.0, color: Colors.red),
              ),
              SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/RecuperarContra');
                },
                child: Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/CrearUsuario');
                },
                child: Text(
                  '¿No tienes una cuenta? Crea una',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
