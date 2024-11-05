import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/login/iniciar_sesion_page.dart';
import 'package:homecoming/pages/crear_publicacion_page.dart';
import 'package:homecoming/pages/mascota.dart';
import 'package:homecoming/pages/menu/galeria_mascotas_adopcion.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/menu/modals.dart';
import 'package:homecoming/pages/usuario_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homecoming/pages/usuario.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PaginaPrincipal extends StatefulWidget {
  @override
  _PaginaPrincipalState createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  late Future<List<Mascota>> futureMascotas;
  List<Mascota> mascotasEnAdopcion = [];
  List<Mascota> _mascotas = []; // Lista de mascotas completa
  List<Mascota> _mascotasFiltradas = []; // Lista filtrada para mostrar
  List<Mascota> _mascotasEnAdopcionFiltradas = []; // Lista filtrada para mostrar
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

    // Modifica la URL para pasar la IP del servidor como parámetro GET
    final response = await http.get(Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/mascotas.php?ip_servidor=$serverIP'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      List<Mascota> todasLasMascotas = jsonResponse.map((data) => Mascota.fromJson(data)).toList();

      setState(() {
        _mascotas = todasLasMascotas; // Guardar todas las mascotas
        mascotasEnAdopcion = todasLasMascotas.where((m) => m.estado == 'adopcion' || m.estado == 'pendiente').toList(); //filtramos para que se muestren las mascotas en adopcion o con adopcion pendiente
        _mascotasFiltradas = todasLasMascotas.where((m) => m.estado == 'perdido').toList();
        _mascotasEnAdopcionFiltradas = todasLasMascotas.where((m) => m.estado == 'adopcion' || m.estado == 'pendiente').toList();
      });

      for (var mascota in todasLasMascotas) {
        _currentImageIndex[mascota.id] = 0;
      }

      return todasLasMascotas;
    } else {
      throw Exception('Error al cargar las mascotas: ${response.statusCode}');
    }
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

  DateTime? _parseFecha(String fechaString) {
    try {
      return DateTime.parse(fechaString);
    } catch (e) {
      print('Error al parsear la fecha: $e');
      return null; // Devolver null si no se pudo parsear
    }
  }

  Future<void> _marcarPublicacionIndebida(int idMascota) async {
    // Primero mostrar diálogo de confirmación
    bool confirmar = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar acción'),
          content: Text('¿Estás seguro de que deseas marcar esta publicación como indebida?'),
          actions: [
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text('Confirmar'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false;

    if (!confirmar) return;

    try {
      final response = await http.post(
        Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/gestionar_publicaciones.php'),
        body: {
          'accion': 'marcarComoIndebido',
          'id': idMascota.toString(),
        },
        // headers: {'Content-Type': 'application/x-www-form-urlencoded'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          obtenerMascotas();
          _mostrarMensajeExito(context);
          // Actualizar la lista de mascotas después de marcar como indebida
          // Si estás usando un provider para las mascotas, actualízalo aquí
        } else {
          _mostrarError(context, 'Error: ${responseData['error']}');
        }
      } else {
        _mostrarError(context, 'Error en la solicitud al servidor');
      }
    } catch (e) {
      print('Error en la conexión: $e');
      _mostrarError(context, 'Error de conexión: $e');
    }
  }
  void _mostrarMensajeExito(BuildContext context) {
    final snackBar = SnackBar(
      content: Text('La publicación se marcó como indebida exitosamente.'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void _mostrarError(BuildContext context, String mensaje) {
    final snackBar = SnackBar(
      content: Text(mensaje),
      backgroundColor: Colors.red,
      duration: Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
  
  void _buscarMascota() {
    String searchQuery = _searchController.text.toLowerCase();

    setState(() {
      if (searchQuery.isEmpty) {
        // Si el campo de búsqueda está vacío, mostrar todas las mascotas con estado 'perdido', 'adopcion' o 'pendiente'
        _mascotasFiltradas = _mascotas.where((m) => m.estado == 'perdido').toList();
        _mascotasEnAdopcionFiltradas = _mascotas.where((m) => m.estado == 'adopcion' || m.estado == 'pendiente').toList();
      } else {
        // Si hay una búsqueda activa, filtrar solo las mascotas con estado 'perdido', 'adopcion' o 'pendiente' que coincidan con el nombre
        _mascotasFiltradas = _mascotas.where((mascota) {
          final nombreMascota = mascota.nombre.toLowerCase();
          return nombreMascota.contains(searchQuery) && mascota.estado == 'perdido';
        }).toList();
        _mascotasEnAdopcionFiltradas = _mascotas.where((mascota) {
          final nombreMascota = mascota.nombre.toLowerCase();
          return nombreMascota.contains(searchQuery) && (mascota.estado == 'adopcion' || mascota.estado == 'pendiente');
        }).toList();
      }
    });
  }
Widget _buildMascotaCard(Mascota mascota, bool esAdministrador, String mensajeFecha) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: EdgeInsets.all(10.0),
        constraints: BoxConstraints(
          maxHeight: 400, // Aumentamos la altura máxima
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Banner de estado (encontrado/perdido)
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
                child: Stack(
                  children: [
                    Center(
                      child: Text(
                        '¡Hay una familia que busca a esta mascota!',
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (esAdministrador)
                      Positioned(
                        top: -10,
                        right: -5,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.white),
                          onPressed: () => _marcarPublicacionIndebida(mascota.id),
                        ),
                      ),
                  ],
                ),
              ),

            // Carrusel de imágenes
            Expanded(
              flex: 3, // Damos más espacio al carrusel
              child: GestureDetector(
                onTap: () => mostrarModalInfoMascota(context, mascota),
                child: Container(
                  width: double.infinity,
                  child: mascota.fotos.isNotEmpty
                    ? CarouselSlider(
                        options: CarouselOptions(
                          height: 250, // Altura fija para el carrusel
                          aspectRatio: 1,
                          viewportFraction: 1.0,
                          enlargeCenterPage: false,
                          autoPlay: mascota.fotos.length > 1, // Solo auto-reproducir si hay más de una imagen
                          autoPlayInterval: Duration(seconds: 3),
                          autoPlayAnimationDuration: Duration(milliseconds: 800),
                          autoPlayCurve: Curves.fastOutSlowIn,
                          enableInfiniteScroll: mascota.fotos.length > 1,
                        ),
                        items: mascota.fotos.map((foto) {
                          return Container(
                            width: double.infinity,
                            margin: EdgeInsets.symmetric(horizontal: 4.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                foto,
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return Center(child: Icon(Icons.error));
                                },
                                loadingBuilder: (context, child, loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                          : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      )
                    : Icon(Icons.pets, size: 200, color: Colors.grey),
                ),
              ),
            ),

            // Información de la mascota
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(
                      mascota.nombre.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold, 
                        fontSize: 18
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Fecha perdida: ${mascota.fechaPerdida}\n$mensajeFecha',
                      style: TextStyle(
                        color: Color.fromARGB(255, 53, 53, 53), 
                        fontSize: 14
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Se perdió en: ${mascota.lugarPerdida}',
                      style: TextStyle(
                        color: const Color.fromARGB(255, 53, 53, 53), 
                        fontSize: 14
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
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
    backgroundColor: Colors.green[50],
    body: SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _buscarMascota(),
              decoration: InputDecoration(
                labelText: 'Buscar mascota',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          if (_mascotasFiltradas.isEmpty && _mascotasEnAdopcionFiltradas.isEmpty && _searchController.text.isNotEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 60,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No se encontraron mascotas con ese nombre',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            Column(
              children: [
                if (mascotasEnAdopcion.isNotEmpty || _mascotasEnAdopcionFiltradas.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Mascotas que están en adopción',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ) ??
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                if (_mascotasEnAdopcionFiltradas.isNotEmpty)
                  ListaHorizontalMascotasAdopcion(mascotas: _mascotasEnAdopcionFiltradas),
                if (_mascotasFiltradas.isNotEmpty || _mascotasEnAdopcionFiltradas.isNotEmpty)
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Mascotas que están perdidas',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ) ??
                              TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Detrás de cada mascota perdida hay un corazón roto. ¡Ayúdanos a reunir a las familias!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
                            return Center(child: Text('No se encontraron mascotas.'));
                          } else {
                            return LayoutBuilder(
                              builder: (context, constraints) {
                                int crossAxisCount;
                                if (constraints.maxWidth > 1200) {
                                  crossAxisCount = 4;
                                } else if (constraints.maxWidth > 900) {
                                  crossAxisCount = 3;
                                } else if (constraints.maxWidth > 600) {
                                  crossAxisCount = 2;
                                } else {
                                  crossAxisCount = 1;
                                }
                                return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.85, // Ajustamos para dar más espacio vertical
      ),
      itemCount: _mascotasFiltradas.length,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final mascota = _mascotasFiltradas[index];
        final fechaPerdida = _parseFecha(mascota.fechaPerdida);
        final mensajeFecha = fechaPerdida != null
            ? obtenerMensajeFecha(fechaPerdida)
            : 'Fecha no disponible';

        return Consumer<UsuarioProvider>(
          builder: (context, usuarioProvider, _) {
            final usuario = usuarioProvider.usuario ?? Usuario.vacio();
            final bool esAdministrador = usuario.tipoUsuario == 'administrador';
            return _buildMascotaCard(mascota, esAdministrador, mensajeFecha);
          },
        );
      },
    );
                              },
                            );
                          }
                        },
                      ),
                    ],
                  ),
              ],
            ),
        ],
      ),
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
            backgroundColor: Colors.green[200],
            child: Icon(Icons.add),
          );
        },
      ),
    );
  }
}
