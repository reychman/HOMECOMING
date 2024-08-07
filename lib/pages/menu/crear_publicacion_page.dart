import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart'; // Para el formato de la fecha

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

      // Primero sube la imagen
      final imageUploadRequest = http.MultipartRequest(
        'POST', Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/upload_image.php')
      );
      imageUploadRequest.files.add(await http.MultipartFile.fromPath('foto', _selectedImage!.path));
      imageUploadRequest.fields['usuario_id'] = usuarioId;

      final streamedResponse = await imageUploadRequest.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          final imageName = jsonResponse['file_name'];

          // Después guarda la información de la mascota
          final response = await http.post(
            Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/agregar_mascota.php'),
            body: {
              'nombre': _nombreController.text,
              'especie': _especie,
              'raza': _razaController.text,
              'sexo': _sexo,
              'fecha_perdida': _fechaPerdidaController.text,
              'lugar_perdida': _lugarPerdidaController.text,
              'descripcion': _descripcionController.text,
              'foto': imageName,
              'usuario_id': usuarioId,
            },
          );

          if (response.statusCode == 200) {
            final jsonResponse = json.decode(response.body);
            if (jsonResponse['success']) {
              _showSnackbar('Mascota registrada con éxito');
              Navigator.of(context).pop();
            } else {
              _showSnackbar('Error al registrar la mascota');
            }
          } else {
            _showSnackbar('Error al conectar con el servidor');
          }
        } else {
          _showSnackbar('Error al subir la imagen');
        }
      } else {
        _showSnackbar('Error al conectar con el servidor');
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
