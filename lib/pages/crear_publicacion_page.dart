import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/menu/home_page.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/usuario.dart';
import 'package:http/http.dart' as http;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:file_picker/file_picker.dart';
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
  //final TextEditingController _razaController = TextEditingController();
  final TextEditingController _fechaPerdidaController = TextEditingController();
  final TextEditingController _lugarPerdidaController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  // Lista de razas de perros y gatos
  final List<String> _razasPerro = [
    'Beagle',
    'Boxer',
    'Bulldog',
    'Caniche',
    'Chihuahua',
    'Dálmata',
    'Golden Retriever',
    'Gran Danés',
    'Labrador',
    'Pastor Alemán',
    'Pitbull',
    'Pomerania',
    'Rottweiler',
    'Schnauzer',
    'Shih Tzu',
    'Terrier Escocés',
    'Yorkshire Terrier',
    'Otro'
  ];
  final List<String> _razasGato = [
    'Angora',
    'Azul Ruso',
    'Bengalí',
    'Bombay',
    'Británico de pelo corto',
    'Himalayo',
    'Maine Coon',
    'Persa',
    'Ragdoll',
    'Siamés',
    'Siberiano',
    'Sphynx',
    'Otro'
  ];
  List<String> _razas = []; // Lista vacía de razas a mostrar
  List<Uint8List> _selectedImages = []; // Para almacenar varias imágenes
  String _especie = 'Seleccione una especie';
  String? _selectedRaza;
  String _sexo = 'Seleccione el sexo';
  String usuarioId = '';
  LatLng? _selectedLocation;
  bool _mostrarComboBoxEstado = false;
  String? _estadoSeleccionado;
  int _currentIndex = 0;
  String? tipoUsuario;

  @override
  void initState() {
    super.initState();
    _infoUsuarioVerificarTipo();
  }

  Future<void> _infoUsuarioVerificarTipo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('usuario_id');
    if (userId != null) {
      setState(() {
        usuarioId = userId.toString();
      });
      
      // Obtener el usuario completo
      Usuario? usuario = await obtenerUsuarioPorId(userId);
      if (usuario != null) {
        setState(() {
          _mostrarComboBoxEstado = usuario.tipoUsuario == 'administrador' || usuario.tipoUsuario == 'refugio';
          tipoUsuario = usuario.tipoUsuario;  // Almacena el tipo de usuario
        });
      }
    } else {
      _showSnackbar('Error: No se encontró el ID del usuario');
    }
  }
  Future<Usuario?> obtenerUsuarioPorId(int userId) async {
  final url = Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/get_usuario_actual.php?user_id=$userId');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final userData = json.decode(response.body);
      if (userData.containsKey('error')) {
        print('Error: ${userData['error']}');
        return null;
      }
      return Usuario.fromJson(userData);
    } else {
      print('Error al obtener usuario: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Error al obtener usuario: $e');
    return null;
  }
}

  Future<void> _enviarDatos() async {
    if (_formKeyStep1.currentState!.validate() && _formKeyStep2.currentState!.validate()) {
      if (_selectedImages.isEmpty) {
        _showSnackbar('Por favor seleccione una o más imágenes');
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

        // Agregar todas las imágenes seleccionadas
        for (int i = 0; i < _selectedImages.length; i++) {
          request.files.add(http.MultipartFile.fromBytes(
            'fotos[]', // Enviar como array
            _selectedImages[i],
            filename: 'foto_$i.png',
          ));
        }

        request.fields['nombre'] = _nombreController.text.toUpperCase();
        request.fields['especie'] = _especie;
        request.fields['raza'] = _selectedRaza ?? '';
        request.fields['sexo'] = _sexo;
        request.fields['estado'] = _estadoSeleccionado ?? 'perdido';  // Valor predeterminado a 'perdido' si no se selecciona
        request.fields['tipo_usuario'] = tipoUsuario ?? 'propietario';  // Valor predeterminado si no se obtiene
        request.fields['fecha_perdida'] = _fechaPerdidaController.text;
        request.fields['lugar_perdida'] = _lugarPerdidaController.text.toUpperCase();
        request.fields['descripcion'] = _descripcionController.text.toUpperCase();
        request.fields['latitud'] = _selectedLocation!.latitude.toString();
        request.fields['longitud'] = _selectedLocation!.longitude.toString();
        request.fields['usuario_id'] = usuarioId;

        final streamedResponse = await request.send();
        final response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          // Imprime el contenido de la respuesta para ver si es JSON o HTML
          print('Response body: ${response.body}');
          
          try {
            final jsonResponse = json.decode(response.body);
            
            if (jsonResponse['success']) {
              _showSnackbar('Mascota registrada con éxito');
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => PaginaPrincipal())
              );
            } else {
              _showSnackbar('Error: ${jsonResponse['message']}');
            }
          } catch (jsonError) {
            _showSnackbar('Error al procesar la respuesta: $jsonError');
            print('Error de JSON: $jsonError');
          }
        } else {
          _showSnackbar('Error al conectar con el servidor');
        }
      } catch (e) {
        _showSnackbar('Ocurrió un error: $e');
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

  Future<void> _pickImages() async {
    final ImagePicker _picker = ImagePicker();
    
    // El usuario selecciona múltiples imágenes
    List<XFile>? pickedFiles = await _picker.pickMultiImage();

      for (XFile file in pickedFiles) {
        Uint8List? imageBytes;

        // Recorte para Android
        if (!kIsWeb && Platform.isAndroid) {
          CroppedFile? croppedFile = await ImageCropper().cropImage(
            sourcePath: file.path,
            uiSettings: [
              AndroidUiSettings(
                toolbarTitle: 'Recortar Imagen',
                toolbarColor: Colors.green,
                toolbarWidgetColor: Colors.white,
                lockAspectRatio: true, // Bloquear la relación de aspecto fija
                aspectRatioPresets: [
                  CropAspectRatioPreset.square,  // Forzar la relación de aspecto cuadrada
                ],
                hideBottomControls: true,  // Ocultar controles inferiores para evitar cambios
              ),
            ],
          );

          if (croppedFile != null) {
            imageBytes = await croppedFile.readAsBytes();
          }
          else {
            // El usuario canceló el recorte
            continue; // Saltar esta iteración y no hacer nada
          }
        }

        // Recorte para Web usando Cropper.js
        if (kIsWeb) {
          if (!mounted) return;  // Verificar si el widget sigue montado antes de usar el contexto

          CroppedFile? croppedFile = await ImageCropper().cropImage(
            sourcePath: file.path,
            uiSettings: [
              WebUiSettings(
                context: context,  // Usamos el context, pero solo si el widget sigue montado
                size: CropperSize(width: 400, height: 400), // Tamaño fijo
                dragMode: WebDragMode.crop, // Modo de arrastre solo para recortar
                initialAspectRatio: 1.0,  // Relación de aspecto fija (cuadrada) para Web
                zoomable: true,  // Habilitar zoom
                rotatable: true,  // Habilitar rotación
                cropBoxResizable: false,
                translations: WebTranslations(
                  title: 'Recortar Imagen',  // Personaliza el título aquí
                  cropButton: 'Recortar',   // Cambia el texto del botón de recorte
                  cancelButton: 'Cancelar', // Cambia el texto del botón de cancelar
                  rotateLeftTooltip: 'Girar a la izquierda',  // Tooltip para girar a la izquierda
                  rotateRightTooltip: 'Girar a la derecha',  // Tooltip para girar a la derecha
                ),
              ),
            ],
          );
          if (croppedFile != null) {
            imageBytes = await croppedFile.readAsBytes();
          }
          else {
            // si el usuario cancela el recorte saltar esa imagen
            continue; 
          }
        }

        // Para plataformas donde no se recorta, usar la imagen original
        if (!kIsWeb && imageBytes == null) {
          imageBytes = await file.readAsBytes();
        }

        // Verificar si el widget sigue montado antes de usar el contexto
        if (!mounted) return;

        // Almacenar las imágenes recortadas o las originales
        setState(() {
          _selectedImages.add(imageBytes!);
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
  if (_currentIndex == 0) {
    if (_formKeyStep1.currentState!.validate()) {
      if (!_mostrarComboBoxEstado) {
        _estadoSeleccionado = 'perdido'; // Si es un propietario, forzamos el estado a 'perdido'
      }
      setState(() {
        _currentIndex += 1; // Avanza al paso 2
      });
    }
  } else if (_currentIndex == 1) {
    if (_formKeyStep2.currentState!.validate()) {
      setState(() {
        _currentIndex += 1; // Avanza al paso 3
      });
    }
  } else if (_currentIndex == 2) {
    // Aquí puedes simplemente avanzar a step 4 sin necesidad de validación
    setState(() {
      _currentIndex += 1; // Avanza al paso 4
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
  final arguments = ModalRoute.of(context)!.settings.arguments;
  final Usuario usuario = arguments is Usuario ? arguments : Usuario.vacio();
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Registrar Mascota',
        style: TextStyle(color: Colors.white), // Color del texto del AppBar
      ),
      backgroundColor: Colors.green[200], // Color de fondo del AppBar
    ),
    drawer: MenuWidget(usuario: usuario),
    backgroundColor: Colors.green[50],
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
        if (_currentIndex == 0 && !_formKeyStep1.currentState!.validate()) {
          // Si estamos en el paso 1 y no se ha validado, no cambiar
          return;
        }
        if (_currentIndex == 1 && !_formKeyStep2.currentState!.validate()) {
          // Si estamos en el paso 2 y no se ha validado, no cambiar
          return;
        }
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
            items: ['Seleccione una especie', 'gato', 'perro']
                .map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (newValue) {
              setState(() {
                _especie = newValue!;
                // Actualiza las razas dependiendo de la especie seleccionada
                if (_especie == 'gato') {
                  _razas = _razasGato;
                } else if (_especie == 'perro') {
                  _razas = _razasPerro;
                } else {
                  _razas = [];
                }
                // Reinicia el valor de la raza seleccionada
                _selectedRaza = null;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty || value == 'Seleccione una especie') {
                return 'Por favor seleccione la especie de la mascota';
              }
              return null;
            },
          ),
          // Dropdown para seleccionar la raza
          DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: 'Raza'),
            value: _selectedRaza,
            onChanged: (_especie == 'gato' || _especie == 'perro')
                ? (value) {
                    setState(() {
                      _selectedRaza = value;
                    });
                  }
                : null, // Deshabilita el campo si no hay una especie seleccionada
            items: _razas.map((raza) {
              return DropdownMenuItem(
                value: raza,
                child: Text(raza),
              );
            }).toList(),
            validator: (value) {
              if (_especie != 'gato' && _especie != 'perro') {
                return null; // No valida si el campo está deshabilitado
              }
              if (value == null || value.isEmpty) {
                return 'Por favor seleccione una raza';
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
          if (_mostrarComboBoxEstado)
          DropdownButtonFormField<String>(
            value: _estadoSeleccionado,
            decoration: InputDecoration(labelText: 'Estado de la mascota'),
            items: ['Perdido', 'adopcion'].map((String value) {
              return DropdownMenuItem<String>(
                value: value.toLowerCase(),
                child: Text(value),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                // guardamos el valor seleccionado
                _estadoSeleccionado = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor seleccione el estado de la mascota';
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
  // Si el estado es "adopcion", no se deben mostrar los campos de pérdida
  bool mostrarCamposPerdida = _estadoSeleccionado != 'adopcion';

  return Form(
    key: _formKeyStep2,
    child: ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Mostrar campos de pérdida solo si no es adopcion
        if (mostrarCamposPerdida) ...[
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
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese la fecha de pérdida';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _lugarPerdidaController,
            decoration: InputDecoration(labelText: 'Lugar de pérdida'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el lugar de pérdida';
              }
              return null;
            },
          ),
          SizedBox(height: 16),
        ],
        // Campo de descripción (siempre visible)
        TextFormField(
          controller: _descripcionController,
          decoration: InputDecoration(labelText: 'Descripción'),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor ingrese una descripción';
            }
            return null;
          },
        ),
        SizedBox(height: 20.0),
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
  return SingleChildScrollView(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _pickImages,
          child: Text('Seleccionar Imágenes'),
        ),
        SizedBox(height: 20),
        if (_selectedImages.isNotEmpty)
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _selectedImages.map((image) {
              return Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.memory(
                      image,
                      width: 150,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    top: 5,
                    right: 5,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedImages.remove(image); // Remover imagen
                        });
                      },
                      child: Icon(Icons.close, color: Colors.red),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            // Verificar que haya imágenes seleccionadas antes de avanzar
            if (_selectedImages.isNotEmpty) {
              _nextStep();
            } else {
              // Mostrar un mensaje si no se han seleccionado imágenes
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Debes seleccionar al menos una imagen.')),
              );
            }
          },
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
        const SizedBox(height: 10.0), // Add some spacing between buttons
        ElevatedButton(
          onPressed: _previousStep,
          child: Text('Anterior'),
        ),
      ],
    );
  }
}
