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

  Future<void> login() async {
    Usuario? usuarioLogeado = await Usuario.iniciarSesion(controllerUser.text, controllerPass.text);

    if (usuarioLogeado != null && usuarioLogeado.id != null) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setInt('userId', usuarioLogeado.id!);
      await prefs.setBool('isLoggedIn', true);

      Provider.of<UsuarioProvider>(context, listen: false).setUsuario(usuarioLogeado);
      Navigator.of(context).pushReplacementNamed('/inicio');
    } else {
      setState(() {
        mensaje = 'Nombre de usuario o contraseña incorrectos.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio de Sesión'),
        backgroundColor: Colors.orange,
      ),
      drawer: MenuWidget(usuario: usuario ?? Usuario.vacio()),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('../../../assets/background.jpg'),
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
                        backgroundColor: Colors.orange,
                        radius: 50.0,
                        child: Icon(Icons.person, size: 50.0, color: Colors.white),
                      ),
                      const SizedBox(height: 20.0),
                      const Text(
                        'Inicio de Sesión',
                        style: TextStyle(fontSize: 26.0, color: Colors.orange),
                      ),
                      const SizedBox(height: 20.0),
                      TextField(
                        key: const Key('usernameField'),
                        controller: controllerUser,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.person, color: Colors.orange),
                          hintText: 'Nombre de usuario',
                          filled: true,
                          fillColor: Colors.orange.withOpacity(0.1),
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
                          prefixIcon: const Icon(Icons.lock, color: Colors.orange),
                          hintText: 'Contraseña',
                          filled: true,
                          fillColor: Colors.orange.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _contrasenaVisible ? Icons.visibility : Icons.visibility_off,
                              color: Colors.orange,
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
                            backgroundColor: Colors.orange,
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
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                      const SizedBox(height: 10.0),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed('/CrearUsuario');
                        },
                        child: const Text(
                          'Crear una cuenta',
                          style: TextStyle(color: Colors.orange),
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
