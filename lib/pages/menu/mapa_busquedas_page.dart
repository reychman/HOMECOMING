import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';

class MapaBusquedasPage extends StatefulWidget {
  @override
  _MapaBusquedasPageState createState() => _MapaBusquedasPageState();
}

class _MapaBusquedasPageState extends State<MapaBusquedasPage> {
  late GoogleMapController _mapController;
  BitmapDescriptor? _customIcon;

  final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-17.3957147, -66.1581871),
    zoom: 10,
  );

  @override
  void initState() {
    super.initState();
    _loadCustomMarker();
  }

  Future<void> _loadCustomMarker() async {
    _customIcon = await BitmapDescriptor.fromAssetImage(
      ImageConfiguration(size: Size(30, 30)), // Tamaño opcional de la imagen
      'assets/imagenes/perro.png',
    );
    setState(() {});
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
      drawer: MenuWidget(),
      body: _customIcon == null
          ? Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: _initialPosition,
              onMapCreated: _onMapCreated,
              markers: _createMarkers(),
            ),
    );
  }

  Set<Marker> _createMarkers() {
    return <Marker>{
      Marker(
        markerId: MarkerId('marker_1'),
        position: LatLng(-17.3957147, -66.1581871),
        icon: _customIcon ?? BitmapDescriptor.defaultMarker,
        infoWindow: InfoWindow(title: 'Ubicación 1', snippet: 'Descripción 1'),
      ),
      // Agrega más marcadores según sea necesario
    };
  }
}
