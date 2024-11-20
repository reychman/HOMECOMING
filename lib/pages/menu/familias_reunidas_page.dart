import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/mascota.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/menu/modals.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:homecoming/pages/usuario.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:animate_do/animate_do.dart';

class FamiliasReunidasPage extends StatefulWidget {
  @override
  _FamiliasReunidasPageState createState() => _FamiliasReunidasPageState();
}

class _FamiliasReunidasPageState extends State<FamiliasReunidasPage> {
  late Future<List<Mascota>> futureMascotas;
  List<Mascota> _mascotas = [];
  List<Mascota> _mascotasFiltradas = [];
  TextEditingController _searchController = TextEditingController();
  ScrollController _scrollController = ScrollController();
  bool _showScrollToTop = false;
  int _totalReuniones = 0; // Added the _totalReuniones field
  double _finalesFelicesPercentaje = 0.0; // Add this line
  int _totalMascotas = 0; // Add this line
  String _selectedDateRange = 'Todos'; // Default value
  final List<String> _dateRanges = ['Todos', 'Últimos 7 días', 'Últimos 30 días', 'Últimos 90 días'];
  void _filtrarPorFecha(String range) {
    setState(() {
      _selectedDateRange = range;
      
      if (range == 'Todos') {
        _mascotasFiltradas = _mascotas.where((m) => m.estado == 'encontrado').toList();
        return;
      }

      int days;
      switch (range) {
        case 'Últimos 7 días':
          days = 7;
          break;
        case 'Últimos 30 días':
          days = 30;
          break;
        case 'Últimos 90 días':
          days = 90;
          break;
        default:
          days = 0;
      }

      DateTime cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      _mascotasFiltradas = _mascotas.where((mascota) {
        if (mascota.estado != 'encontrado' || mascota.fechaEncontrado == 'Desconocido') {
          return false;
        }

        try {
          DateTime fechaEncontrado = DateTime.parse(mascota.fechaEncontrado);
          return fechaEncontrado.isAfter(cutoffDate);
        } catch (e) {
          return false;
        }
      }).toList();
    });
  }


  @override
  void initState() {
    super.initState();
    futureMascotas = obtenerMascotas();
    _searchController.addListener(_buscarMascota);
    _scrollController.addListener(_scrollListener);
  }

