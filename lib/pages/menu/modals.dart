import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/mascota.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void mostrarModalInfoMascota(BuildContext context, Mascota mascota) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isNarrowScreen = constraints.maxWidth < 600; // Pantallas angostas

            return Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white, // Color de fondo del diálogo
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: isNarrowScreen
                  ? Column( // Disposición vertical en pantallas angostas
                      children: [
                        // Carrusel de fotos (arriba)
                        Expanded(
                          flex: 1,
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: double.infinity,
                              viewportFraction: 1.0,
                              enlargeCenterPage: false,
                            ),
                            items: mascota.fotos.map((foto) {
                              return SizedBox(
                                width: double.infinity,
                                child: Image.network(foto, fit: BoxFit.contain),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Información de la mascota y dueño (abajo)
                        Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader('Información de la Mascota'),
                                _buildInfoText('Nombre: ${mascota.nombre.toUpperCase()}'),
                                _buildInfoText('Especie: ${mascota.especie.toUpperCase()}'),
                                _buildInfoText('Raza: ${mascota.raza.toUpperCase()}'),
                                _buildInfoText('Sexo: ${mascota.sexo.toUpperCase()}'),
                                if (mascota.estado != 'adopcion') ...[
                                  _buildInfoText('Fecha de pérdida: ${mascota.fechaPerdida}'),
                                  _buildInfoText('Lugar de pérdida: ${mascota.lugarPerdida.toUpperCase()}'),
                                ],
                                _buildInfoText('Estado: ${mascota.estado.toUpperCase()}'),
                                _buildInfoText('Descripción: ${mascota.descripcion.toUpperCase()}'),
                                SizedBox(height: 20),
                                _buildSectionHeader('Información del Dueño'),
                                _buildInfoText('Nombre Completo: ${mascota.nombreDueno.toUpperCase()} ${mascota.primerApellidoDueno.toUpperCase()} ${mascota.segundoApellidoDueno.toUpperCase()}'),
                                SizedBox(height: 10),
                                _buildInteractiveText(
                                  'Email',
                                  mascota.emailDueno,
                                  'mailto:${mascota.emailDueno}',
                                ),
                                _buildWhatsAppContact(context, mascota),
                                // Espaciado adicional antes del botón
                                SizedBox(height: 20),// Botón "Me interesa" para adopción
                                if (mascota.estado == 'adopcion' || mascota.estado == 'pendiente') ...[
                                  Center( // Centrar el botón
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Lógica para manejar la adopción
                                        Navigator.of(context).pop();
                                        _interesadoEnAdopcion(context, mascota);
                                      },
                                      child: Text('Me interesa'),
                                    ),
                                  ),
                                ] else if (mascota.estado == 'perdido') ...[
                                  Center( // Centrar el botón
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Lógica para manejar la pérdida
                                        enviarMensajeWhatsApp(context, mascota, 'perdido');
                                      },
                                      child: Text('Reportar Avistamiento'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Row( // Disposición horizontal en pantallas anchas
                      children: [
                        // Carrusel de fotos (lado izquierdo)
                        Expanded(
                          flex: 1,
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: double.infinity,
                              viewportFraction: 1.0,
                              enlargeCenterPage: false,
                            ),
                            items: mascota.fotos.map((foto) {
                              return SizedBox(
                                width: double.infinity,
                                child: Image.network(foto, fit: BoxFit.contain),
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(width: 20),
                        // Información de la mascota y dueño (lado derecho)
                        Expanded(
                          flex: 1,
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionHeader('Información de la Mascota'),
                                _buildInfoText('Nombre: ${mascota.nombre.toUpperCase()}'),
                                _buildInfoText('Especie: ${mascota.especie.toUpperCase()}'),
                                _buildInfoText('Raza: ${mascota.raza.toUpperCase()}'),
                                _buildInfoText('Sexo: ${mascota.sexo.toUpperCase()}'),
                                if (mascota.estado != 'adopcion') ...[
                                  _buildInfoText('Fecha de pérdida: ${mascota.fechaPerdida}'),
                                  _buildInfoText('Lugar de pérdida: ${mascota.lugarPerdida.toUpperCase()}'),
                                ],
                                _buildInfoText('Estado: ${mascota.estado.toUpperCase()}'),
                                _buildInfoText('Descripción: ${mascota.descripcion.toUpperCase()}'),
                                SizedBox(height: 20),
                                _buildSectionHeader('Información del Dueño'),
                                _buildInfoText('Nombre Completo: ${mascota.nombreDueno.toUpperCase()} ${mascota.primerApellidoDueno.toUpperCase()} ${mascota.segundoApellidoDueno.toUpperCase()}'),
                                SizedBox(height: 10),
                                _buildInteractiveText(
                                  'Email',
                                  mascota.emailDueno,
                                  'mailto:${mascota.emailDueno}',
                                ),
                                _buildWhatsAppContact(context, mascota),
                                // Botón "Me interesa" para adopción
                                if (mascota.estado == 'adopcion' || mascota.estado == 'pendiente') ...[
                                  Center( // Centrar el botón
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Lógica para manejar la adopción
                                        Navigator.of(context).pop();
                                        _interesadoEnAdopcion(context, mascota);
                                      },
                                      child: Text('Me interesa'),
                                    ),
                                  ),
                                ] else if (mascota.estado == 'perdido') ...[
                                  Center( // Centrar el botón
                                    child: ElevatedButton(
                                      onPressed: () {
                                        // Lógica para manejar la pérdida
                                        enviarMensajeWhatsApp(context, mascota, 'perdido');
                                      },
                                      child: Text('Reportar Avistamiento'),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
            );
          },
        ),
      );
    },
  );
}
  void _interesadoEnAdopcion(BuildContext context, Mascota mascota) async {
    // Obtén el ID del adoptante de forma asincrónica
    int? adoptanteId = await obtenerIdAdoptante(); // Asegúrate de usar 'await' aquí
    int mascotaId = mascota.id; // Suponiendo que `mascota` tiene una propiedad `id`

    // Verificar si se obtuvo el ID del adoptante
    if (adoptanteId == null) {
      mostrarDialogo(context); // Llama al diálogo en lugar de mostrar un SnackBar
      return;
    }

    // Crear el cuerpo de la solicitud
    var body = {
      'action': 'registrar_interes',
      'mascota_id': mascotaId.toString(), // Asegúrate de que los valores sean del tipo correcto
      'adoptante_id': adoptanteId.toString(), // Convertir a string si es necesario
    };

    // Realizar la solicitud POST
    final response = await http.post(
      Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/adopcion.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );
    // Debug: imprime el cuerpo de la respuesta
    //print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}'); // Añade esta línea
    // Manejar la respuesta
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        mostrarMensaje(context, data['message']);
      } else {
        mostrarMensaje(context, data['message']);
      }
    } else {
      mostrarMensaje(context, 'Error al registrar el interés. Código de estado: ${response.statusCode}');
      //print('Error: ${response.body}'); // Añade esta línea para ver el cuerpo del error
    }
  }

  Future<int?> obtenerIdAdoptante() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt('usuario_id');
  }

  // Función para mostrar mensajes en un snackbar o alerta
  void mostrarMensaje(BuildContext context, String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  void mostrarDialogo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sesión Requerida'),
          content: Text('Debe de iniciar sesión para continuar. ¿Qué desea hacer?'),
          actions: [
            TextButton(
              child: Text('Crear una cuenta'),
              onPressed: () {
                Navigator.of(context).pushNamed('/CrearUsuario');
              },
            ),
            TextButton(
              child: Text('Iniciar sesión'),
              onPressed: () {
                Navigator.of(context).pushNamed('/iniciar_sesion');
              },
            ),
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
            ),
          ],
        );
      },
    );
  }

