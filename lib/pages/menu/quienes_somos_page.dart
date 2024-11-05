import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/usuario.dart';
import 'package:homecoming/pages/login/iniciar_sesion_page.dart';
import 'package:homecoming/pages/crear_publicacion_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuienesSomosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Usuario? usuario;
    final size = MediaQuery.of(context).size;
    final bool isSmallScreen = size.width < 600;

    Future<bool> usuarioEstaLogeado() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isLoggedIn') ?? false;
    }

    Widget buildHeader() {
      return Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green[200]!,
              Colors.green[50]!,
            ],
          ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: 40.0,
          horizontal: isSmallScreen ? 20.0 : 40.0,
        ),
        child: Column(
          children: [
            Text(
              'Bienvenido a Homecoming',
              style: TextStyle(
                fontSize: isSmallScreen ? 28.0 : 36.0,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 20.0),
            Text(
              'Ayudamos a familias a reencontrarse con sus mascotas perdidas',
              style: TextStyle(
                fontSize: isSmallScreen ? 20.0 : 24.0,
                color: Colors.green[700],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    Widget buildMission() {
      return Container(
        padding: EdgeInsets.all(isSmallScreen ? 20.0 : 40.0),
        child: Column(
          children: [
            Row(
              children: [
                if (!isSmallScreen)
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image.network(
                        'http://$serverIP/homecoming/assets/imagenes/quienes_somos.png',
                        fit: BoxFit.cover,
                        height: 300.0,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 300.0,
                            color: Colors.green[100],
                            child: Icon(Icons.pets, size: 100, color: Colors.green),
                          );
                        },
                      ),
                    ),
                  ),
                if (!isSmallScreen) SizedBox(width: 40.0),
                Expanded(
                  flex: isSmallScreen ? 2 : 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nuestra Misión',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 24.0 : 28.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Text(
                        'Nos dedicamos a reunir familias con sus mascotas perdidas a través de una plataforma moderna y efectiva. Entendemos el dolor y la preocupación que significa perder a un miembro peludo de la familia, y estamos aquí para ayudarte en cada paso del camino.',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16.0 : 18.0,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isSmallScreen) ...[
              SizedBox(height: 20.0),
              ClipRRect(
                borderRadius: BorderRadius.circular(20.0),
                child: Image.network(
                  'http://$serverIP/homecoming/assets/imagenes/quienes_somos.png',
                  fit: BoxFit.cover,
                  height: 200.0,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200.0,
                      color: Colors.green[100],
                      child: Icon(Icons.pets, size: 80, color: Colors.green),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      );
    }

    Widget buildServices() {
      final services = [
        {
          'icon': Icons.search,
          'title': 'Búsqueda Activa',
          'description': 'Sistema de búsqueda inteligente que conecta personas y recursos en tu área.',
        },
        {
          'icon': Icons.notifications_active,
          'title': 'Alertas Inmediatas',
          'description': 'Notificaciones en tiempo real cuando hay avistamientos o información relevante.',
        },
        {
          'icon': Icons.support_agent,
          'title': 'Soporte 24/7',
          'description': 'Equipo dedicado disponible para ayudarte en cualquier momento.',
        },
        {
          'icon': Icons.people,
          'title': 'Comunidad Solidaria',
          'description': 'Red de voluntarios y personas comprometidas con encontrar mascotas perdidas.',
        },
      ];

      return Container(
        color: Colors.green[50],
        padding: EdgeInsets.all(isSmallScreen ? 20.0 : 40.0),
        child: Column(
          children: [
            Text(
              'Nuestros Servicios',
              style: TextStyle(
                fontSize: isSmallScreen ? 24.0 : 28.0,
                fontWeight: FontWeight.bold,
                color: Colors.green[800],
              ),
            ),
            SizedBox(height: 40.0),
            Wrap(
              spacing: 20.0,
              runSpacing: 20.0,
              children: services.map((service) {
                return Container(
                  width: isSmallScreen ? double.infinity : 250.0,
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        service['icon'] as IconData,
                        size: 40.0,
                        color: Colors.green,
                      ),
                      SizedBox(height: 15.0),
                      Text(
                        service['title'] as String,
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      SizedBox(height: 10.0),
                      Text(
                        service['description'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(height: 1.5),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    }

    Widget buildCallToAction() {
      return Container(
        padding: EdgeInsets.all(isSmallScreen ? 20.0 : 40.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green[400]!,
              Colors.green[600]!,
            ],
          ),
        ),
        child: Column(
          children: [
            Text(
              '¿Se perdió tu mascota?',
              style: TextStyle(
                fontSize: isSmallScreen ? 24.0 : 32.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.0),
            Text(
              'No pierdas tiempo. Activa la búsqueda ahora y permite que nuestra comunidad te ayude a encontrarla.',
              style: TextStyle(
                fontSize: isSmallScreen ? 16.0 : 18.0,
                color: Colors.white,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30.0),
            FutureBuilder<bool>(
              future: usuarioEstaLogeado(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(color: Colors.white);
                }

                final bool usuarioLogeado = snapshot.data ?? false;

                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 30.0 : 40.0,
                      vertical: 20.0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: () async {
                    if (usuarioLogeado) {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => CrearPublicacionPage(),
                        ),
                      );

                      if (result == true) {
                        // Acción después de la publicación
                      }
                    } else {
                      await Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => IniciarSesionPage(),
                      ));
                    }
                  },
                  child: Text(
                    'Activar Búsqueda',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 16.0 : 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('¿Quiénes somos?'),
        backgroundColor: Colors.green[200],
      ),
      drawer: MenuWidget(usuario: usuario ?? Usuario.vacio()),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildHeader(),
            buildMission(),
            buildServices(),
            buildCallToAction(),
          ],
        ),
      ),
    );
  }
}