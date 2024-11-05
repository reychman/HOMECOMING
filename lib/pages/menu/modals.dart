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
    barrierDismissible: true,
    barrierColor: Colors.black87,
    builder: (BuildContext context) {
      return TweenAnimationBuilder(
        duration: Duration(milliseconds: 300),
        tween: Tween<double>(begin: 0.0, end: 1.0),
        builder: (context, double value, child) {
          return Transform.scale(
            scale: value,
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              elevation: 15,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  bool isNarrowScreen = constraints.maxWidth < 600;

                  return Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.8,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 15,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Close button
                        Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            icon: Icon(Icons.close, color: Colors.grey[600]),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ),
                        Expanded(
                          child: isNarrowScreen
                              ? _buildVerticalLayout(context, mascota)
                              : _buildHorizontalLayout(context, mascota),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    },
  );
}

Widget _buildVerticalLayout(BuildContext context, Mascota mascota) {
  return Column(
    children: [
      // Carrusel mejorado
      Expanded(
        flex: 1,
        child: _buildEnhancedCarousel(mascota),
      ),
      SizedBox(height: 20),
      // Información
      Expanded(
        flex: 1,
        child: _buildInfoSection(context, mascota),
      ),
    ],
  );
}

Widget _buildHorizontalLayout(BuildContext context, Mascota mascota) {
  return Row(
    children: [
      Expanded(
        flex: 1,
        child: _buildEnhancedCarousel(mascota),
      ),
      SizedBox(width: 20),
      Expanded(
        flex: 1,
        child: _buildInfoSection(context, mascota),
      ),
    ],
  );
}

Widget _buildEnhancedCarousel(Mascota mascota) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 10,
          offset: Offset(0, 5),
        ),
      ],
    ),
    child: CarouselSlider(
      options: CarouselOptions(
        height: double.infinity,
        viewportFraction: 1.0,
        enlargeCenterPage: true,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 5),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
      ),
      items: mascota.fotos.map((foto) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 5,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.network(
              foto,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  ),
                );
              },
            ),
          ),
        );
      }).toList(),
    ),
  );
}

Widget _buildInfoSection(BuildContext context, Mascota mascota) {
  return Container(
    padding: EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.grey[50],
      borderRadius: BorderRadius.circular(20),
    ),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEnhancedSectionHeader('Información de la Mascota', Icons.pets),
          _buildEnhancedInfoCard([
            _buildInfoText('Nombre: ${mascota.nombre.toUpperCase()}'),
            _buildInfoText('Especie: ${mascota.especie.toUpperCase()}'),
            _buildInfoText('Raza: ${mascota.raza.toUpperCase()}'),
            _buildInfoText('Sexo: ${mascota.sexo.toUpperCase()}'),
            if (mascota.estado != 'adopcion') ...[
              _buildInfoText('Fecha de pérdida: ${mascota.fechaPerdida}'),
              _buildInfoText('Lugar de pérdida: ${mascota.lugarPerdida.toUpperCase()}'),
            ],
            _buildStatusChip(mascota.estado),
            _buildInfoText('Descripción: ${mascota.descripcion.toUpperCase()}'),
          ]),
          
          SizedBox(height: 20),
          _buildEnhancedSectionHeader('Información del Dueño', Icons.person),
          _buildEnhancedInfoCard([
            _buildInfoText('Nombre Completo: ${mascota.nombreDueno.toUpperCase()} ${mascota.primerApellidoDueno.toUpperCase()} ${mascota.segundoApellidoDueno.toUpperCase()}'),
            SizedBox(height: 10),
            _buildContactButton(
              icon: Icons.email,
              text: mascota.emailDueno,
              onTap: () => _launchEmail(mascota.emailDueno),
            ),
            SizedBox(height: 10),
            _buildWhatsAppButton(context, mascota),
          ]),
          
          SizedBox(height: 20),
          if (mascota.estado == 'adopcion' || mascota.estado == 'pendiente')
            _buildActionButton(
              'Me interesa',
              Icons.favorite,
              Colors.pink,
              () {
                Navigator.of(context).pop();
                _interesadoEnAdopcion(context, mascota);
              },
            )
          else if (mascota.estado == 'perdido')
            _buildActionButton(
              'Reportar Avistamiento',
              Icons.visibility,
              Colors.blue,
              () => enviarMensajeWhatsApp(context, mascota, 'perdido'),
            ),
        ],
      ),
    ),
  );
}

Widget _buildEnhancedSectionHeader(String title, IconData icon) {
  return Container(
    margin: EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Icon(icon, color: Colors.blue[700], size: 24),
        SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue[700],
          ),
        ),
      ],
    ),
  );
}

Widget _buildEnhancedInfoCard(List<Widget> children) {
  return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(15),
    ),
    child: Padding(
      padding: EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    ),
  );
}

Widget _buildStatusChip(String estado) {
  Color chipColor;
  IconData chipIcon;
  switch (estado.toLowerCase()) {
    case 'adopcion':
      chipColor = Colors.green;
      chipIcon = Icons.pets;
      break;
    case 'perdido':
      chipColor = Colors.red;
      chipIcon = Icons.search;
      break;
    case 'pendiente':
      chipColor = Colors.orange;
      chipIcon = Icons.pending;
      break;
    default:
      chipColor = Colors.blue;
      chipIcon = Icons.info;
  }

  return Container(
    margin: EdgeInsets.symmetric(vertical: 8),
    child: Chip(
      avatar: Icon(chipIcon, color: Colors.white, size: 18),
      label: Text(
        estado.toUpperCase(),
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
      backgroundColor: chipColor,
    ),
  );
}

Widget _buildContactButton({
  required IconData icon,
  required String text,
  required VoidCallback onTap,
}) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue[300]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue[700], size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  color: Colors.blue[700],
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildWhatsAppButton(BuildContext context, Mascota mascota) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () => enviarMensajeWhatsApp(context, mascota, mascota.estado),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.green[300]!),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Image.network(
              'http://$serverIP/homecoming/assets/imagenes/whatsapp.png',
              width: 24,
              height: 24,
            ),
            SizedBox(width: 10),
            Text(
              mascota.telefonoDueno,
              style: TextStyle(
                color: Colors.green[700],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildActionButton(
  String text,
  IconData icon,
  Color color,
  VoidCallback onPressed,
) {
  return Container(
    width: double.infinity,
    child: ElevatedButton.icon(
      icon: Icon(icon, color: Colors.white),
      label: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
      onPressed: onPressed,
    ),
  );
}

Future<void> _launchEmail(String email) async {
  final Uri emailUri = Uri(
    scheme: 'mailto',
    path: email,
  );
  if (await canLaunchUrl(emailUri)) {
    await launchUrl(emailUri);
  }
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

