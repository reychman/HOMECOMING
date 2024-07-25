import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuWidget extends StatelessWidget {
  Future<Map<String, String>> _getUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String nombre = prefs.getString('nombre') ?? '';
    String tipoUsuario = prefs.getString('tipo_usuario') ?? '';
    return {'nombre': nombre, 'tipo_usuario': tipoUsuario};
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: FutureBuilder<Map<String, String>>(
        future: _getUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error al cargar datos'));
          }
          final userData = snapshot.data!;
          final bool usuarioLogeado = userData['nombre']!.isNotEmpty && userData['tipo_usuario']!.isNotEmpty;

          return Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ListView(
                padding: EdgeInsets.zero,
                shrinkWrap: true, // This allows ListView to take only the necessary space
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                    ),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Menú Principal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                            ),
                          ),
                        ),
                        if (usuarioLogeado)
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  userData['nombre']!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                Text(
                                  userData['tipo_usuario']!,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (usuarioLogeado)
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Perfil'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/perfilUsuario');
                      },
                    ),
                  ListTile(
                    leading: Icon(Icons.home),
                    title: Text('Home'),
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/home');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.info),
                    title: Text('¿Quiénes somos?'),
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/quienes_somos');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.question_answer),
                    title: Text('Preguntas Frecuentes'),
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/preguntas_frecuentes');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.map),
                    title: Text('Mapa de búsquedas'),
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/mapa_busquedas');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.family_restroom),
                    title: Text('Familias reunidas'),
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/familias_reunidas');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.payment),
                    title: Text('Planes'),
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/planes');
                    },
                  ),
                  if (!usuarioLogeado)
                    ListTile(
                      leading: Icon(Icons.login),
                      title: Text('Iniciar Sesión'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/iniciar_sesion');
                      },
                    ),
                  if (usuarioLogeado)
                    ListTile(
                      leading: Icon(Icons.person_search),
                      title: Text('Administrar Usuarios'),
                      onTap: () {
                        Navigator.of(context).pushReplacementNamed('/admin_usuarios');
                      },
                    ),
                ],
              ),
              if (usuarioLogeado)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: IconButton(
                      icon: Icon(Icons.power_settings_new_sharp, color: Colors.red),
                      onPressed: () async {
                        SharedPreferences prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        Navigator.of(context).pushReplacementNamed('/home');
                      },
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
