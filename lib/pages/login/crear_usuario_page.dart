import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/login/iniciar_sesion_page.dart';
import 'dart:convert';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/menu/usuario.dart';
import 'package:http/http.dart' as http;

class CrearUsuarioPage extends StatefulWidget {
  @override
  _CrearUsuarioPageState createState() => _CrearUsuarioPageState();
}

class _CrearUsuarioPageState extends State<CrearUsuarioPage> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController primerApellidoController = TextEditingController();
  final TextEditingController segundoApellidoController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController contrasenaController = TextEditingController();
  final TextEditingController verificarContrasenaController = TextEditingController();
  bool _contrasenaVisible1 = false;
  bool _contrasenaVisible2 = false;
  String? tipoUsuario;
  String mensaje = "";
  Usuario? usuario;
  
  Future<void> crearUsuario() async {
    // Validaciones de campos obligatorios
    if (nombreController.text.isEmpty || primerApellidoController.text.isEmpty || telefonoController.text.isEmpty || emailController.text.isEmpty || contrasenaController.text.isEmpty ||
        verificarContrasenaController.text.isEmpty || tipoUsuario == null) {
      setState(() {
        mensaje = "Todos los campos son obligatorios";
      });
      return;
    }

    // Validaciones de longitud de contraseña
    if (contrasenaController.text.length < 6 || verificarContrasenaController.text.length < 6) {
      setState(() {
        mensaje = "Las contraseñas deben tener al menos 6 caracteres";
      });
      return;
    }

    // Validaciones de coincidencia de contraseñas
    if (contrasenaController.text != verificarContrasenaController.text) {
      setState(() {
        mensaje = "Verifique que ambas contraseñas sean iguales";
      });
      return;
    }

    // Encriptar contraseña con SHA-1
    final passwordHash = sha1.convert(utf8.encode(contrasenaController.text)).toString();

    // Crear objeto Usuario
    Usuario nuevoUsuario = Usuario(
      nombre: nombreController.text.toUpperCase(),
      primerApellido: primerApellidoController.text.toUpperCase(),
      segundoApellido: segundoApellidoController.text.toUpperCase(),
      telefono: telefonoController.text,
      email: emailController.text,
      contrasena: passwordHash,
      tipoUsuario: tipoUsuario!,
    );

    // Llamar al método para crear usuario
    bool success = await Usuario.createUsuario(nuevoUsuario);

    if (success) {
      // Enviar correo de verificación
      bool correoEnviado = await enviarCorreoVerificacion(nuevoUsuario.email);

      if (correoEnviado) {
        mostrarDialogoExito();
      } else {
        setState(() {
          mensaje = "Error al enviar el correo de verificación.";
        });
      }
    } else {
      setState(() {
        mensaje = "Error al crear el usuario";
      });
    }
  }

  Future<bool> enviarCorreoVerificacion(String email) async {
    try {
      final response = await http.post(
        Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/envioEmails/vendor/enviar_verificacion.php'),
        body: {'email': email},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error al enviar correo de verificación: $e');
      return false;
    }
  }

  void mostrarDialogoExito() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Verificación de Correo Electrónico'),
          content: Text('Se ha enviado un correo de verificación. Por favor, verifica tu bandeja de entrada para activar tu cuenta.'),
          actions: <Widget>[
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => IniciarSesionPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Usuario'),
      ),
      drawer: MenuWidget(usuario: usuario ?? Usuario.vacio()), 
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: primerApellidoController,
                decoration: InputDecoration(
                  labelText: 'Primer Apellido',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: segundoApellidoController,
                decoration: InputDecoration(
                  labelText: 'Segundo Apellido',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: telefonoController,
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: contrasenaController,
                obscureText: !_contrasenaVisible1,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _contrasenaVisible1 ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _contrasenaVisible1 = !_contrasenaVisible1;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: verificarContrasenaController,
                obscureText: !_contrasenaVisible2,
                decoration: InputDecoration(
                  labelText: 'Verificar Contraseña',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _contrasenaVisible2 ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _contrasenaVisible2 = !_contrasenaVisible2;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              DropdownButtonFormField<String>(
                value: tipoUsuario,
                onChanged: (String? newValue) {
                  setState(() {
                    tipoUsuario = newValue;
                  });
                },
                items: <String>['propietario', 'refugio']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: InputDecoration(
                  labelText: 'Tipo de Usuario',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: crearUsuario,
                child: Text('Crear Usuario'),
              ),
              SizedBox(height: 10.0),
              Text(
                mensaje,
                style: TextStyle(fontSize: 20.0, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
