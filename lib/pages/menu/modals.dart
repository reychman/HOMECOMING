import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/mascota.dart';
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
                              return Container(
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
Widget _buildWhatsAppContact(BuildContext context, Mascota mascota) {
  return GestureDetector(
    onTap: () async {
      final whatsappUri = Uri.parse(
        'https://wa.me/${mascota.telefonoDueno}?text=Hola, estoy contactando sobre tu mascota perdida: ${mascota.nombre}'
      );
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir WhatsApp')),
        );
      }
    },
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
            color: Colors.blue, // Color del enlace
            decoration: TextDecoration.underline,
          ),
        ),
      ],
    ),
  );
}