// Función para construir encabezados de sección
Widget _buildSectionHeader(String title) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.blueGrey,
      ),
    ),
  );
}

// Función para construir texto de información con estilo
Widget _buildInfoText(String text) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 4.0),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 16,
        color: Colors.black, // Color del texto
      ),
    ),
  );
}

Widget _buildInteractiveText(String label, String value, String url) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        Expanded(
          child: InkWell(
            onTap: () async {
              final uri = Uri.parse(url);
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                throw 'No se pudo iniciar $url';
              }
            },
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

void enviarMensajeWhatsApp(BuildContext context, Mascota mascota, String estado) async {
  // Verificar el estado de la mascota para personalizar el mensaje
  String cargarMensaje;
  if (estado == 'perdido') {
    cargarMensaje = 'Hola, hablo con ${mascota.nombreDueno}?, me comunico por su mascota perdida: ${mascota.nombre}';
  } else if (estado == 'adopcion' || estado == 'pendiente') {
    cargarMensaje = 'Hola, hablo con ${mascota.nombreDueno}?, me comunico con usted porque estoy interesado en la adopción de la mascota: ${mascota.nombre}, con la siguiente descripción: ${mascota.descripcion}';
  } else {
    cargarMensaje = 'Hola, estoy contactando sobre la mascota: ${mascota.nombre}';
  }

  // Generar la URI de WhatsApp completamente codificada
  final whatsappUri = Uri.https(
    'wa.me',
    '/${mascota.telefonoDueno}',
    {'text': cargarMensaje},
  );

  // Intentar abrir el enlace de WhatsApp
  if (await canLaunchUrl(whatsappUri)) {
    await launchUrl(whatsappUri);
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No se pudo abrir WhatsApp')),
    );
  }
}

// Función para construir el widget de contacto de WhatsApp
Widget _buildWhatsAppContact(BuildContext context, Mascota mascota) {
  return GestureDetector(
    onTap: () => enviarMensajeWhatsApp(context, mascota, mascota.estado),
    child: Row(
      children: [
        Image.network(
          'http://$serverIP/homecoming/assets/imagenes/whatsapp.png',
          width: 30,
          height: 30,
        ),
        SizedBox(width: 10),
        Text(
          mascota.telefonoDueno,
          style: TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    ),
  );
}

