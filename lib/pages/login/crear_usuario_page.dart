import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/login/iniciar_sesion_page.dart';
import 'dart:convert';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/usuario.dart';
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
  final TextEditingController nombreRefugioController = TextEditingController();
  final TextEditingController emailRefugioController = TextEditingController();
  final TextEditingController ubicacionRefugioController = TextEditingController();
  final TextEditingController telefonoRefugioController = TextEditingController();

  bool _contrasenaVisible1 = false;
  bool _contrasenaVisible2 = false;
  String? tipoUsuario;
  String mensaje = "";
  Usuario? usuario;
  int _currentStep = 0;

  // Método para avanzar de paso
  void _nextStep() {
    setState(() {
      if (_currentStep < 3) {
        _currentStep++;
      }
    });
  }

  // Método para retroceder de paso
  void _previousStep() {
    setState(() {
      if (_currentStep > 0) {
        _currentStep--;
      }
    });
  }

  // Método para validar y crear un usuario o refugio
  Future<void> crearUsuario() async {
    // Validaciones de campos obligatorios
    if (nombreController.text.isEmpty || primerApellidoController.text.isEmpty || telefonoController.text.isEmpty || emailController.text.isEmpty || contrasenaController.text.isEmpty ||
        verificarContrasenaController.text.isEmpty || tipoUsuario == null) {
      setState(() {
        mensaje = "Todos los campos son obligatorios";
      });
      return;
    }

    // Validaciones adicionales si se selecciona refugio
    if (tipoUsuario == 'refugio') {
      if (nombreRefugioController.text.isEmpty || emailRefugioController.text.isEmpty || ubicacionRefugioController.text.isEmpty || telefonoRefugioController.text.isEmpty) {
        setState(() {
          mensaje = "Todos los campos de refugio son obligatorios";
        });
        return;
      }
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

    if (tipoUsuario == 'propietario') {
      // Lógica para crear un usuario propietario (estado normal)
      Usuario nuevoUsuario = Usuario(
        nombre: nombreController.text.toUpperCase(),
        primerApellido: primerApellidoController.text.toUpperCase(),
        segundoApellido: segundoApellidoController.text.toUpperCase(),
        telefono: telefonoController.text,
        email: emailController.text,
        contrasena: passwordHash,
        tipoUsuario: tipoUsuario!,
      );

      bool success = await Usuario.createUsuario(nuevoUsuario);

      if (success) {
        mostrarDialogoExito();
      } else {
        setState(() {
          mensaje = "Error al crear el usuario";
        });
      }
    } else if (tipoUsuario == 'refugio') {
      // Lógica para crear un refugio con estado 0 (inactivo)
      Usuario nuevoRefugio = Usuario(
        nombre: nombreController.text.toUpperCase(),
        primerApellido: primerApellidoController.text.toUpperCase(),
        segundoApellido: segundoApellidoController.text.toUpperCase(),
        telefono: telefonoController.text,
        email: emailController.text,
        contrasena: passwordHash,
        tipoUsuario: tipoUsuario!,
        estado: 0, // Estado inactivo
        nombreRefugio: nombreRefugioController.text.toUpperCase(),
        emailRefugio: emailRefugioController.text,
        ubicacionRefugio: ubicacionRefugioController.text.toUpperCase(),
        telefonoRefugio: telefonoRefugioController.text,
      );

      bool success = await Usuario.createUsuario(nuevoRefugio);

      if (success) {
        mostrarDialogoRevision();
      } else {
        setState(() {
          mensaje = "Error al crear el refugio";
        });
      }
    }
  }

  // Mostrar el mensaje de cuenta en revisión para refugios
  void mostrarDialogoRevision() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Cuenta de Refugio en Revisión'),
          content: Text('Su cuenta de refugio entrará en revisión. Esto puede tardar de 24 a 48 horas. Se le notificará por correo electrónico si su cuenta es válida.'),
          actions: <Widget>[
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                Navigator.of(context).pushNamed('/inicio');
              },
            ),
          ],
        );
      },
    );
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

  // Sección de pasos
  List<Step> _buildSteps() {
    return [
      Step(
        title: Text('Paso 1: Información Personal'),
        content: Column(
          children: [
            TextField(
              controller: nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.orange.withOpacity(0.1),
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: primerApellidoController,
              decoration: InputDecoration(
                labelText: 'Primer Apellido',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.orange.withOpacity(0.1),
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: segundoApellidoController,
              decoration: InputDecoration(
                labelText: 'Segundo Apellido (Opcional)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.orange.withOpacity(0.1),
              ),
            ),
          ],
        ),
        isActive: _currentStep == 0,
      ),
      Step(
        title: Text('Paso 2: Contacto'),
        content: Column(
          children: [
            TextField(
              controller: telefonoController,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.orange.withOpacity(0.1),
              ),
            ),
            SizedBox(height: 10.0),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.orange.withOpacity(0.1),
              ),
            ),
          ],
        ),
        isActive: _currentStep == 1,
      ),
      Step(
        title: Text('Paso 3: Contraseña'),
        content: Column(
          children: [
            TextField(
              controller: contrasenaController,
              obscureText: !_contrasenaVisible1,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.orange.withOpacity(0.1),
                suffixIcon: IconButton(
                  icon: Icon(
                    _contrasenaVisible1 ? Icons.visibility : Icons.visibility_off,
                    color: Colors.orange,
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
                filled: true,
                fillColor: Colors.orange.withOpacity(0.1),
                suffixIcon: IconButton(
                  icon: Icon(
                    _contrasenaVisible2 ? Icons.visibility : Icons.visibility_off,
                    color: Colors.orange,
                  ),
                  onPressed: () {
                    setState(() {
                      _contrasenaVisible2 = !_contrasenaVisible2;
                    });
                  },
                ),
              ),
            ),
          ],
        ),
        isActive: _currentStep == 2,
      ),
      Step(
        title: Text('Paso 4: Tipo de Usuario'),
        content: Column(
          children: [
            SizedBox(height: 20.0),
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
                filled: true,
                fillColor: Colors.orange.withOpacity(0.1),
              ),
            ),
            if (tipoUsuario == 'refugio') ...[
              SizedBox(height: 10.0),
              TextField(
                controller: nombreRefugioController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Refugio',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.orange.withOpacity(0.1),
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: emailRefugioController,
                decoration: InputDecoration(
                  labelText: 'Email del Refugio',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.orange.withOpacity(0.1),
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: ubicacionRefugioController,
                decoration: InputDecoration(
                  labelText: 'Ubicación del Refugio',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.orange.withOpacity(0.1),
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: telefonoRefugioController,
                decoration: InputDecoration(
                  labelText: 'Teléfono del Refugio',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.orange.withOpacity(0.1),
                ),
              ),
            ],
            SizedBox(height: 20.0),
            if (tipoUsuario == 'propietario' || tipoUsuario == 'refugio') 
              ElevatedButton(
                onPressed: crearUsuario,
                child: Text('Crear Usuario'),
              ),
          ],
        ),
        isActive: _currentStep == 3,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Usuario'),
        backgroundColor: Colors.orange[200],
      ),
      drawer: MenuWidget(usuario: usuario ?? Usuario.vacio()), 
      body: Stepper(
        currentStep: _currentStep,
        onStepContinue: _nextStep,
        onStepCancel: _previousStep,
        steps: _buildSteps(),
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return Row(
            children: <Widget>[
              ElevatedButton(
                onPressed: details.onStepContinue,
                child: Text('Siguiente'),
              ),
              SizedBox(width: 10),
              if (_currentStep > 0)
                ElevatedButton(
                  onPressed: details.onStepCancel,
                  child: Text('Anterior'),
                ),
            ],
          );
        },
      ),
    );
  }
}
