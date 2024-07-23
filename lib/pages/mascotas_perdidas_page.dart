import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:http/http.dart' as http;

class MascotasPerdidas extends StatefulWidget {
  @override
  _EstadoPaginaMascotasPerdidas createState() =>
      _EstadoPaginaMascotasPerdidas();
}

class _EstadoPaginaMascotasPerdidas extends State<MascotasPerdidas> {
  List<dynamic> mascotasPerdidas = [];

  @override
  void initState() {
    super.initState();
    buscarMascotasPerdidas();
  }

  Future<void> buscarMascotasPerdidas() async {
    try {
      final response = await http.get(Uri.parse(
          'http://$serverIP/homecomingbd_v2/mascotas_perdidas.php'));

      print('Response body: ${response.body}'); // Para depuración

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse is List) {
          setState(() {
            mascotasPerdidas = jsonResponse;
          });
        } else {
          print('Unexpected JSON response format: $jsonResponse');
        }
      } else {
        // Manejar error de servidor
        print('Failed to load lost pets, status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      // Manejar error de conexión
      print('Failed to load lost pets: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mascotas Perdidas'),
      ),
      body: mascotasPerdidas.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: mascotasPerdidas.length,
              itemBuilder: (context, index) {
                final pet = mascotasPerdidas[index];
                return ListTile(
                  title: Text(pet['detalles_adicionales']),
                  subtitle:
                      Text('${pet['lugar_perdida']} - ${pet['fecha_perdida']}'),//los valores deben coincidir con los de la base de datos
                );
              },
            ),
    );
  }
}