  void _scrollListener() {
    if (_scrollController.offset >= 400) {
      setState(() => _showScrollToTop = true);
    } else {
      setState(() => _showScrollToTop = false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

Future<List<Mascota>> obtenerMascotas() async {
    try {
      final response = await http.get(
        Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/mascotas.php?ip_servidor=$serverIP')
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        List<Mascota> mascotas = jsonResponse.map((data) => Mascota.fromJson(data)).toList();
        List<Mascota> mascotasEncontradas = mascotas.where((m) => m.estado == 'encontrado').toList();

        setState(() {
          _mascotas = mascotas;
          _mascotasFiltradas = mascotasEncontradas;
          _totalReuniones = mascotasEncontradas.length;
          _totalMascotas = mascotas.length; // Store the total number of pets
          _finalesFelicesPercentaje = (_totalReuniones / _totalMascotas * 100);// Calculate the percentage correctly
        });
        return mascotasEncontradas;
      } else {
        throw Exception('Error al cargar las mascotas encontradas');
      }
    } catch (e) {
      rethrow;
    }
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: GridView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.85,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Container(),
          );
        },
      ),
    );
  }

  Widget _buildStatsCard() {
    return FadeInDown(
      duration: Duration(milliseconds: 500),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.pets,
                    value: _totalReuniones.toString(),
                    label: 'Mascotas\nReunidas',
                  ),
                  _buildStatItem(
                    icon: Icons.favorite,
                    value: '${_finalesFelicesPercentaje.toStringAsFixed(2)}%',
                    label: 'Finales\nFelices',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

Widget _buildStatItem({
  required IconData icon,
  required String value,
  required String label,
}) {
  return Column(
    children: [
      Icon(icon, size: 40, color: Colors.green),
      SizedBox(height: 8),
      Text(
        value,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.green[800],
        ),
      ),
      Text(
        label,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
        textAlign: TextAlign.center,
      ),
    ],
  );
}

  Widget _buildSearchBar() {
    return FadeInDown(
      delay: Duration(milliseconds: 200),
      child: Container(
        margin: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Buscar mascota...',
            prefixIcon: Icon(Icons.search, color: Colors.green),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear, color: Colors.green),
                    onPressed: () {
                      _searchController.clear();
                      _buscarMascota();
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMascotaCard(Mascota mascota, BuildContext context) {
    return FadeInUp(
      duration: Duration(milliseconds: 500),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green, Colors.green.shade300],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.celebration, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    '¡Reunidos!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => mostrarModalInfoMascota(context, mascota),
                child: Stack(
                  children: [
                    if (mascota.fotos.isEmpty)
                      Center(child: Icon(Icons.pets, size: 200, color: Colors.grey))
                    else if (mascota.fotos.length == 1)
                      _buildSingleImage(mascota.fotos[0])
                    else
                      _buildCarousel(mascota.fotos),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Color.fromARGB(255, 187, 240, 177).withOpacity(0.7),
                              Color.fromARGB(0, 221, 240, 209),
                            ],
                          ),
                        ),
                        padding: EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mascota.nombre.toUpperCase(),
                              style: TextStyle(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              mascota.lugarPerdida,
                              style: TextStyle(
                                color: const Color.fromARGB(255, 0, 0, 0).withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildSingleImage(String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 40, color: Colors.red),
                SizedBox(height: 8),
                Text(
                  'Error al cargar la imagen',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildCarousel(List<String> images) {
    return CarouselSlider(
      options: CarouselOptions(
        height: double.infinity,
        viewportFraction: 1.0,
        enableInfiniteScroll: true,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 3),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayCurve: Curves.fastOutSlowIn,
      ),
      items: images.map((imageUrl) {
        return _buildSingleImage(imageUrl);
      }).toList(),
    );
  }

  void _buscarMascota() {
    String searchQuery = _searchController.text.toLowerCase();
    List<Mascota> mascotasFiltradas = _mascotas.where((mascota) {
      final nombreMascota = mascota.nombre.toLowerCase();
      final lugarPerdida = mascota.lugarPerdida.toLowerCase();
      return (nombreMascota.contains(searchQuery) ||
          lugarPerdida.contains(searchQuery)) &&
          mascota.estado == 'encontrado';
    }).toList();

    // Apply date filter if not 'Todos'
    if (_selectedDateRange != 'Todos') {
      int days;
      switch (_selectedDateRange) {
        case 'Últimos 7 días':
          days = 7;
          break;
        case 'Últimos 30 días':
          days = 30;
          break;
        case 'Últimos 90 días':
          days = 90;
          break;
        default:
          days = 0;
      }

      DateTime cutoffDate = DateTime.now().subtract(Duration(days: days));
      mascotasFiltradas = mascotasFiltradas.where((mascota) {
        DateTime fechaEncontrado  = DateTime.parse(mascota.fechaEncontrado );
        return fechaEncontrado.isAfter(cutoffDate);
      }).toList();
    }

    setState(() {
      _mascotasFiltradas = mascotasFiltradas;
    });
  }
  Widget _buildDateFilter() {
    return FadeInDown(
      delay: Duration(milliseconds: 300),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonFormField<String>(
          value: _selectedDateRange,
          decoration: InputDecoration(
            prefixIcon: Icon(Icons.calendar_today, color: Colors.green),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items: _dateRanges.map((String range) {
            return DropdownMenuItem<String>(
              value: range,
              child: Text(range),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              _filtrarPorFecha(newValue);
            }
          },
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
        title: Text(
          'Familias Reunidas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
        backgroundColor: Colors.green[200],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                futureMascotas = obtenerMascotas();
              });
            },
            tooltip: 'Actualizar lista',
          ),
        ],
      ),
      drawer: MenuWidget(usuario: usuario),
      backgroundColor: Colors.green[50],
      floatingActionButton: _showScrollToTop
          ? FloatingActionButton(
              child: Icon(Icons.arrow_upward),
              backgroundColor: Colors.green,
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                );
              },
              tooltip: 'Volver arriba',
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            futureMascotas = obtenerMascotas();
          });
        },
        child: LayoutBuilder(
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

            return SingleChildScrollView(
              controller: _scrollController,
              physics: AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  // Barra de búsqueda
                  _buildSearchBar(),
                  // Tarjeta de estadísticas
                  _buildStatsCard(),
                  // Sección de encabezado
                  Container(
                    margin: EdgeInsets.all(16),
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.green[100]!, Colors.green[50]!],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.1),
                          spreadRadius: 2,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.pets,
                          size: 50,
                          color: Colors.green[800],
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Un reencuentro que alegra el alma",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.green[800],
                            letterSpacing: 0.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "Aquí celebramos las historias de aquellas mascotas que, gracias al esfuerzo y la compasión de muchas personas, lograron volver a casa.",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            "Si ves una mascota perdida, ¡no dudes en actuar! Tú podrías ser la razón de otro final feliz.",
                            style: TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: Colors.green[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildDateFilter(), // Add this line
                  // Grid de mascotas
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FutureBuilder<List<Mascota>>(
                      future: futureMascotas,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return _buildLoadingShimmer();
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 60,
                                  color: Colors.red,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Error al cargar las mascotas',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.red,
                                  ),
                                ),
                                SizedBox(height: 8),
                                  ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      futureMascotas = obtenerMascotas();
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green, // Use backgroundColor instead of primary
                                  ),
                                  child: Text('Reintentar'),
                                ),
                              ],
                            ),
                          );
                        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pets,
                                  size: 60,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Aún no hay mascotas reunidas con su familia.',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  '¡Sé parte del cambio y ayuda a otra mascota a regresar a casa!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                    fontStyle: FontStyle.italic,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          );
                        }

                        if (_mascotasFiltradas.isEmpty) {
                          return Center(
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
                          );
                        }

                        return GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16.0,
                            mainAxisSpacing: 16.0,
                            childAspectRatio: 0.99,
                          ),
                          itemCount: _mascotasFiltradas.length,
                          itemBuilder: (context, index) {
                            return _buildMascotaCard(_mascotasFiltradas[index], context);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}