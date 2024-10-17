import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/login/iniciar_sesion_page.dart';
import 'package:homecoming/pages/crear_publicacion_page.dart';
import 'package:homecoming/pages/mascota.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/menu/modals.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homecoming/pages/usuario.dart';

class PaginaPrincipal extends StatefulWidget {
  @override
  _PaginaPrincipalState createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  late Future<List<Mascota>> futureMascotas;
  List<Mascota> mascotasEnAdopcion = [];
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

  Usuario? usuario;
  Future<bool> usuarioEstaLogeado() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false; // Verifica la bandera
  }

  Widget _cardAdopciones(Mascota mascota) {
    return Card(
      child: Column(
        children: [
          Expanded(
            child: mascota.fotos.isNotEmpty
                ? CarouselSlider.builder(
                    itemCount: mascota.fotos.length,
                    itemBuilder: (BuildContext context, int index, int realIndex) {
                      return _imagenesManejoErrores(mascota.fotos[index]);
                    },
                    options: CarouselOptions(
                      viewportFraction: 1.0,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                    ),
                  )
                : Center(child: Text('No hay imágenes disponibles')),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              mascota.nombre,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  Widget _imagenesManejoErrores(String imageUrl) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        print('Error loading image: $imageUrl');
        print('Error details: $error');
        return Center(child: Icon(Icons.error));
      },
      loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
    );
  }
  String obtenerMensajeFecha(DateTime fechaPerdida) {
    final hoy = DateTime.now();
    final diferenciaDias = hoy.difference(fechaPerdida).inDays;

    if (diferenciaDias == 0) {
      return 'Hoy';
    } else if (diferenciaDias == 1) {
      return 'Ayer';
    } else if (diferenciaDias <= 3) {
      return 'Hace un par de días';
    } else if (diferenciaDias == 7) {
      return 'Hace 1 semana';
    } else {
      return 'Hace más de una semana';
    }
  }

Future<List<Mascota>> obtenerMascotas() async {
    print("Obteniendo las mascotas...");
    final response = await http.get(Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/mascotas.php'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      print("Respuesta JSON: $jsonResponse");
      
      List<Mascota> todasLasMascotas = jsonResponse.map((data) => Mascota.fromJson(data)).toList();
      print("Total de mascotas obtenidas: ${todasLasMascotas.length}");
      
      setState(() {
        mascotasEnAdopcion = todasLasMascotas.where((m) => m.estado == 'adopcion').toList();
        _mascotasFiltradas = todasLasMascotas.where((m) => m.estado == 'perdido').toList();
      });
      
      print("Mascotas en adopción: ${mascotasEnAdopcion.length}");
      print("Mascotas perdidas: ${_mascotasFiltradas.length}");
      
      for (var mascota in todasLasMascotas) {
        _currentImageIndex[mascota.id] = 0;
      }

      return todasLasMascotas;
    } else {
      throw Exception('Error al cargar las mascotas: ${response.statusCode}');
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
        // Avanzar a la siguiente imagen
        if (currentIndex < fotos.length - 1) {
          _currentImageIndex[mascotaId] = currentIndex + 1;
        } else {
          _currentImageIndex[mascotaId] = 0; // Regresa a la primera imagen si es la última
        }
      } else {
        // Retroceder a la imagen anterior
        if (currentIndex > 0) {
          _currentImageIndex[mascotaId] = currentIndex - 1;
        } else {
          _currentImageIndex[mascotaId] = fotos.length - 1; // Ir a la última si estamos en la primera
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
        backgroundColor: Colors.green[200],
        title: Text('Página Principal'),
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
           // Carrusel de mascotas en adopción
          if (mascotasEnAdopcion.isNotEmpty)
            SizedBox(
              height: 200,
              child: CarouselSlider.builder(
                itemCount: mascotasEnAdopcion.length,
                itemBuilder: (BuildContext context, int index, int realIndex) {
                  return _cardAdopciones(mascotasEnAdopcion[index]);
                },
                options: CarouselOptions(
                  height: 200,
                  viewportFraction: 0.8,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  autoPlayInterval: Duration(seconds: 3),
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  autoPlayCurve: Curves.fastOutSlowIn,
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
                  return Center(child: Text('No se encontraron mascotas.'));
                } else {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      int crossAxisCount = 1; // 1 card por defecto para pantallas pequeñas

                      if (constraints.maxWidth > 1150) {
                        crossAxisCount = 3; // 3 cards en pantallas anchas
                      } else if (constraints.maxWidth > 750) {
                        crossAxisCount = 2; // 2 cards en pantallas medianas
                      }

                      return GridView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 20.0, // Espacio horizontal entre los cards
                          mainAxisSpacing: 16.0,  // Espacio vertical entre los cards
                          childAspectRatio: 1.5,  // Mantener la relación de aspecto de los cards
                        ),
                        itemCount: _mascotasFiltradas.length,
                        itemBuilder: (context, index) {
                          final mascota = _mascotasFiltradas[index];
                          final fechaPerdida = DateTime.parse(mascota.fechaPerdida);
                          final mensajeFecha = obtenerMensajeFecha(fechaPerdida);

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
                                    if (mascota.estado == 'encontrado')
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
                                    if (mascota.estado == 'perdido')
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color.fromARGB(255, 206, 71, 71),
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                          '¡Hay una familia que busca a esta mascota!',
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    Flexible(
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
                                          Flexible(
                                            child: GestureDetector(
                                              onTap: () {
                                                mostrarModalInfoMascota(context, mascota);
                                              },
                                              child: mascota.fotos.isNotEmpty
                                                  ? _imagenesManejoErrores(mascota.fotos[_currentImageIndex[mascota.id] ?? 0])
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
                                        '${mascota.fechaPerdida}  -  ${mensajeFecha}',
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
      floatingActionButton: FutureBuilder<bool>(
        future: usuarioEstaLogeado(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(); // Placeholder mientras se carga
          }
          final bool usuarioLogeado = snapshot.data ?? false;

          return FloatingActionButton(
            onPressed: () async {
              if (usuarioLogeado) {
                final result = await Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CrearPublicacionPage(),
                ));

                if (result == true) {
                  // Refrescar la lista de mascotas si se publicó una mascota nueva
                  setState(() {
                    futureMascotas = obtenerMascotas();
                  });
                }
              } else {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => IniciarSesionPage(),
                ));
              }
            },
            child: Icon(Icons.add),
            backgroundColor: const Color.fromARGB(255, 33, 243, 121),
          );
        },
      ),
    );
  }
}
