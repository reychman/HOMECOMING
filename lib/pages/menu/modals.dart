import 'dart:async';
import 'dart:convert';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
            if (mascota.estado != 'adopcion'&& mascota.estado != 'pendiente') ...[
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
          FutureBuilder<bool>(
            future: verificarInteresExistente(mascota.id),
            builder: (context, snapshot) {
              if (snapshot.hasData && !snapshot.data!) {
                return _buildActionButton(
                  'Me interesa',
                  Icons.favorite,
                  Colors.pink,
                  () => _mostrarDialogoConfirmacion(context, mascota),
                );
              }
              return SizedBox.shrink();
            },
          )
          else if (mascota.estado == 'perdido')
            _buildActionButton(
            'Reportar Avistamiento',
            Icons.visibility,
            Colors.blue,
            () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              int? adoptanteId = prefs.getInt('usuario_id');

              if (adoptanteId == null) {
                mostrarDialogo(context);
                return;
              }
              enviarMensajeWhatsApp(context, mascota, 'perdido');
            },
          ),
        ],
      ),
    ),
  );
}
Future<bool> verificarInteresExistente(int mascotaId) async {
  final adoptanteId = await obtenerIdAdoptante();
  if (adoptanteId == null) return false;

  final response = await http.get(
    Uri.parse(
      'http://$serverIP/homecoming/homecomingbd_v2/adopcion.php?verificar_interes=true&mascota_id=$mascotaId&adoptante_id=$adoptanteId'
    ),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data['data']['existe_interes'] ?? false;
  }
  return false;
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
            fontSize: 16,
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
  return SizedBox(
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
void _mostrarDialogoConfirmacion(BuildContext context, Mascota mascota) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(
              Icons.pets,
              color: Colors.green[700],
              size: 30,
            ),
            SizedBox(width: 10),
            Text(
              'Confirmar Interés',
              style: TextStyle(
                color: Colors.green[700],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: SizedBox(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '¿Estás seguro que deseas mostrar interés en adoptar a ${mascota.nombre}?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Al confirmar, el dueño de la mascota podrá ver tu información de contacto para el proceso de adopción.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        actions: [
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Cancelar',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el modal de confirmación
                      _registrarInteresConfirmado(context, mascota); // Realiza la acción
                      Navigator.of(context).pop(); // Cierra el modal principal
                      Navigator.pushReplacementNamed(context, '/inicio'); // Redirige a la página principal
                    },
                    child: Text(
                      'Confirmar',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    },
  ).then((confirmado) {
    if (confirmado == true) {
      Navigator.of(context).pop(); // Cerrar el modal principal
      _registrarInteresConfirmado(context, mascota);
    }
  });
}

// Nueva función para manejar el registro de interés después de la confirmación
  void _registrarInteresConfirmado(BuildContext context, Mascota mascota) async {
    int? adoptanteId = await obtenerIdAdoptante();
    
    if (adoptanteId == null) {
      mostrarDialogo(context);
      return;
    }

    var body = {
      'action': 'registrar_interes',
      'mascota_id': mascota.id.toString(),
      'adoptante_id': adoptanteId.toString(),
    };

    final response = await http.post(
      Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/adopcion.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: body,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'success') {
        mostrarMensaje(context, data['message']);
        // Volver a abrir el modal actualizado
        mostrarModalInfoMascota(context, mascota);
      } else if (data['message'] != 'INTERES_EXISTENTE') {
        mostrarMensaje(context, data['message']);
      }
    } else {
      mostrarMensaje(context, 'Error al registrar el interés');
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

  // Mostrar el diálogo de avistamiento
  final avistamientoData = await mostrarDialogoAvistamiento(context, mascota);
  if (avistamientoData != null) {
    // Guardar el avistamiento en la base de datos
    await guardarAvistamiento(avistamientoData);

    try {
      // Determinar si estamos en web o móvil
      if (kIsWeb) {
        // Para web, usar wa.me
        final whatsappUri = Uri.https(
          'wa.me',
          '/${mascota.telefonoDueno}',
          {'text': cargarMensaje},
        );
        await launchUrl(whatsappUri);
      } else {
        // Para Android, usar whatsapp://send
        String url = "whatsapp://send?phone=${mascota.telefonoDueno}&text=${Uri.encodeComponent(cargarMensaje)}";
        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
        } else {
          // Si WhatsApp no está instalado
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('WhatsApp no está instalado en el dispositivo'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('Error al abrir WhatsApp: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo abrir WhatsApp'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

Future<void> guardarAvistamiento(Map<String, dynamic> data) async {
  try {
    // Obtener el usuario_id almacenado en SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? usuarioId = prefs.getInt('usuario_id');

    if (usuarioId == null) {
      throw Exception('Usuario no identificado. Por favor, inicie sesión nuevamente.');
    }

    final response = await http.post(
      Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/avistamientos.php'),
      headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      body: {
        'id_mascota': data['mascotaId'].toString(),
        'latitud': data['latitud'].toString(),
        'longitud': data['longitud'].toString(),
        'detalles': data['detalles'] ?? '',
        'usuario_id': usuarioId.toString(), // Incluye el usuario_id
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Error al guardar el avistamiento: ${response.body}');
    }
  } catch (e) {
    print('Error en guardarAvistamiento: $e');
    rethrow;
  }
}

Future<LatLng?> fetchPetLocation(int mascotaId) async {
  try {
    final response = await http.get(
      Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/get_pet_location.php?mascota_id=$mascotaId')
    );

    
    if (response.statusCode == 200) {
      final locationData = json.decode(response.body);
      
      if (locationData['latitud'] != null && locationData['longitud'] != null) {
        double lat = double.parse(locationData['latitud'].toString());
        double lon = double.parse(locationData['longitud'].toString());
        return LatLng(lat, lon);
      }
    }
  } catch (e) {
    print('Error fetching pet location: $e');
  }

  return null;
}

Future<Map<String, dynamic>?> mostrarDialogoAvistamiento(
  BuildContext context, Mascota mascota) async {
  final Completer<GoogleMapController> _controller = Completer();
  LatLng? _selectedLocation;
  final Set<Marker> _markers = {};
  
  bool isMobile = !kIsWeb; // Si no es Web, entonces es móvil

  // Cargar ícono personalizado, con tamaño diferente para móvil
  BitmapDescriptor customIcon;

  if (isMobile) {
    // Usar un tamaño reducido para móvil
    customIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(32, 32)), // Tamaño reducido para móvil
      'assets/imagenes/ubicacion.png',
    );
  } else {
    // Usar el tamaño original para Web
    customIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)), // Tamaño original para Web
      'imagenes/ubicacion.png',
    );
  }

  // Fetch and add original location marker
  LatLng? originalLocation = await fetchPetLocation(mascota.id);
  
  // Initialize camera position
  CameraPosition _kInitialPosition = CameraPosition(
    target: originalLocation ?? LatLng(-17.3935, -66.1570), // Default coordinates if no location found
    zoom: 12.0,
  );
  
  if (originalLocation != null) {
    _markers.add(
      Marker(
        markerId: MarkerId('original_location'),
        position: originalLocation,
        icon: customIcon, // Usar el ícono personalizado
        infoWindow: InfoWindow(title: 'Ubicación original de pérdida'),
      ),
    );
  }

  // Crear un formulario para ingresar detalles del avistamiento
  final formKey = GlobalKey<FormState>();
  String? detalles;

  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Reportar Avistamiento'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Mascota: ${mascota.nombre}\nEl mascador muestra la ubicacion donde se perdio la mascota'),
                    SizedBox(height: 16.0),
                    SizedBox(
                      width: 400,
                      height: 300,
                      child: GoogleMap(
                        mapType: MapType.normal,
                        initialCameraPosition: _kInitialPosition,
                        onMapCreated: (GoogleMapController controller) {
                          _controller.complete(controller);
                        },
                        markers: _markers,
                        onTap: (LatLng location) {
                          setState(() {
                            // Añadir marcador de avistamiento
                            _markers.removeWhere(
                                (marker) => marker.markerId.value == 'selected_location');
                            _markers.add(
                              Marker(
                                markerId: MarkerId('selected_location'),
                                position: location,
                                icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
                                infoWindow: InfoWindow(title: 'Avistamiento reportado'),
                              ),
                            );
                            _selectedLocation = location;
                          });
                        },
                      ),
                    ),
                    Text(
                      _selectedLocation != null
                          ? 'Ubicación seleccionada: ${_selectedLocation!.latitude}, ${_selectedLocation!.longitude}'
                          : 'Toque el mapa para seleccionar una ubicación',
                      style: TextStyle(fontSize: 12),
                    ),
                    SizedBox(height: 16.0),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Detalles del Avistamiento',
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa los detalles del avistamiento';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        detalles = value;
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              if (formKey.currentState?.validate() ?? false) {
                if (_selectedLocation == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Por favor, seleccione una ubicación en el mapa')),
                  );
                  return;
                }
                formKey.currentState?.save();

                // Guardar avistamiento
                try {
                  final sightingData = {
                    'mascotaId': mascota.id,
                    'latitud': _selectedLocation!.latitude,
                    'longitud': _selectedLocation!.longitude,
                    'detalles': detalles,
                  };

                  Navigator.of(context).pop(sightingData);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error al guardar el avistamiento: $e')),
                  );
                }
              }
            },
            child: Text('Reportar'),
          ),
        ],
      );
    },
  );
}
