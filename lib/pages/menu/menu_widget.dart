import 'package:homecoming/ip.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:homecoming/pages/usuario.dart';
import 'package:homecoming/pages/usuario_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MenuWidget extends StatelessWidget {
  final Usuario? usuario;

  const MenuWidget({
    required this.usuario, 
    Key? key
  }) : super(key: key);
  
  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');
    await prefs.setBool('isLoggedIn', false);
    Provider.of<UsuarioProvider>(context, listen: false).setUsuario(Usuario.vacio());
    Navigator.of(context).pushReplacementNamed('/inicio');
  }

  @override
  Widget build(BuildContext context) {
    final usuario = Provider.of<UsuarioProvider>(context).usuario ?? Usuario.vacio();
    final bool usuarioLogeado = usuario.nombre.isNotEmpty && usuario.tipoUsuario?.isNotEmpty == true;
    final bool esAdministrador = usuario.tipoUsuario == 'administrador';

    // Definimos una paleta de colores personalizada
    final colorScheme = {
      'primary': Colors.green[800],
      'secondary': Colors.green[600],
      'background': Colors.green[50],
      'menuItem': Colors.green[700],
      'cardBackground': Colors.white,
      'headerGradientStart': Colors.green[500],
      'headerGradientEnd': Colors.green[700],
    };

    Widget buildMenuItem({
      required IconData icon,
      required String title,
      required VoidCallback onTap,
      Color? iconColor,
      Widget? trailing,
    }) {
      return Container(
        margin: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colorScheme['cardBackground'],
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: Icon(
            icon,
            color: iconColor ?? colorScheme['menuItem'],
            size: 24,
          ),
          title: Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          trailing: trailing,
          onTap: onTap,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    return Drawer(
      backgroundColor: colorScheme['background'],
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme['headerGradientStart']!,
                  colorScheme['headerGradientEnd']!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: usuario.fotoPortada != null && usuario.fotoPortada!.isNotEmpty
                              ? Image.network(
                                  'http://$serverIP/homecoming/assets/imagenes/fotos_perfil/${usuario.fotoPortada}?${DateTime.now().millisecondsSinceEpoch}',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => Icon(
                                    Icons.person,
                                    size: 60,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    usuarioLogeado ? usuario.nombre : 'Invitado',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          offset: Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Text(
                    usuarioLogeado ? usuario.tipoUsuario ?? 'Sin rol' : 'Sin rol',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(vertical: 12),
              children: [
                if (usuarioLogeado)
                  buildMenuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Perfil',
                    onTap: () => Navigator.of(context).pushReplacementNamed('/perfilUsuario'),
                  ),
                buildMenuItem(
                  icon: Icons.home_rounded,
                  title: 'Inicio',
                  onTap: () => Navigator.of(context).pushReplacementNamed('/inicio'),
                ),
                buildMenuItem(
                  icon: Icons.info_outline_rounded,
                  title: '¿Quiénes somos?',
                  onTap: () => Navigator.of(context).pushReplacementNamed('/quienes_somos'),
                ),
                buildMenuItem(
                  icon: Icons.question_answer_rounded,
                  title: 'Preguntas Frecuentes',
                  onTap: () => Navigator.of(context).pushReplacementNamed('/preguntas_frecuentes'),
                ),
                buildMenuItem(
                  icon: Icons.map_rounded,
                  title: 'Mapa de búsquedas',
                  onTap: () => Navigator.of(context).pushReplacementNamed('/mapa_busquedas'),
                ),
                buildMenuItem(
                  icon: Icons.family_restroom_rounded,
                  title: 'Familias reunidas',
                  onTap: () => Navigator.of(context).pushReplacementNamed('/familias_reunidas'),
                ),
                if (usuarioLogeado && esAdministrador)
                  buildMenuItem(
                    icon: Icons.assessment_rounded,
                    title: 'Reportes',
                    onTap: () => Navigator.of(context).pushReplacementNamed('/reportes'),
                  ),
                if (!usuarioLogeado)
                  buildMenuItem(
                    icon: Icons.login_rounded,
                    title: 'Iniciar Sesión',
                    onTap: () => Navigator.of(context).pushReplacementNamed('/iniciar_sesion'),
                  ),
                if (usuarioLogeado && esAdministrador)
                  buildMenuItem(
                    icon: Icons.admin_panel_settings_rounded,
                    title: 'Administrar Usuarios',
                    onTap: () => Navigator.of(context).pushReplacementNamed('/admin_usuarios'),
                    iconColor: colorScheme['primary'],
                  ),
              ],
            ),
          ),
          if (usuarioLogeado)
            Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [
                    Colors.red[400]!,
                    Colors.red[600]!,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.2),
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => _logout(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Cerrar Sesión',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}