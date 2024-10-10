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

    Future<bool> usuarioEstaLogeado() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool('isLoggedIn') ?? false;
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
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Ayudamos a familias a reencontrarse con sus mascotas perdidas',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 96, 179, 97),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Queremos que sepas que no estás solo en esta búsqueda, estamos aquí para apoyarte y ayudarte a encontrar a tu compañero fiel.',
                    style: TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.0),
                  Image.network(
                    'http://$serverIP/homecoming/assets/imagenes/quienes_somos.png',
                    fit: BoxFit.cover,
                    height: 200.0,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(Icons.error, size: 100, color: Colors.red);
                    },
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Vamos a traer a tu mascota de vuelta a casa',
                    style: TextStyle(
                      fontSize: 22.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 96, 179, 97),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    '¡No pierdas la esperanza, estamos aquí para ayudarte en este difícil momento! '
                    'Déjanos ser tu guía y trabajemos juntos para encontrar a tu fiel compañero.\n\n'
                    'Creemos, sabemos lo que hacemos, queremos y tenemos la vocación de servicio y '
                    'disponemos de los recursos necesarios para encontrar y asegurarnos que tu amigo está a salvo.\n\n'
                    'Al contratar nuestros servicios vas a obtener un trabajo planificado para potenciar la búsqueda y '
                    'acompañarte en cómo localizar tu mascota perdida.\n\n'
                    'Los pilares de nuestro servicio son la base de la confianza:',
                    style: TextStyle(fontSize: 16.0),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: Icon(Icons.pets, color: Color.fromARGB(255, 96, 179, 97)),
                        title: Text('Contamos con el conocimiento y la habilidad necesaria para facilitar tu búsqueda.'),
                      ),
                      ListTile(
                        leading: Icon(Icons.pets, color: Color.fromARGB(255, 96, 179, 97)),
                        title: Text('Tenemos la voluntad y la predisposición para brindarte un apoyo genuino.'),
                      ),
                      ListTile(
                        leading: Icon(Icons.pets, color: Color.fromARGB(255, 96, 179, 97)),
                        title: Text('Operamos con los recursos suficientes para alcanzar resultados efectivos.'),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.0),
                  Container(
                    width: double.infinity,
                    color: Color.fromARGB(255, 96, 179, 97),
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      '¿Se perdió tu mascota? Encontrala ahora\nActivá la búsqueda. Completá el formulario y comencemos.',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 20.0),
                  FutureBuilder<bool>(
                    future: usuarioEstaLogeado(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      final bool usuarioLogeado = snapshot.data ?? false;

                      return ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 33, 243, 121),
                          padding: EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
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
                          'Activá tu búsqueda',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
