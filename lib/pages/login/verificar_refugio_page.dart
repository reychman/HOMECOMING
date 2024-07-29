import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class VerificarRefugioPage extends StatefulWidget {
  final int usuarioId;

  VerificarRefugioPage({required this.usuarioId});

  @override
  _VerificarRefugioPageState createState() => _VerificarRefugioPageState();
}

class _VerificarRefugioPageState extends State<VerificarRefugioPage> {
  final TextEditingController nombreController = TextEditingController();
  final TextEditingController ubicacionController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  String mensaje = "";

  Future<void> enviarDatos() async {
    final response = await http.post(
      Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/crear_refugio.php'),
      body: {
        "nombre": nombreController.text,
        "ubicacion": ubicacionController.text,
        "telefono": telefonoController.text,
        "usuario_id": widget.usuarioId.toString(),
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    try {
      var data = json.decode(response.body);

      if (data.containsKey('error')) {
        setState(() {
          mensaje = data['error'];
        });
      } else {
        setState(() {
          mensaje = "Los datos se enviaron correctamente para su verificación";
        });

        await Future.delayed(Duration(seconds: 7));
        setState(() {
          mensaje = "";
        });

        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error decoding JSON: $e');
      setState(() {
        mensaje = 'Error en el servidor. Intente nuevamente más tarde.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Verificar Refugio'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre del Refugio',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: ubicacionController,
                decoration: InputDecoration(
                  labelText: 'Ubicación',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 10.0),
              TextField(
                controller: telefonoController,
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: enviarDatos,
                child: Text('Enviar Datos'),
              ),
              SizedBox(height: 10.0),
              Text(
                mensaje,
                style: TextStyle(fontSize: 20.0, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
