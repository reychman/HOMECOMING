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

class _ListaHorizontalMascotasAdopcionState extends State<ListaHorizontalMascotasAdopcion> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late AnimationController _animationController;
  // ignore: unused_field
  late Animation<double> _scaleAnimation;
  int _currentIndex = 0;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    
    // Configuración de la animación principal
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Texto animado con fade in
        TweenAnimationBuilder(
          duration: const Duration(seconds: 1),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Opacity(
              opacity: value,
              child: Padding(
                padding: EdgeInsets.only(
                  left: 16.0 + (32.0 * (1 - value)),
                  right: 16.0,
                  top: 16.0,
                  bottom: 16.0,
                ),
                child: Text(
                  'Los refugios están llenos de mascotas maravillosas esperando un hogar lleno de amor. Al adoptar, no solo salvas una vida, sino que también ayudas a reducir el abandono animal. ¡Abre tu corazón y tu hogar!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          },
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 300,
              child: ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: widget.mascotas.length,
                itemBuilder: (context, index) {
                  final mascota = widget.mascotas[index];
                  return MouseRegion(
                    onEnter: (_) => _onHover(index),
                    onExit: (_) => _onHoverExit(),
                    child: AnimatedScale(
                      scale: _hoveredIndex == index ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        transform: Matrix4.identity()
                          ..translate(
                            0.0,
                            _hoveredIndex == index ? -10.0 : 0.0,
                          ),
                        child: GestureDetector(
                          onTap: () {
                            // Animación de pulsación al tocar
                            _animationController.forward().then((_) {
                              _animationController.reverse();
                              mostrarModalInfoMascota(context, mascota);
                            });
                          },
                          child: Container(
                            width: 200,
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Hero(
                                    tag: 'mascota-${mascota.id}',
                                    child: CarouselSlider(
                                      options: CarouselOptions(
                                        aspectRatio: 1,
                                        viewportFraction: 1,
                                        enlargeCenterPage: false,
                                        autoPlay: mascota.fotos.length > 1,
                                        autoPlayInterval: Duration(seconds: 3),
                                        autoPlayAnimationDuration: Duration(milliseconds: 800),
                                        autoPlayCurve: Curves.fastOutSlowIn,
                                      ),
                                      items: mascota.fotos.map((foto) {
                                        return ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            foto,
                                            fit: BoxFit.cover,
                                            width: double.infinity,
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ),
                                AnimatedContainer(
                                  duration: Duration(milliseconds: 200),
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _hoveredIndex == index 
                                        ? Colors.grey.shade100 
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mascota.nombre.isNotEmpty ? mascota.nombre : 'Sin Nombre',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
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
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Botones de navegación con animación de fade
            Positioned(
              left: 0,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: _currentIndex > 0 ? 1.0 : 0.0,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios, size: 20, color: Colors.black54),
                  onPressed: () {
                    if (_currentIndex > 0) {
                      _currentIndex--;
                      _scrollController.animateTo(
                        _currentIndex * 216.0,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: AnimatedOpacity(
                duration: Duration(milliseconds: 200),
                opacity: _currentIndex < widget.mascotas.length - 1 ? 1.0 : 0.0,
                child: IconButton(
                  icon: Icon(Icons.arrow_forward_ios, size: 20, color: Colors.black54),
                  onPressed: () {
                    if (_currentIndex < widget.mascotas.length - 1) {
                      _currentIndex++;
                      _scrollController.animateTo(
                        _currentIndex * 216.0,
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onHover(int index) {
    setState(() {
      _hoveredIndex = index;
    });
  }

  void _onHoverExit() {
    setState(() {
      _hoveredIndex = null;
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    _animationController.dispose();
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