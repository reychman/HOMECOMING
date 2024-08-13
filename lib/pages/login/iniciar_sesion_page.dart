import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:homecoming/pages/menu/usuario.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/menu/usuario_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IniciarSesionPage extends StatefulWidget {
  const IniciarSesionPage({Key? key}) : super(key: key);

  @override
  State<IniciarSesionPage> createState() => _IniciarSesionPageState();
}

class _IniciarSesionPageState extends State<IniciarSesionPage> {
  TextEditingController controllerUser = TextEditingController();
  TextEditingController controllerPass = TextEditingController();
  bool _contrasenaVisible = false;
  String mensaje = "";
  
  // Definir la variable usuario como una variable de estado
  Usuario? usuario;

Future<void> login() async {
  Usuario? usuarioLogeado = await Usuario.iniciarSesion(controllerUser.text, controllerPass.text);

  if (usuarioLogeado != null && usuarioLogeado.id != null) {
    // Almacena el userId en SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userId', usuarioLogeado.id!); // Usa el operador `!` para deshacer el nullable

    // Actualizar el estado del usuario
    Provider.of<UsuarioProvider>(context, listen: false).setUsuario(usuarioLogeado);

    // Navegar a la página correspondiente
    Navigator.of(context).pushReplacementNamed('/inicio');
  } 
  else {
    setState(() {
      mensaje = 'Nombre de usuario o contraseña incorrectos.';
    });
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de Sesión'),
      ),
      drawer: MenuWidget(usuario: usuario ?? Usuario.vacio()), 
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircleAvatar(
                backgroundColor: Colors.white,
                radius: 50.0,
                child: Icon(Icons.person, size: 50.0),
              ),
              const SizedBox(height: 20.0),
              const Text(
                'Inicio de Sesión',
                style: TextStyle(fontSize: 24.0, color: Colors.white),
              ),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: TextField(
                  key: const Key('usernameField'),
                  controller: controllerUser,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.person),
                    hintText: 'Nombre de usuario',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: TextField(
                  key: const Key('passwordField'),
                  controller: controllerPass,
                  obscureText: !_contrasenaVisible,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.lock),
                    hintText: 'Contraseña',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _contrasenaVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _contrasenaVisible = !_contrasenaVisible;
                        });
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20.0),
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
                  padding: const EdgeInsets.symmetric(horizontal: 100.0, vertical: 15.0),
                ),
                child: const Text('Ingresar'),
              ),
              const SizedBox(height: 20.0),
              Text(
                mensaje,
                style: const TextStyle(color: Colors.red, fontSize: 16.0),
              ),
              const SizedBox(height: 20.0),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/RecuperarContra');
                },
                child: const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/CrearUsuario');
                },
                child: const Text(
                  'Crear una cuenta',
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
