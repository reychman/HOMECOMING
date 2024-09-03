import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:homecoming/pages/usuario.dart';
import 'package:homecoming/pages/usuario_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuWidget extends StatelessWidget {
  final Usuario usuario;

  const MenuWidget({required this.usuario, Key? key}) : super(key: key);
  
    Future<void> _logout(BuildContext context) async {
    // Elimina los datos del usuario de SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); // Elimina el userId almacenado
    await prefs.setBool('isLoggedIn', false); // Nueva bandera

    // Actualiza el estado del usuario en el UsuarioProvider
    Provider.of<UsuarioProvider>(context, listen: false).setUsuario(Usuario.vacio());

    // Redirige al usuario a la página principal
    Navigator.of(context).pushReplacementNamed('/inicio');
  }

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<UsuarioProvider>(context).usuario ?? Usuario.vacio();
    final bool usuarioLogeado = usuario.nombre.isNotEmpty && usuario.tipoUsuario.isNotEmpty;
    final bool esAdministrador = usuario.tipoUsuario == 'administrador';


    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                UserAccountsDrawerHeader(
                  accountName: Text(usuarioLogeado ? usuario.nombre : 'Invitado'),
                  accountEmail: Text(usuarioLogeado ? usuario.tipoUsuario : 'Sin rol'),
                  currentAccountPicture: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 40.0,
                    ),
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
                    Navigator.of(context).pushReplacementNamed('/inicio');
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
                  leading: Icon(Icons.picture_as_pdf),
                  title: Text('Reportes'),
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed('/reportes');
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
                if (usuarioLogeado && esAdministrador)
                  ListTile(
                    leading: Icon(Icons.person_search),
                    title: Text('Administrar Usuarios'),
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/admin_usuarios');
                    },
                  ),
              ],
            ),
          ),
          if (usuario.id != null) // Verifica si el usuario está logueado
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  icon: Icon(Icons.power_settings_new_sharp, color: Colors.red),
                  onPressed: () => _logout(context), // Llama a la función de logout
                ),
              ),
            ),
        ],
      ),
    );
  }
}