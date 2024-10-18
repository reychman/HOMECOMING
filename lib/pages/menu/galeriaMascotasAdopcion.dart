import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:homecoming/pages/mascota.dart';
import 'package:homecoming/pages/menu/modals.dart';

class ListaHorizontalMascotasAdopcion extends StatefulWidget {
  final List<Mascota> mascotas;

  const ListaHorizontalMascotasAdopcion({Key? key, required this.mascotas}) : super(key: key);

  @override
  _ListaHorizontalMascotasAdopcionState createState() => _ListaHorizontalMascotasAdopcionState();
}

class _ListaHorizontalMascotasAdopcionState extends State<ListaHorizontalMascotasAdopcion> {
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Los refugios están llenos de mascotas maravillosas esperando un hogar lleno de amor. Al adoptar, no solo salvas una vida, sino que también ayudas a reducir el abandono animal. ¡Abre tu corazón y tu hogar!',
            style: TextStyle(
              fontSize: 16, // Ajusta el tamaño de la fuente aquí
              fontWeight: FontWeight.bold,
              // Otros estilos que desees
            ),
          ),
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 300, // Ajusta esta altura según tus necesidades
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: widget.mascotas.length,
                itemBuilder: (context, index) {
                  final mascota = widget.mascotas[index];
                  return GestureDetector(
                    onTap: () => mostrarModalInfoMascota(context, mascota),
                    child: Container(
                      width: 200, // Ajusta este ancho según tus necesidades
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: CarouselSlider(
                              options: CarouselOptions(
                                aspectRatio: 1,
                                viewportFraction: 1,
                                enlargeCenterPage: false,
                                autoPlay: mascota.fotos.length > 1, // Solo autoPlay si hay más de una foto
                                autoPlayInterval: Duration(seconds: 3),
                                autoPlayAnimationDuration: Duration(milliseconds: 800),
                                autoPlayCurve: Curves.fastOutSlowIn,
                              ),
                              items: mascota.fotos.map((foto) {
                                return Image.network(
                                  foto,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                );
                              }).toList(),
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            mascota.nombre.isNotEmpty ? mascota.nombre : 'Sin Nombre',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 4),
                          Text(
                            mascota.descripcion,
                            style: TextStyle(fontSize: 14),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Positioned(
              left: 0,
              child: IconButton(
                icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.black54),
                onPressed: () {
                  if (_currentIndex > 0) {
                    _currentIndex--;
                    _scrollController.animateTo(
                      _currentIndex * 216.0, // 200 (ancho) + 16 (margen)
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
            Positioned(
              right: 0,
              child: IconButton(
                icon: Icon(Icons.arrow_forward_ios, size: 20, color: Colors.black54),
                onPressed: () {
                  if (_currentIndex < widget.mascotas.length - 1) {
                    _currentIndex++;
                    _scrollController.animateTo(
                      _currentIndex * 216.0, // 200 (ancho) + 16 (margen)
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    int index = (_scrollController.offset / 216.0).round();
    if (index != _currentIndex) {
      setState(() {
        _currentIndex = index;
      });
    }
  }
}
