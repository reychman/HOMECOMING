import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/usuario.dart';

class PreguntasFrecuentesPage extends StatefulWidget {
  @override
  _PreguntasFrecuentesPageState createState() =>
      _PreguntasFrecuentesPageState();
}

class _PreguntasFrecuentesPageState extends State<PreguntasFrecuentesPage> {
  Usuario? usuario;

  // Datos iniciales (por defecto)
  String tituloGeneral = 'Consejos de qué hacer si encuentras un perro perdido';
  String tituloActual = 'Encontré un perro perdido ... ¿qué debo hacer?';
  String contenidoActual =
      'Si alguna vez has visto un perrito en la calle en busca de seguridad...';
  String imagenActual =
      'http://$serverIP/homecoming/assets/imagenes/perro_perdido.jpg';
  bool mostrarPlantillas = false; // Bandera para mostrar los enlaces de descarga

  // Función para actualizar el contenido cuando se selecciona una opción
  void actualizarContenido(String nuevoTituloGeneral, String nuevoTitulo, String nuevoContenido, String nuevaImagen, {bool plantillas = false}) {
    setState(() {
      tituloGeneral = nuevoTituloGeneral;
      tituloActual = nuevoTitulo;
      contenidoActual = nuevoContenido;
      imagenActual = nuevaImagen;
      mostrarPlantillas = plantillas; // Actualiza si se deben mostrar las plantillas
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preguntas Frecuentes'),
        backgroundColor: Colors.green[200],
      ),
      drawer: MenuWidget(usuario: usuario ?? Usuario.vacio()),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título general dinámico
                  Text(
                    tituloGeneral,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  // Imagen dinámica
                  Image.network(
                    imagenActual,
                    errorBuilder: (context, error, stackTrace) {
                      return Text('Error al cargar la imagen');
                    },
                  ),
                  SizedBox(height: 10),
                  // Título dinámico
                  Text(
                    tituloActual,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  // Contenido dinámico
                  Text(
                    contenidoActual,
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  // Mostrar enlaces de descarga solo si es necesario
                  if (mostrarPlantillas) ...[
                    SizedBox(height: 20),
                    Text(
                      'Descarga Plantillas:',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    TextButton(
                      onPressed: () {
                        // Acción de descarga plantilla 1
                      },
                      child: Text(
                        'Presiona aquí para descargar Plantilla 1',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Acción de descarga plantilla 2
                      },
                      child: Text(
                        'Presiona aquí para descargar Plantilla 2',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // Acción de descarga plantilla 3
                      },
                      child: Text(
                        'Presiona aquí para descargar Plantilla 3',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Publicaciones Populares',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  Divider(),
                  // Opciones del menú (ListTile) con la función de actualización de contenido
                  ListTile(
                    title: Text('Consejos de qué hacer si encuentras un perro perdido'),
                    onTap: () {
                      actualizarContenido(
                        'Consejos de qué hacer si encuentras un perro perdido',
                        'Consejos de qué hacer si encuentras un perro perdido',
                        'Aquí te explicamos qué hacer...',
                        'http://$serverIP/homecoming/assets/imagenes/perro_perdido.jpg',
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Oración a San Roque para encontrar un perro'),
                    onTap: () {
                      actualizarContenido(
                        'Oración a San Roque para encontrar un perro',
                        'Oración a San Roque para encontrar un perro',
                        'La oración a San Roque es...',
                        'http://$serverIP/homecoming/assets/imagenes/oracion_san_roque.jpg',
                      );
                    },
                  ),
                  ListTile(
                    title: Text('Campaña “Un tarro de agua para los perritos de la calle” ¿Te apuntas?'),
                    onTap: () {
                      actualizarContenido(
                        'Campaña “Un tarro de agua para los perritos de la calle”',
                        'Campaña “Un tarro de agua para los perritos de la calle”',
                        'La campaña consiste en...',
                        'http://$serverIP/homecoming/assets/imagenes/campana_agua.jpg',
                      );
                    },
                  ),
                  ListTile(
                    title: Text('¿Qué distancia recorre un perro perdido?'),
                    onTap: () {
                      actualizarContenido(
                        '¿Qué distancia recorre un perro perdido?',
                        '¿Qué distancia recorre un perro perdido?',
                        'Los perros perdidos pueden recorrer...',
                        'http://$serverIP/homecoming/assets/imagenes/distancia_perro.jpg',
                      );
                    },
                  ),
                  ListTile(
                    title: Text('¿Cómo encontrar un perro robado?'),
                    onTap: () {
                      actualizarContenido(
                        '¿Cómo encontrar un perro robado?',
                        '¿Cómo encontrar un perro robado?',
                        'Si tu perro ha sido robado...',
                        'http://$serverIP/homecoming/assets/imagenes/perro_robado.jpg',
                      );
                    },
                  ),
                  ListTile(
                    title: Text('¿Cómo hacer un cartel de se busca perro?'),
                    onTap: () {
                      actualizarContenido(
                        '¿Cómo hacer un cartel de se busca perro?',
                        '¿Cómo hacer un cartel de se busca perro?',
                        'Es muy buena idea hacer un cartel de perro perdido o se busca perro si tu mascota desaparece. Hemos creado 3 formatos para cartel de perro perdido en Microsoft Word para que los descargues gratuitamente y los utilices para recuperar a tu mascota.\n\n'
                        'Un buen cartel de perro perdido debe presentar información específica de ti y de tu perro...',
                        'http://$serverIP/homecoming/assets/imagenes/cartel_busqueda.jpg',
                        plantillas: true, // Mostrar los enlaces de plantillas
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
