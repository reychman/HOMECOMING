import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/mascota.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/usuario.dart';
import 'dart:convert'; // Importa para decodificar JSON
import 'package:http/http.dart' as http; // Importa para solicitudes HTTP

class MapaBusquedasPage extends StatefulWidget {
  @override
  _MapaBusquedasPageState createState() => _MapaBusquedasPageState();
}

class _MapaBusquedasPageState extends State<MapaBusquedasPage> {
  late GoogleMapController _mapController;
  BitmapDescriptor? _perroIcon;
  BitmapDescriptor? _gatoIcon;
  List<Mascota> _mascotas = [];

  final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-17.3957147, -66.1581871),
    zoom: 10,
  );

  @override
  void initState() {
    super.initState();
    _loadCustomMarkers();
    _fetchMascotas();
  }

  Future<void> _loadCustomMarkers() async {
    _perroIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(30, 30)),
      'assets/imagenes/perro.png',
    );
    _gatoIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(39, 39)),
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
    _mapController = controller;
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(-17.3957147, -66.1581871),
          zoom: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de búsquedas'),
      ),
      drawer: MenuWidget(usuario: Usuario.vacio()),
      body: _perroIcon == null || _gatoIcon == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: _onMapCreated,
              markers: _createMarkers(),
            ),
    );
  }

  Set<Marker> _createMarkers() {
    return _mascotas.map((mascota) {
      final icon = mascota.especie.toLowerCase() == 'perro' ? _perroIcon : _gatoIcon;
      return Marker(
        markerId: MarkerId(mascota.id.toString()),
        position: LatLng(mascota.latitud!, mascota.longitud!),
        icon: icon ?? BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(
          title: 'Aquí hay una mascota desaparecida',
          snippet: mascota.descripcion,
        ),
      );
    }).toSet();
  }
}
