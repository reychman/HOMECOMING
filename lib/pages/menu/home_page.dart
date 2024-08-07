import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/login/iniciar_sesion_page.dart';
import 'package:homecoming/pages/menu/crear_publicacion_page.dart';
import 'package:homecoming/pages/menu/mascota.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/menu/info_mascotas_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PaginaPrincipal extends StatefulWidget {
  @override
  _PaginaPrincipalState createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  late Future<List<Mascota>> futureMascotas;

  @override
  void initState() {
    super.initState();
    futureMascotas = obtenerMascotas();
  }

  Future<List<Mascota>> obtenerMascotas() async {
    final response = await http.get(Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/mascotas.php'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Mascota.fromJson(data)).toList();
    } else {
      throw Exception('Error al cargar las mascotas');
    }
  }

  Future<Map<String, String>> obtenerDatosUsuario() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String nombre = prefs.getString('nombre') ?? '';
    String tipoUsuario = prefs.getString('tipo_usuario') ?? '';
    return {'nombre': nombre, 'tipo_usuario': tipoUsuario};
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
    } else if (diferenciaDias <= 7) {
      return 'Hace semanas';
    } else {
      return 'Hace más de una semana';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Página Principal'),
      ),
      drawer: MenuWidget(),
      body: FutureBuilder<List<Mascota>>(
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
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final mascota = snapshot.data![index];
                final fechaPerdida = DateTime.parse(mascota.fechaPerdida);
                final mensajeFecha = obtenerMensajeFecha(fechaPerdida);

                return Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => InfoMascotasPage(mascota: mascota),
                      ));
                    },
                    child: Card(
                      margin: EdgeInsets.all(10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (mascota.estado == 'encontrado')
                            Container(
                              width: 400,
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
                              width: 400,
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              mascota.foto.isNotEmpty
                                  ? Image.asset(
                                      'assets/imagenes/fotos_mascotas/${mascota.foto}',
                                      width: 400,
                                      height: 400,
                                      fit: BoxFit.cover,
                                    )
                                  : Icon(Icons.pets, size: 200),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  mascota.nombre,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Text(
                                  mensajeFecha,
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                child: Text(
                                  mascota.lugarPerdida,
                                  style: TextStyle(color: Colors.grey, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FutureBuilder<Map<String, String>>(
        future: obtenerDatosUsuario(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(); // Placeholder while loading
          }
          final userData = snapshot.data!;
          final bool usuarioLogeado = userData['nombre']!.isNotEmpty;

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
            backgroundColor: Colors.blue,
          );
        },
      ),
    );
  }
}
