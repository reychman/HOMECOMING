import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/mascota.dart';
import 'package:homecoming/pages/menu/info_mascotas_page.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/usuario.dart';
import 'dart:convert'; // Importa para decodificar JSON
import 'package:http/http.dart' as http; // Importa para solicitudes HTTP

class MapaBusquedasPage extends StatefulWidget {
  @override
  _MapaBusquedasPageState createState() => _MapaBusquedasPageState();
}

class _MapaBusquedasPageState extends State<MapaBusquedasPage> {
  GoogleMapController? _mapController;
  BitmapDescriptor? _perroIcon;
  BitmapDescriptor? _gatoIcon;

  final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-17.3957147, -66.1581871),
    zoom: 10,
  );

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
    _fetchMascotas(); // Cargar mascotas desde la base de datos
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
    setState(() {});
  }

Future<void> _fetchMascotas() async {
  final response = await http.get(Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/mapa_busquedas.php'));

  if (response.statusCode == 200) {
    final List<dynamic> data = json.decode(response.body);
    setState(() {
      _mascotas = data.map((json) => Mascota.fromJson(json)).toList();
    });
  } else {
    print('Error al obtener los datos: ${response.statusCode}');
  }
}


  void _onMapCreated(GoogleMapController controller) {
    setState(() {
      _mapController = controller;
    });
    _animateToInitialPosition(); // Llama a la función para animar la cámara
  }
  void _animateToInitialPosition() {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(-17.3957147, -66.1581871),
            zoom: 14,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de búsquedas'),
      ),
      drawer: MenuWidget(usuario: usuario ?? Usuario.vacio()), 
      body: (_perroIcon == null || _gatoIcon == null)
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: _onMapCreated, // Asegúrate de asignar el método aquí
              markers: _createMarkers(),
            ),
    );
  }

  Set<Marker> _createMarkers() {
    return _mascotas.map((mascota) {
      BitmapDescriptor? icon = (mascota.especie == 'perro') ? _perroIcon : _gatoIcon;
      
      return Marker(
        markerId: MarkerId(mascota.id.toString()),
        position: LatLng(mascota.latitud!, mascota.longitud!),
        icon: icon ?? BitmapDescriptor.defaultMarker,
        onTap: () => _showMascotaInfoDialog(mascota), // Mostrar el diálogo al hacer clic
      );
    }).toSet();
  }

  void _showMascotaInfoDialog(Mascota mascota) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mostrar la foto de la mascota
              Center(
                child: mascota.foto.isNotEmpty
                    ? Image.asset(
                        'assets/imagenes/fotos_mascotas/${mascota.foto}',
                        width: 150,
                        height: 150,
                        fit: BoxFit.cover,
                      )
                    : Icon(Icons.pets, size: 100, color: Colors.grey),
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
                      Navigator.pop(context); // Cerrar el diálogo
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InfoMascotasPage(mascota: mascota), // Navegar a la página de información
                        ),
                      );
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
  }
}
