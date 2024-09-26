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
  List<Mascota> _mascotas = []; // Lista de mascotas completa
  List<Mascota> _mascotasFiltradas = []; // Lista filtrada para mostrar
  TextEditingController _searchController = TextEditingController();

  // Mapa para manejar el índice actual de imagen para cada mascota
  Map<int, int> _currentImageIndex = {};

  @override
  void initState() {
    super.initState();
    futureMascotas = obtenerMascotas();
    _searchController.addListener(_buscarMascota); // Añadir listener al controlador
  }

  @override
  void dispose() {
    _searchController.dispose(); // Liberar recursos del controlador
    super.dispose();
  }

  Future<List<Mascota>> obtenerMascotas() async {
    print("Obteniendo las mascotas encontradas...");
    final response = await http.get(Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/mascotas.php'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      List<Mascota> mascotas = jsonResponse.map((data) => Mascota.fromJson(data)).toList();

      // Filtrar solo las mascotas con estado "encontrado"
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

  // Función para cambiar manualmente la imagen al hacer clic
  void _cambiarImagen(int mascotaId, List<String> fotos, bool avanzar) {
    setState(() {
      int currentIndex = _currentImageIndex[mascotaId]!;
      if (avanzar) {
        if (currentIndex < fotos.length - 1) {
          _currentImageIndex[mascotaId] = currentIndex + 1;
        } else {
          _currentImageIndex[mascotaId] = 0; // Regresa a la primera imagen si es la última
        }
      } else {
        if (currentIndex > 0) {
          _currentImageIndex[mascotaId] = currentIndex - 1;
        } else {
          _currentImageIndex[mascotaId] = fotos.length - 1;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments;
    final Usuario usuario = arguments is Usuario ? arguments : Usuario.vacio();

    return Scaffold(
      appBar: AppBar(
        title: Text('Familias Reunidas'),
        backgroundColor: Color.fromARGB(255, 123, 209, 125),
      ),
      drawer: MenuWidget(usuario: usuario),
      body: Column(
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
          Expanded(
            child: FutureBuilder<List<Mascota>>(
              future: futureMascotas,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No se encontraron mascotas encontradas.'));
                } else {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 1; // Solo un card en pantallas angostas
                      if (constraints.maxWidth > 600) {
                        crossAxisCount = 2; // Dos cards en pantallas anchas
                      }

                      return GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          childAspectRatio: 0.9, // Mantener la relación de aspecto de los cards
                        ),
                        itemCount: _mascotasFiltradas.length,
                        itemBuilder: (context, index) {
                          final mascota = _mascotasFiltradas[index];

                          return GestureDetector(
                            onTap: () {
                              mostrarModalInfoMascota(context, mascota); // Mostrar modal en lugar de navegar
                            },
                            child: Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Container(
                                padding: EdgeInsets.all(10.0),
                                constraints: BoxConstraints(
                                  maxHeight: 350, // Limita la altura máxima del Card
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
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
                                              onTap: () {
                                                mostrarModalInfoMascota(context, mascota);
                                              },
                                              child: mascota.fotos.isNotEmpty
                                                  ? Image.network(
                                                      'http://localhost/homecoming/assets/imagenes/fotos_mascotas/${mascota.fotos[_currentImageIndex[mascota.id]!]}',
                                                      width: 400,
                                                      height: 250,
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
                                        style: TextStyle(color: const Color.fromARGB(255, 53, 53, 53), fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
