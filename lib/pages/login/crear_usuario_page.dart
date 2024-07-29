import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/login/verificar_refugio_page.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/propietario_page.dart';
import 'dart:convert';
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
  bool _passwordVisible1 = false;
  bool _passwordVisible2 = false;
  String? tipoUsuario;
  String mensaje = "";

  Future<void> crearUsuario() async {
    if (nombreController.text.isEmpty ||
        primerApellidoController.text.isEmpty ||
        telefonoController.text.isEmpty ||
        emailController.text.isEmpty ||
        contrasenaController.text.isEmpty ||
        verificarContrasenaController.text.isEmpty ||
        tipoUsuario == null) {
      setState(() {
        mensaje = "Todos los campos son obligatorios";
      });
      return;
    }

    if (contrasenaController.text.length < 6 || verificarContrasenaController.text.length < 6) {
      setState(() {
        mensaje = "Las contraseñas deben tener al menos 6 caracteres";
      });
      return;
    }

    if (contrasenaController.text != verificarContrasenaController.text) {
      setState(() {
        mensaje = "Verifique que ambas contraseñas sean iguales";
      });
      return;
    }

    final passwordHash = sha1.convert(utf8.encode(contrasenaController.text)).toString();

    final response = await http.post(
      Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/crear_usuario.php'),
      body: {
        "nombre": nombreController.text,
        "primerApellido": primerApellidoController.text,
        "segundoApellido": segundoApellidoController.text,
        "telefono": telefonoController.text,
        "email": emailController.text,
        "contrasena": passwordHash,
        "tipo_usuario": tipoUsuario,
      },
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
        if (tipoUsuario == 'propietario') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => Propietario()),
          );
        } else if (tipoUsuario == 'refugio') {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => VerificarRefugioPage(usuarioId: datauser['id'])),
          );
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
        title: Text('Crear Usuario'),
      ),
      drawer: MenuWidget(),
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
                obscureText: !_passwordVisible1,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible1 ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible1 = !_passwordVisible1;
                      });
                    },
                  ),
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: verificarContrasenaController,
                obscureText: !_passwordVisible2,
                decoration: InputDecoration(
                  labelText: 'Verificar Contraseña',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible2 ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible2 = !_passwordVisible2;
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
