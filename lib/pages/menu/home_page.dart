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
  List<Mascota> _mascotas = []; // Lista de mascotas completa
  List<Mascota> _mascotasFiltradas = []; // Lista filtrada para mostrar
  TextEditingController _searchController = TextEditingController();

  // Mapa para manejar el índice actual de imagen para cada mascota
  Map<int, int> _currentImageIndex = {};

  @override
  void initState() {
    super.initState();
    futureMascotas = obtenerMascotas();
    _searchController.addListener(_onSearchChanged); // Añadir listener al controlador
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
    final response = await http.get(Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/mascotas.php'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      List<Mascota> mascotas = jsonResponse.map((data) => Mascota.fromJson(data)).toList();
      setState(() {
        _mascotas = mascotas;
        _mascotasFiltradas = mascotas;
        // Inicializamos el índice de la imagen actual para cada mascota
        for (var mascota in mascotas) {
          _currentImageIndex[mascota.id] = 0;
        }
      });
      return mascotas;
    } else {
      throw Exception('Error al cargar las mascotas');
    }
  }

  void _onSearchChanged() {
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

  // Función para mostrar el modal con la información de la mascota


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
                labelText: 'Buscar mascota o propietario',
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
                  return Center(child: Text('No se encontraron mascotas.'));
                } else {
                  return ListView.builder(
                    itemCount: _mascotasFiltradas.length,
                    itemBuilder: (context, index) {
                      final mascota = _mascotasFiltradas[index];
                      final fechaPerdida = DateTime.parse(mascota.fechaPerdida);
                      final mensajeFecha = obtenerMensajeFecha(fechaPerdida);

                      return GestureDetector(
                        onTap: () {
                          mostrarModalInfoMascota(context, mascota); // Mostrar modal en lugar de navegar
                        },
                        child: Center(
                          child: Card(
                            margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.9, // Ocupa el 90% del ancho de la pantalla
                              constraints: BoxConstraints(maxWidth: 500), // Limitar el ancho máximo a 500
                              padding: EdgeInsets.all(10.0),
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
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Botón de imagen anterior
                                          IconButton(
                                            icon: Icon(Icons.arrow_back),
                                            iconSize: 30.0, // Tamaño del ícono de la flecha
                                            onPressed: () {
                                              if (mascota.fotos.isNotEmpty) {
                                                _cambiarImagen(mascota.id, mascota.fotos, false);
                                              }
                                            },
                                          ),
                                          Expanded(
                                            child: GestureDetector(
                                              onTap: () {
                                                mostrarModalInfoMascota(context, mascota); // Mostrar modal cuando se hace clic en la imagen
                                              },
                                              child: mascota.fotos.isNotEmpty
                                                  ? Image.asset(
                                                      'assets/imagenes/fotos_mascotas/${mascota.fotos[_currentImageIndex[mascota.id]!]}',
                                                      width: 400,
                                                      height: 250, // Ajustar la altura de la imagen
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Icon(Icons.error, size: 100, color: Colors.red);
                                                      },
                                                    )
                                                  : Icon(Icons.pets, size: 200, color: Colors.grey),
                                            ),
                                          ),
                                          // Botón de imagen siguiente
                                          IconButton(
                                            icon: Icon(Icons.arrow_forward),
                                            iconSize: 30.0, // Tamaño del ícono de la flecha
                                            onPressed: () {
                                              if (mascota.fotos.isNotEmpty) {
                                                _cambiarImagen(mascota.id, mascota.fotos, true);
                                              }
                                            },
                                          ),
                                        ],
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
                                ],
                              ),
                            ),
                          ),
                        ),
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
            onPressed: () {
              if (usuarioLogeado) {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => CrearPublicacionPage(),
                ));
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
