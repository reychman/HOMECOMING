import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart'; // Asegúrate de tener este import

class CrearPublicacionPage extends StatefulWidget {
  @override
  _CrearPublicacionPageState createState() => _CrearPublicacionPageState();
}

class _CrearPublicacionPageState extends State<CrearPublicacionPage> {
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _razaController = TextEditingController();
  final TextEditingController _fechaPerdidaController = TextEditingController();
  final TextEditingController _lugarPerdidaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  Uint8List? _selectedImage;
  String _especie = 'Seleccione una especie';
  String _sexo = 'Seleccione el sexo';
  String usuarioId = '';
  LatLng? _selectedLocation;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      int? userId = prefs.getInt('usuario_id'); // Usa getInt para recuperar como int
      usuarioId = userId != null ? userId.toString() : ''; // Convierte a String si no es null
    });

    if (usuarioId.isEmpty) {
      _showSnackbar('Error: No se encontró el ID del usuario');
    }
  }

  Future<void> _enviarDatos() async {
    if (_formKeyStep1.currentState!.validate() && _formKeyStep2.currentState!.validate()) {
      if (_selectedImage == null) {
        _showSnackbar('Por favor seleccione una imagen');
        return;
      }

      if (_selectedLocation == null) {
        _showSnackbar('Por favor seleccione la ubicación en el mapa');
        return;
      }

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/publicar_mascota.php'),
        );

        request.files.add(http.MultipartFile.fromBytes(
          'foto',
          _selectedImage!,
          filename: 'foto.png',
        ));

        request.fields['nombre'] = _nombreController.text;
        request.fields['especie'] = _especie;
        request.fields['raza'] = _razaController.text;
        request.fields['sexo'] = _sexo;
        request.fields['fecha_perdida'] = _fechaPerdidaController.text;
        request.fields['lugar_perdida'] = _lugarPerdidaController.text;
        request.fields['descripcion'] = _descripcionController.text;
        request.fields['latitud'] = _selectedLocation!.latitude.toString();
        request.fields['longitud'] = _selectedLocation!.longitude.toString();
        request.fields['usuario_id'] = usuarioId;

        final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        // Imprimir el cuerpo de la respuesta para debug
        print('Response body: ${response.body}');

        try {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['success']) {
            _showSnackbar('Mascota registrada con éxito');
            Navigator.of(context).pop();
          } else {
            _showSnackbar('Error: ${jsonResponse['message']}');
          }
        } catch (e) {
          _showSnackbar('Error al decodificar JSON: $e');
          print('Error decoding JSON: $e');
        }
      } else {
        _showSnackbar('Error al conectar con el servidor');
        print('Error response status: ${response.statusCode}');
        print('Error response body: ${response.body}');
      }
    } catch (e) {
      _showSnackbar('Ocurrió un error: $e');
      print('Error sending data: $e');
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

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null) {
      setState(() {
        _selectedImage = result.files.first.bytes;
      });
    }
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

  void _nextStep() {
    if (_currentIndex < 3) {
      setState(() {
        _currentIndex++;
      });
    }
  }

  void _previousStep() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Registrar Mascota Perdida',
        style: TextStyle(color: Colors.white), // Color del texto del AppBar
      ),
      backgroundColor: Colors.green[200], // Color de fondo del AppBar
    ),
    body: IndexedStack(
      index: _currentIndex,
      children: [
        _buildStep1(),
        _buildStep2(),
        _buildStep3(),
        _buildStep4(),
      ],
    ),
    bottomNavigationBar: BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      backgroundColor: Colors.white, // Color de fondo del BottomNavigationBar
      selectedItemColor: Colors.green, // Color de ítem seleccionado
      unselectedItemColor: Colors.grey, // Color de ítems no seleccionados
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          label: 'Paso 1',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          label: 'Paso 2',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.image),
          label: 'Paso 3',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.map),
          label: 'Paso 4',
        ),
      ],
      type: BottomNavigationBarType.fixed, // Asegura que el color del fondo y los ítems se apliquen correctamente
    ),
  );
}

  Widget _buildStep1() {
    return Form(
      key: _formKeyStep1,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
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
            items: ['Seleccione el sexo', 'hembra', 'macho'].map((String value) {
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
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: _nextStep,
            child: Text('Siguiente'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return Form(
      key: _formKeyStep2,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
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
          const SizedBox(height: 20.0),
          ElevatedButton(
            onPressed: _nextStep,
            child: Text('Siguiente'),
          ),
          ElevatedButton(
            onPressed: _previousStep,
            child: Text('Anterior'),
          ),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _pickImage,
          child: Text('Seleccionar Imagen'),
        ),
        if (_selectedImage != null) Image.memory(_selectedImage!),
        ElevatedButton(
          onPressed: _nextStep,
          child: Text('Siguiente'),
        ),
        ElevatedButton(
          onPressed: _previousStep,
          child: Text('Anterior'),
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: GoogleMap(
            onMapCreated: (GoogleMapController controller) {},
            initialCameraPosition: CameraPosition(
              target: LatLng(-17.3935, -66.1570), // Coordenadas de Cochabamba, Bolivia
              zoom: 12.0,
            ),
            onTap: (LatLng latLng) {
              setState(() {
                _selectedLocation = latLng;
              });
            },
            markers: _selectedLocation != null
                ? {
                    Marker(
                      markerId: MarkerId('selectedLocation'),
                      position: _selectedLocation!,
                    )
                  }
                : {},
          ),
        ),
        const SizedBox(height: 20.0),
        ElevatedButton(
          onPressed: _enviarDatos,
          child: Text('Registrar Mascota'),
        ),
        ElevatedButton(
          onPressed: _previousStep,
          child: Text('Anterior'),
        ),
      ],
    );
  }
}
