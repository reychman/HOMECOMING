import 'package:homecoming/ip.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:homecoming/pages/usuario.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/usuario_provider.dart';
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

  Usuario? usuario;

  @override
  void initState() {
    super.initState();
    _checkLoginStatus(); // Revisar si hay una sesión activa cuando la app inicia
  }

  // Método para revisar si el usuario ya está logueado
  Future<void> _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    int? usuarioId = prefs.getInt('usuario_id');

    if (isLoggedIn && usuarioId != null) {
      Usuario? usuarioLogeado = await UsuarioProvider.getUsuarioActual(usuarioId);
      if (usuarioLogeado != null) {
        // Si el usuario está logueado y se ha recuperado su info correctamente
        Provider.of<UsuarioProvider>(context, listen: false).setUsuario(usuarioLogeado);
        Navigator.of(context).pushReplacementNamed('/inicio');
      }
    }
  }

  // Modifica el método login() en iniciar_sesion_page.dart
  Future<void> login() async {
    try {
      Usuario? usuarioLogeado = await Usuario.iniciarSesion(
          controllerUser.text, controllerPass.text);

      if (usuarioLogeado != null) {
        // El usuario existe, ahora verificamos su estado
        if (usuarioLogeado.estado == 0) {
          setState(() {
            mensaje = 'Tu cuenta está inactiva. Por favor, activa tu cuenta para continuar.';
          });
          return;
        }

        // Si llegamos aquí, la cuenta está activa
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('usuario_id', usuarioLogeado.id!);
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('foto_perfil', usuarioLogeado.fotoPortada ?? '');

        // Configurar el usuario en el estado global
        Provider.of<UsuarioProvider>(context, listen: false)
            .setUsuario(usuarioLogeado);

        // Navegar a la página de inicio
        Navigator.of(context).pushReplacementNamed('/inicio');
      } else {
        setState(() {
          mensaje = 'Nombre de usuario o contraseña incorrectos.';
        });
      }
    } catch (e) {
      setState(() {
        mensaje = 'Error al intentar iniciar sesión. Por favor, intenta de nuevo.';
      });
      print('Error durante el login: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de Sesión'),
        backgroundColor: Colors.green[200],
      ),
      drawer: MenuWidget(usuario: usuario ?? Usuario.vacio()),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('http://$serverIP/homecoming/assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenWidth > 500 ? 500 : screenWidth * 0.9,
              minWidth: 150,
            ),
            child: SingleChildScrollView(
              child: Card(
                color: Colors.white.withOpacity(0.8),
                elevation: 10.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircleAvatar(
                        backgroundColor: Colors.lightGreen,
                        radius: 50.0,
                        child: Icon(Icons.person, size: 50.0, color: Colors.white),
                      ),
                      const SizedBox(height: 20.0),
                      const Text(
                        'Inicio de Sesión',
                        style: TextStyle(fontSize: 26.0, color: Colors.lightGreen),
                      ),
                      const SizedBox(height: 20.0),
                      TextField(
                        key: const Key('usernameField'),
                        controller: controllerUser,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person, color: Colors.lightGreen),
                          hintText: 'Nombre de usuario',
                          filled: true,
                          fillColor: Colors.green.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      TextField(
                        key: const Key('passwordField'),
                        controller: controllerPass,
                        obscureText: !_contrasenaVisible,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.lock, color: Colors.lightGreen),
                          hintText: 'Contraseña',
                          filled: true,
                          fillColor: Colors.green.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _contrasenaVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.lightGreen,
                            ),
                            onPressed: () {
                              setState(() {
                                _contrasenaVisible = !_contrasenaVisible;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      SizedBox(
                        width: double.infinity, // Hace que el botón ocupe el ancho máximo disponible
                        child: ElevatedButton(
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
                            backgroundColor: Colors.green[200],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 15.0),
                          ),
                          child: const Text('Ingresar'),
                        ),
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
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/CrearUsuario');
                        },
                        child: const Text(
                          'Crear una cuenta',
                          style: TextStyle(color: Colors.green),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
