import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CrearPublicacionPage extends StatefulWidget {
  @override
  _CrearPublicacionPageState createState() => _CrearPublicacionPageState();
}

class _CrearPublicacionPageState extends State<CrearPublicacionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _especieController = TextEditingController();
  final TextEditingController _razaController = TextEditingController();
  final TextEditingController _sexoController = TextEditingController();
  final TextEditingController _fechaPerdidaController = TextEditingController();
  final TextEditingController _lugarPerdidaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  final TextEditingController _fotoController = TextEditingController();
  String usuarioId = '';

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      usuarioId = prefs.getString('usuario_id') ?? '';
    });
  }

  Future<void> _enviarDatos() async {
    if (_formKey.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/agregar_mascota.php'),
        body: {
          'nombre': _nombreController.text,
          'especie': _especieController.text,
          'raza': _razaController.text,
          'sexo': _sexoController.text,
          'fecha_perdida': _fechaPerdidaController.text,
          'lugar_perdida': _lugarPerdidaController.text,
          'descripcion': _descripcionController.text,
          'foto': _fotoController.text,
          'usuario_id': usuarioId,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Mascota registrada con éxito')));
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al registrar la mascota')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al conectar con el servidor')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registrar Mascota Perdida'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese el nombre de la mascota';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _especieController,
                decoration: InputDecoration(labelText: 'Especie (gato/perro)'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese la especie de la mascota';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _razaController,
                decoration: InputDecoration(labelText: 'Raza'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese la raza de la mascota';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _sexoController,
                decoration: InputDecoration(labelText: 'Sexo (hembra/macho)'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese el sexo de la mascota';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fechaPerdidaController,
                decoration: InputDecoration(labelText: 'Fecha de pérdida (YYYY-MM-DD)'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese la fecha de pérdida';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _lugarPerdidaController,
                decoration: InputDecoration(labelText: 'Lugar de pérdida'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese el lugar de pérdida';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descripcionController,
                decoration: InputDecoration(labelText: 'Descripción'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese una descripción';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fotoController,
                decoration: InputDecoration(labelText: 'URL de la foto'),
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Por favor ingrese la URL de la foto';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _enviarDatos,
                child: Text('Registrar Mascota'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
