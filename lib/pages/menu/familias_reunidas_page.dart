import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/mascota.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/menu/modals.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:homecoming/pages/usuario.dart';

class FamiliasReunidasPage extends StatefulWidget {
  @override
  _FamiliasReunidasPageState createState() => _FamiliasReunidasPageState();
}

class _FamiliasReunidasPageState extends State<FamiliasReunidasPage> {
  late Future<List<Mascota>> futureMascotas;
  List<Mascota> _mascotas = [];
  List<Mascota> _mascotasFiltradas = [];
  TextEditingController _searchController = TextEditingController();
  Map<int, int> _currentImageIndex = {};

  @override
  void initState() {
    super.initState();
    futureMascotas = obtenerMascotas();
    _searchController.addListener(_buscarMascota);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Mascota>> obtenerMascotas() async {
    print("Obteniendo las mascotas encontradas...");
    final response = await http.get(Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/mascotas.php?ip_servidor=$serverIP'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      List<Mascota> mascotas = jsonResponse.map((data) => Mascota.fromJson(data)).toList();
      List<Mascota> mascotasEncontradas = mascotas.where((m) => m.estado == 'encontrado').toList();

      setState(() {
        _mascotas = mascotasEncontradas;
        _mascotasFiltradas = mascotasEncontradas;
        for (var mascota in mascotasEncontradas) {
          _currentImageIndex[mascota.id] = 0;
        }
      });
      return mascotasEncontradas;
    } else {
      throw Exception('Error al cargar las mascotas encontradas');
    }
  }

  void _buscarMascota() {
    String searchQuery = _searchController.text.toLowerCase();
    setState(() {
      _mascotasFiltradas = _mascotas.where((mascota) {
        final nombreMascota = mascota.nombre.toLowerCase();
        return nombreMascota.contains(searchQuery);
      }).toList();
    });
  }

  void _cambiarImagen(int mascotaId, List<String> fotos, bool avanzar) {
    setState(() {
      int currentIndex = _currentImageIndex[mascotaId]!;
      if (avanzar) {
        _currentImageIndex[mascotaId] = currentIndex < fotos.length - 1 ? currentIndex + 1 : 0;
      } else {
        _currentImageIndex[mascotaId] = currentIndex > 0 ? currentIndex - 1 : fotos.length - 1;
      }
    });
  }

  Widget _buildMascotaCard(Mascota mascota, BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Text(
              '¡Mascota reunida con su familia!',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  iconSize: 30.0,
                  onPressed: () {
                    if (mascota.fotos.isNotEmpty) {
                      _cambiarImagen(mascota.id, mascota.fotos, false);
                    }
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => mostrarModalInfoMascota(context, mascota),
                    child: mascota.fotos.isNotEmpty
                        ? Image.network(
                            mascota.fotos[_currentImageIndex[mascota.id]!],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(Icons.error, size: 100, color: Colors.red);
                            },
                          )
                        : Icon(Icons.pets, size: 200, color: Colors.grey),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  iconSize: 30.0,
                  onPressed: () {
                    if (mascota.fotos.isNotEmpty) {
                      _cambiarImagen(mascota.id, mascota.fotos, true);
                    }
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              mascota.nombre.toUpperCase(),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              'Fecha perdida: ${mascota.fechaPerdida}',
              style: TextStyle(color: Color.fromARGB(255, 53, 53, 53), fontSize: 14),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Text(
              mascota.lugarPerdida,
              style: TextStyle(color: Color.fromARGB(255, 53, 53, 53), fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments;
    final Usuario usuario = arguments is Usuario ? arguments : Usuario.vacio();

    return Scaffold(
      appBar: AppBar(
        title: Text('Familias Reunidas'),
        backgroundColor: Colors.green[200],
      ),
      drawer: MenuWidget(usuario: usuario),
      backgroundColor: Colors.green[50],
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Determinar el número de columnas basado en el ancho de la pantalla
          int crossAxisCount;
          if (constraints.maxWidth > 1200) {
            crossAxisCount = 4; // Extra large screens
          } else if (constraints.maxWidth > 900) {
            crossAxisCount = 3; // Desktop/Tablet landscape
          } else if (constraints.maxWidth > 600) {
            crossAxisCount = 2; // Tablet portrait
          } else {
            crossAxisCount = 1; // Mobile
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar mascota',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Un reencuentro que alegra el alma",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Aquí celebramos las historias de aquellas mascotas que, gracias al esfuerzo y la compasión de muchas personas, lograron volver a casa. ¡Cada reencuentro es un recordatorio de lo importante que es no rendirse!",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      Text(
                        "Si ves una mascota perdida, ¡no dudes en actuar! Tú podrías ser la razón de otro final feliz.",
                        style: TextStyle(
                          fontSize: 14,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                FutureBuilder<List<Mascota>>(
                  future: futureMascotas,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Aún no hay mascotas reunidas con su familia. ¡Sé parte del cambio y ayuda a otra mascota a regresar a casa!',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[700],
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      );
                    }

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 0.85,
                        ),
                        itemCount: _mascotasFiltradas.length,
                        itemBuilder: (context, index) {
                          return _buildMascotaCard(_mascotasFiltradas[index], context);
                        },
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}