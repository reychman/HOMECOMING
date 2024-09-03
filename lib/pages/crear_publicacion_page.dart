import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';


class CrearPublicacionPage extends StatefulWidget {
  @override
  _CrearPublicacionPageState createState() => _CrearPublicacionPageState();
}

class _CrearPublicacionPageState extends State<CrearPublicacionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _razaController = TextEditingController();
  final TextEditingController _fechaPerdidaController = TextEditingController();
  final TextEditingController _lugarPerdidaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  File? _selectedImage;
  String _especie = 'Seleccione una especie';
  String _sexo = 'Seleccione el sexo';
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
    if (_selectedImage == null) {
      _showSnackbar('Por favor seleccione una imagen');
      return;
    }

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/publicar_mascota.php'),
      );

      request.files.add(await http.MultipartFile.fromPath('foto', _selectedImage!.path));

      request.fields['nombre'] = _nombreController.text;
      request.fields['especie'] = _especie;
      request.fields['raza'] = _razaController.text;
      request.fields['sexo'] = _sexo;
      request.fields['fecha_perdida'] = _fechaPerdidaController.text;
      request.fields['lugar_perdida'] = _lugarPerdidaController.text;
      request.fields['descripcion'] = _descripcionController.text;
      request.fields['usuario_id'] = usuarioId;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          _showSnackbar('Mascota registrada con éxito');
          Navigator.of(context).pop();
        } else {
          _showSnackbar('Error: ${jsonResponse['message']}');
        }
      } else {
        _showSnackbar('Error al conectar con el servidor');
        print('Error: ${response.statusCode} - ${response.reasonPhrase}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      _showSnackbar('Ocurrió un error: $e');
      print('Exception: $e');
    }
  }
}


  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 4),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != DateTime.now()) {
      setState(() {
        _fechaPerdidaController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
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
              DropdownButtonFormField<String>(
                value: _especie,
                decoration: InputDecoration(labelText: 'Especie'),
                items: ['Seleccione una especie', 'gato', 'perro'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _especie = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty || value == 'Seleccione una especie') {
                    return 'Por favor seleccione la especie de la mascota';
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
              DropdownButtonFormField<String>(
                value: _sexo,
                decoration: InputDecoration(labelText: 'Sexo'),
                items: ['Seleccione el sexo', 'macho', 'hembra'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _sexo = newValue!;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty || value == 'Seleccione el sexo') {
                    return 'Por favor seleccione el sexo de la mascota';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _fechaPerdidaController,
                decoration: InputDecoration(
                  labelText: 'Fecha de pérdida (YYYY-MM-DD)',
                  suffixIcon: IconButton(
                    icon: Icon(Icons.calendar_today),
                    onPressed: () => _selectDate(context),
                  ),
                ),
                readOnly: true,
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
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: TextEditingController(text: _selectedImage != null ? _selectedImage!.path : ''),
                      decoration: InputDecoration(labelText: 'URL de la foto'),
                      readOnly: true,
                      validator: (value) {
                        if (_selectedImage == null) {
                          return 'Por favor seleccione una imagen';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.photo),
                    onPressed: _pickImage,
                  ),
                ],
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
