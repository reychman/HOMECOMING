import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/login/perfil_usuario_page.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/usuario.dart';
import 'package:http/http.dart' as http;

class EditarPublicacionPage extends StatefulWidget {
  final Map<String, dynamic> publicacion;
  final String estado; // Nuevo parámetro para el estado de la publicación

  EditarPublicacionPage({required this.publicacion, required this.estado});

  @override
  _EditarPublicacionPageState createState() => _EditarPublicacionPageState();
}

class _EditarPublicacionPageState extends State<EditarPublicacionPage> {
  final _formKeyStep1 = GlobalKey<FormState>();
  final _formKeyStep2 = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _razaController = TextEditingController();
  TextEditingController _fechaPerdidaController = TextEditingController();
  TextEditingController _lugarPerdidaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  String _especie = 'Seleccione una especie';
  String _sexo = 'Seleccione el sexo';
  String usuarioId = '';
  LatLng? _selectedLocation;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();

    // Inicializa los controladores de texto con los valores de la publicación
    _nombreController.text = widget.publicacion['nombre'] ?? '';
    _razaController.text = widget.publicacion['raza'] ?? '';
    _descripcionController.text = widget.publicacion['descripcion'] ?? '';

    // Inicializa las variables de Dropdown
    _especie = widget.publicacion['especie'] ?? 'Seleccione una especie';
    _sexo = widget.publicacion['sexo'] ?? 'Seleccione el sexo';
    // Solo cargar estos campos si el estado es "perdido" o "encontrado"
    if (widget.publicacion['estado'] == 'perdido' || widget.publicacion['estado'] == 'encontrado') {
      _fechaPerdidaController.text = widget.publicacion['fecha_perdida'] ?? '';
      _lugarPerdidaController.text = widget.publicacion['lugar_perdida'] ?? '';
    }
    // Inicializa la ubicación seleccionada, si está disponible
    if (widget.publicacion['latitud'] != null && widget.publicacion['longitud'] != null) {
      _selectedLocation = LatLng(
        double.parse(widget.publicacion['latitud']),
        double.parse(widget.publicacion['longitud']),
      );
    }
  }

  Future<void> _editarPublicacion() async {
    if (_formKeyStep1.currentState!.validate() && _formKeyStep2.currentState!.validate()) {
      if (_selectedLocation == null) {
        _showSnackbar('Por favor seleccione una ubicación en el mapa');
        return;
      }

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/gestionar_publicaciones.php'),
        );

        request.fields['accion'] = 'actualizarPublicacion';
        request.fields['id'] = widget.publicacion['id'].toString();
        request.fields['nombre'] = _nombreController.text.toUpperCase();
        request.fields['especie'] = _especie;
        request.fields['raza'] = _razaController.text;
        request.fields['sexo'] = _sexo;
        request.fields['descripcion'] = _descripcionController.text.toUpperCase();
        request.fields['latitud'] = _selectedLocation!.latitude.toString();
        request.fields['longitud'] = _selectedLocation!.longitude.toString();

        // Solo envía los campos opcionales si el estado no es 'adopcion'
        if (widget.publicacion['estado'] == 'perdido' || widget.publicacion['estado'] == 'encontrado') {
          request.fields['fecha_perdida'] = _fechaPerdidaController.text;
          request.fields['lugar_perdida'] = _lugarPerdidaController.text;
        }

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          print('Response body: ${response.body}');
          try {
            final jsonResponse = json.decode(response.body);
            if (jsonResponse['success']) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Datos de la mascota actualizados con éxito'),
                  duration: Duration(seconds: 2),
                ),
              );

              await Future.delayed(Duration(seconds: 1));
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => PerfilUsuario(),
                ),
              );
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


  Future<void> _selectDate(BuildContext context) async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (selectedDate != null) {
      setState(() {
        _fechaPerdidaController.text = selectedDate.toIso8601String().split('T')[0];
      });
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

  Widget _buildStep1() {
    return Form(
      key: _formKeyStep1,
      child: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          TextFormField(
            controller: _nombreController,
            decoration: InputDecoration(labelText: 'Nombre de la Mascota'),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Por favor ingrese un nombre';
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
          TextFormField(
            controller: _razaController,
            decoration: InputDecoration(labelText: 'Raza'),
            validator: (value) {
              if (value!.isEmpty) {
                return 'Por favor ingrese la raza';
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
          // Mostrar el botón para seleccionar la fecha solo si el estado no es 'adopcion'
          if (widget.estado != 'adopcion' && widget.estado != 'pendiente' ) 
            ElevatedButton(
              onPressed: () => _selectDate(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                side: BorderSide(color: Colors.grey),
              ),
              child: Text(
                _fechaPerdidaController.text.isEmpty
                    ? 'Seleccione la fecha de pérdida'
                    : 'Fecha seleccionada: ${_fechaPerdidaController.text}',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          // Mostrar el campo lugar de pérdida solo si el estado no es 'adopcion'
          if (widget.estado != 'adopcion' && widget.estado != 'pendiente' ) 
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
            onPressed: _previousStep,
            child: Text('Anterior'),
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

  Widget _buildStep3() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: GoogleMap(
            onMapCreated: (GoogleMapController controller) {},
            // Si _selectedLocation tiene un valor, usa esa ubicación, si no usa una predeterminada.
            initialCameraPosition: CameraPosition(
              target: _selectedLocation ?? LatLng(-17.3935, -66.1570), // Usa la ubicación guardada o predeterminada
              zoom: 12.0,
            ),
            onTap: (LatLng latLng) {
              setState(() {
                _selectedLocation = latLng;
              });
            },
            // Si hay una ubicación seleccionada, muestra un marcador en esa ubicación.
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
        ElevatedButton(
          onPressed: _previousStep,
          child: Text('Anterior'),
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _editarPublicacion,
          child: Text('Guardar cambios'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments;
    final Usuario usuario = arguments is Usuario ? arguments : Usuario.vacio();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Publicación',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green[200],
      ),
      drawer: MenuWidget(usuario: usuario),
      backgroundColor: Colors.green[50],
      body: IndexedStack(
        index: _currentIndex,
        children: [
          _buildStep1(),
          _buildStep2(),
          _buildStep3(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
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
            icon: Icon(Icons.map),
            label: 'Paso 3',
          ),
        ],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
