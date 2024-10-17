import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/mascota.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/menu/modals.dart';
import 'package:homecoming/pages/usuario.dart';
import 'dart:convert'; // Importa para decodificar JSON
import 'package:http/http.dart' as http; // Importa para solicitudes HTTP

class MapaBusquedasPage extends StatefulWidget {
  @override
  _MapaBusquedasPageState createState() => _MapaBusquedasPageState();
}

class _MapaBusquedasPageState extends State<MapaBusquedasPage> {
  GoogleMapController? _mapController; // Controlador del mapa
  BitmapDescriptor? _perroIcon;
  BitmapDescriptor? _gatoIcon;
  bool _isMapReady = false;
  
  final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-17.3957147, -66.1581871),
    zoom: 10,
  );

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers(); // Cargar íconos personalizados
    _fetchMascotas(); // Cargar mascotas desde la base de datos
  }

  // Configura el controlador del mapa y anima la cámara a la posición inicial
void _onMapCreated(GoogleMapController controller) {
  _mapController = controller;
  setState(() {
    _isMapReady = true;
    _animateToInitialPosition(); // Animar solo después de que el mapa esté listo
  });
  //print("Mapa creado y animado a la posición inicial");
}

  // Animar la cámara a la posición inicial
  void _animateToInitialPosition() {
    if (_mapController != null) {
      //print("Animando cámara a la posición inicial");
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(-17.3957147, -66.1581871),
            zoom: 14,
          ),
        ),
      );
    } else {
      print("El controlador del mapa es null");
    }
  }
  // Asegurarse de liberar el controlador cuando el widget es destruido
@override
void dispose() {
  // Asegúrate de que el controlador no sea null antes de intentar eliminarlo
  if (_mapController != null) {
    _mapController!.dispose();
  }
  super.dispose();
}

  Usuario? usuario;
  List<Mascota> _mascotas = [];

  Future<void> _loadCustomMarkers() async {
    _perroIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      'assets/imagenes/perro.png',
    );
    _gatoIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(48, 48)),
      'assets/imagenes/gato.png',
    );
    setState(() {}); // Actualiza el estado con los íconos cargados
  }

Future<void> _fetchMascotas() async {
  final response = await http.get(Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/mapa_busquedas.php'));

  if (response.statusCode == 200) {
    //print('Response body: ${response.body}');
    final List<dynamic> data = json.decode(response.body);
    setState(() {
      _mascotas = data.map((json) {
        // Asegúrate de que las URLs de las fotos sean absolutas y válidas
        List<String> fotos = [];
        if (json['fotos'] is List) {
          fotos = (json['fotos'] as List).map((foto) {
            if (foto is String) {
              if (foto.startsWith('http')) {
                return foto;
              } else {
                // Asegúrate de que esta es la ruta correcta a tus imágenes
                return 'http://$serverIP/homecoming/assets/imagenes/fotos_mascotas/$foto';
              }
            }
            return ''; // En caso de que el elemento no sea un String
          }).where((foto) => foto.isNotEmpty).toList();
        }
        
        return Mascota.fromJson({
          ...json,
          'fotos': fotos,
        });
      }).toList();
    });
    // Imprimir información de depuración
    //for (var mascota in _mascotas) {
      //print('Mascota: ${mascota.nombre}');
      //print('Fotos: ${mascota.fotos}');
      //print('Nombre del dueño: ${mascota.nombreDueno}');
    //}
  } else {
    print('Error al obtener los datos: ${response.statusCode}');
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        title: Text('Mapa de búsquedas'),
      ),
      drawer: MenuWidget(usuario: usuario ?? Usuario.vacio()), // Menú lateral
      body: (_perroIcon == null || _gatoIcon == null)
          ? Center(child: CircularProgressIndicator()) // Muestra el loading mientras se cargan los íconos
          : GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: _onMapCreated,
              markers: _createMarkers(), // Crear marcadores
            ),
    );
  }

  // Crear los marcadores de las mascotas
  Set<Marker> _createMarkers() {
    return _mascotas.map((mascota) {
      BitmapDescriptor? icon = (mascota.especie == 'perro') ? _perroIcon : _gatoIcon;
      
      return Marker(
        markerId: MarkerId(mascota.id.toString()),
        position: LatLng(mascota.latitud!, mascota.longitud!),
        icon: icon ?? BitmapDescriptor.defaultMarker,
        onTap: () => _showMascotaInfoDialog(mascota), // Mostrar el diálogo al hacer clic en el marcador
      );
    }).toSet();
  }

  // Mostrar un diálogo con la información de la mascota
  void _showMascotaInfoDialog(Mascota mascota) {
    int _currentImageIndex = 0;

    showDialog(
      context: context,
      barrierDismissible: false, // Impide cerrar el modal al hacer clic fuera de él
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
              title: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'No me dejes solo,',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Ayúdame a encontrar el camino.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              contentPadding: EdgeInsets.all(16), // Padding alrededor del contenido
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Mostrar la foto de la mascota con controles de navegación
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back),
                        onPressed: () {
                          if (mascota.fotos.isNotEmpty) {
                            setState(() {
                              // Navegar a la imagen anterior
                              if (_currentImageIndex > 0) {
                                _currentImageIndex--;
                              } else {
                                _currentImageIndex = mascota.fotos.length - 1; // Ir a la última si estamos en la primera
                              }
                            });
                          }
                        },
                      ),
                      SizedBox(width: 10),
                      Center(
                        child: mascota.fotos.isNotEmpty
                            ? Image.network(
                              mascota.fotos[_currentImageIndex],  // Ya es una URL completa
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(Icons.error, size: 100, color: Colors.red);
                              },
                            )
                            : Icon(Icons.pets, size: 100, color: Colors.grey), // Icono si no hay fotos
                      ),
                      SizedBox(width: 10),
                      IconButton(
                        icon: Icon(Icons.arrow_forward),
                        onPressed: () {
                          if (mascota.fotos.isNotEmpty) {
                            setState(() {
                              // Navegar a la siguiente imagen
                              if (_currentImageIndex < mascota.fotos.length - 1) {
                                _currentImageIndex++;
                              } else {
                                _currentImageIndex = 0; // Volver a la primera si estamos en la última
                              }
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  // Mostrar el nombre de la mascota
                  Text(
                    'Nombre: ${mascota.nombre.isNotEmpty ? mascota.nombre.toUpperCase() : 'Desconocido'}',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  // Mostrar la descripción de la mascota
                  Text(mascota.descripcion),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Botón para ver más detalles
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context); // Cerrar el diálogo actual
                          mostrarModalInfoMascota(context, mascota); // Llamar al método de home_page.dart
                        },
                        child: Text('Ver más detalles'),
                      ),
                      SizedBox(width: 8), // Espacio entre los botones
                      // Botón para cerrar el diálogo
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('Cerrar'),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
