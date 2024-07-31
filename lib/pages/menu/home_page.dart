import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/login/iniciar_sesion_page.dart';
import 'package:homecoming/pages/menu/crear_publicacion_page.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Mascota {
  final int id;
  final String nombre;
  final String especie;
  final String raza;
  final String sexo;
  final String fechaPerdida;
  final String lugarPerdida;
  final String estado;
  final String descripcion;
  final String foto;

  Mascota({
    required this.id,
    required this.nombre,
    required this.especie,
    required this.raza,
    required this.sexo,
    required this.fechaPerdida,
    required this.lugarPerdida,
    required this.estado,
    required this.descripcion,
    required this.foto,
  });

  factory Mascota.fromJson(Map<String, dynamic> json) {
    return Mascota(
      id: json['id'],
      nombre: json['nombre'],
      especie: json['especie'],
      raza: json['raza'],
      sexo: json['sexo'],
      fechaPerdida: json['fecha_perdida'],
      lugarPerdida: json['lugar_perdida'],
      estado: json['estado'],
      descripcion: json['descripcion'],
      foto: json['foto'],
    );
  }
}

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
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    leading: mascota.foto.isNotEmpty
                        ? Image.network(mascota.foto, width: 50, height: 50, fit: BoxFit.cover)
                        : Icon(Icons.pets, size: 50),
                    title: Text(mascota.nombre),
                    subtitle: Text('${mascota.especie} - ${mascota.raza} - ${mascota.sexo}'),
                    trailing: Text(mascota.estado),
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
