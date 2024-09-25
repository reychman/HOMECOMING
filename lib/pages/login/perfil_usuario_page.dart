import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/editar_perfil_page.dart';
import 'package:homecoming/pages/login/EditarPublicacionPage.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/usuario.dart';
import 'package:homecoming/pages/usuario_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';

class PerfilUsuario extends StatefulWidget {
  const PerfilUsuario({Key? key}) : super(key: key);

  @override
  _PerfilUsuarioState createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  Uint8List? _imageBytes;
  Usuario? _usuario;
  List<dynamic> _misPublicaciones = []; // Lista de publicaciones del usuario

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _fetchUserPublications(); // Cargar publicaciones del usuario
  }
  Future<void> _mostrarModalCambiarFotos(BuildContext context, int publicacionId) async {
    List<Uint8List> nuevasFotos = [];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Cambiar Fotos de la Mascota'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Selecciona nuevas fotos para la mascota'),
                    ElevatedButton(
                      onPressed: () async {
                        final ImagePicker _picker = ImagePicker();
                        final List<XFile>? pickedFiles = await _picker.pickMultiImage();
                        if (pickedFiles != null) {
                          for (XFile file in pickedFiles) {
                            Uint8List? croppedBytes = await _cropImage(context, file.path);
                            if (croppedBytes != null) {
                              setState(() {
                                nuevasFotos.add(croppedBytes);
                              });
                            }
                          }
                        }
                      },
                      child: Text('Seleccionar y Recortar Fotos'),
                    ),
                    SizedBox(height: 10),
                    if (nuevasFotos.isNotEmpty)
                      SizedBox(
                        height: 100, // Limita la altura del contenedor de las imágenes
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: nuevasFotos.map((foto) {
                              return Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Image.memory(foto, height: 100, width: 100, fit: BoxFit.contain),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (nuevasFotos.isNotEmpty) {
                      Navigator.of(context).pop(nuevasFotos);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se seleccionaron fotos.')));
                    }
                  },
                  child: Text('Actualizar Fotos'),
                ),
              ],
            );
          },
        );
      },
    ).then((value) async {
      if (value != null && value is List<Uint8List>) {
        await _agregarFotos(context, publicacionId, value);
      }
    });
  }
  Future<void> _mostrarModalReemplazarFoto(BuildContext context, int publicacionId) async {
  Uint8List? nuevaFoto;

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Reemplazar Foto'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    final ImagePicker _picker = ImagePicker();
                    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      Uint8List? croppedBytes = await _cropImage(context, pickedFile.path);
                      if (croppedBytes != null) {
                        setState(() {
                          nuevaFoto = croppedBytes;
                        });
                      }
                    }
                  },
                  child: Text('Seleccionar y Recortar Foto'),
                ),
                SizedBox(height: 10),
                if (nuevaFoto != null)
                  Image.memory(nuevaFoto!, height: 100, width: 100, fit: BoxFit.contain),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nuevaFoto != null) {
                    Navigator.of(context).pop();
                    await reemplazarFoto(context, publicacionId, nuevaFoto!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No se seleccionó una nueva foto.')));
                  }
                },
                child: Text('Reemplazar Foto'),
              ),
            ],
          );
        },
      );
    },
  );
}
Future<void> _mostrarModalEliminarFoto(BuildContext context, int publicacionId) async {
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Eliminar Foto'),
        content: Text('¿Estás seguro de que deseas eliminar esta foto?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await eliminarFoto(context, publicacionId);
            },
            child: Text('Eliminar Foto'),
          ),
        ],
      );
    },
  );
}


  Future<Uint8List?> _cropImage(BuildContext context, String imagePath) async {
    CroppedFile? croppedFile;

    // Configuración para Web y Android/iOS
    croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1),  // Relación de aspecto cuadrada
      uiSettings: [
        if (!kIsWeb)
          AndroidUiSettings(
            toolbarTitle: 'Recortar Imagen',
            toolbarColor: Colors.green,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.square,
            lockAspectRatio: true,
          ),
        if (kIsWeb)
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

    // Si se ha recortado correctamente la imagen, devolver los bytes
    if (croppedFile != null) {
      return await croppedFile.readAsBytes();
    }

    // Si el usuario cancela el recorte o falla, devolver null
    return null;
  }

  Future<void> _agregarFotos(BuildContext context, int publicacionId, List<Uint8List> nuevasFotos) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/gestionar_publicaciones.php'),
    );

    request.fields['accion'] = 'agregarFotos';
    request.fields['publicacion_id'] = publicacionId.toString();

    for (int i = 0; i < nuevasFotos.length; i++) {
      request.files.add(http.MultipartFile.fromBytes(
        'fotos_mascotas[]',
        nuevasFotos[i],
        filename: 'foto_${i}.jpg',  // Nombrar las fotos
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      
      // Asegurarnos de que el jsonResponse esté bien formado antes de acceder a sus claves
      final jsonResponse = jsonDecode(responseData);

      if (jsonResponse != null && jsonResponse is Map && jsonResponse.containsKey('success') && jsonResponse['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Fotos actualizadas con éxito.')));
        _fetchUserPublications(); // Asegúrate de que esta función esté definida en tu clase
      } else {
        // Manejar el error si 'success' es null o falso
        String errorMessage = jsonResponse != null && jsonResponse.containsKey('error')
          ? jsonResponse['error']
          : 'Error desconocido al actualizar las fotos.';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $errorMessage')));
      }
    } catch (e) {
      // Manejar los errores en la solicitud HTTP
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al subir fotos: $e')));
    }
  }
  Future<void> eliminarFoto(BuildContext context, int fotoId) async {
    final response = await http.post(
      Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/gestionar_publicaciones.php'),
      body: {
        'accion': 'eliminarFoto',
        'foto_id': fotoId.toString(),
      },
    );

    final jsonResponse = jsonDecode(response.body);

    if (jsonResponse['success']) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Foto eliminada con éxito'),
        duration: Duration(seconds: 3),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error: ${jsonResponse['error']}'),
        duration: Duration(seconds: 3),
      ));
    }
  }

  Future<void> reemplazarFoto(BuildContext context, int fotoId, Uint8List nuevaFoto) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/gestionar_publicaciones.php'),
    );

    request.fields['accion'] = 'reemplazarFoto';
    request.fields['foto_id'] = fotoId.toString();

    request.files.add(http.MultipartFile.fromBytes(
      'nueva_foto',
      nuevaFoto,
      filename: 'foto_reemplazo.jpg',
      contentType: MediaType('image', 'jpeg'),
    ));

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);

      if (jsonResponse['success']) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Foto reemplazada con éxito'),
          duration: Duration(seconds: 3),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${jsonResponse['error']}'),
          duration: Duration(seconds: 3),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error al reemplazar foto: $e'),
        duration: Duration(seconds: 3),
      ));
    }
  }

  Future<void> _loadUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? usuario_id = prefs.getInt('usuario_id');

  if (usuario_id != null) {
    Usuario? usuarioLogeado = await UsuarioProvider.getUsuarioActual(usuario_id);
    setState(() {
      _usuario = usuarioLogeado;
    });
    
    // Llamar a fetchUserPublications una vez cargado el usuario
    _fetchUserPublications();
  } else {
    print('No se encontró un usuario_id en SharedPreferences');
  }
}

Future<void> _uploadImage(Uint8List imageBytes) async {
  if (_usuario == null || _usuario!.id == null) return;

  final request = http.MultipartRequest(
    'POST',
    Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/upload_image.php'),
  );

  // Enviar los campos requeridos por el servidor
  request.fields['accion'] = 'subirFotoPerfil'; // Asegúrate de que esto coincida con lo esperado en el servidor
  request.fields['id'] = _usuario!.id.toString(); // Enviar el ID del usuario

  // Añadir la imagen
  request.files.add(http.MultipartFile.fromBytes(
    'foto_perfil', // Nombre del campo en la tabla 'usuarios'
    imageBytes,
    filename: 'foto_perfil_${_usuario!.id}.jpg', // Asigna un nombre único a la imagen
    contentType: MediaType('image', 'jpeg'),
  ));

  try {
    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final jsonResponse = jsonDecode(responseData);

    if (jsonResponse['success']) {
      // Actualiza la foto de perfil en la interfaz
      setState(() {
        _usuario!.fotoPortada = jsonResponse['foto_perfil'];
      });

      // Guardar la foto en SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('foto_perfil', jsonResponse['foto_perfil']);

      // Refrescar la página después de la operación
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PerfilUsuario(),
          ),
        );
    } else {
      print('Error al subir la imagen: ${jsonResponse['error']}');
    }
  } catch (e) {
    print('Error en _uploadImage: $e');
  }
}

Future<void> _reemplazarFotoPerfil() async {
  final picker = ImagePicker();
  try {
    // Seleccionar una nueva imagen desde la galería
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Recortar la imagen seleccionada
      final croppedBytes = await _cropImage(context, pickedFile.path);

      if (croppedBytes != null) {
        // Actualizar la imagen en la interfaz
        setState(() {
          _imageBytes = croppedBytes;
        });

        // Subir la nueva imagen al servidor
        await _uploadImage(croppedBytes);
      } else {
        // Si no se recortó correctamente
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se recortó la imagen.')),
        );
      }
    } else {
      // Si no se seleccionó ninguna imagen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se seleccionó ninguna imagen.')),
      );
    }
  } catch (e) {
    // Manejar errores
    print('Error al seleccionar o recortar la imagen: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al seleccionar o recortar la imagen.')),
    );
  }
}

  Future<void> _eliminarFotoPerfil() async {
    if (_usuario == null || _usuario!.id == null) return;

    final response = await http.post(
      Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/upload_image.php'),
      body: {
        'accion': 'eliminarFotoPerfil',
        'id': _usuario!.id.toString(),
      },
    );

    final jsonResponse = jsonDecode(response.body);

    if (jsonResponse['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Foto de perfil eliminada correctamente'),
          duration: Duration(seconds: 2),
        ),
      );

      // Eliminar la foto de perfil en la UI y en SharedPreferences
      setState(() {
        _usuario!.fotoPortada = null;
        _imageBytes = null;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('foto_perfil');

      // Refrescar la página después de la eliminación
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PerfilUsuario(),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      // Seleccionar imagen desde la galería
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Llamamos al método _cropImage para recortar la imagen
        final croppedBytes = await _cropImage(context, pickedFile.path);

        if (croppedBytes != null) {
          // Mostramos la imagen recortada antes de subirla
          setState(() {
            _imageBytes = croppedBytes;
          });

          // Subimos la imagen recortada al servidor
          await _uploadImage(croppedBytes);
        } else {
          // Si no se recortó correctamente la imagen
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se recortó la imagen.')),
          );
        }
      } else {
        // Si no se seleccionó ninguna imagen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se seleccionó ninguna imagen.')),
        );
      }
    } catch (e) {
      // Captura cualquier error durante la selección o recorte de la imagen
      print('Error al seleccionar o recortar la imagen: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al seleccionar o recortar la imagen.')),
      );
    }
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
    } else if (diferenciaDias == 7) {
      return 'Hace 1 semana';
    } else {
      return 'Hace más de una semana';
    }
  }
  Future<void> _updatePassword() async {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool isPasswordVisible = false; // Controla la visibilidad de la contraseña
  bool isConfirmPasswordVisible = false; // Controla la visibilidad de la contraseña de confirmación

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Actualizar Contraseña'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Nueva Contraseña',
                    suffixIcon: IconButton(
                      icon: Icon(
                        isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isPasswordVisible = !isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !isPasswordVisible,
                ),
                TextField(
                  controller: confirmPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    suffixIcon: IconButton(
                      icon: Icon(
                        isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          isConfirmPasswordVisible = !isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !isConfirmPasswordVisible,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (newPasswordController.text == confirmPasswordController.text) {
                    // Llamar a la función para actualizar la contraseña en el backend
                    await _enviarNuevaContrasena(newPasswordController.text);
                    Navigator.of(context).pop(); // Cierra el modal
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Las contraseñas no coinciden')),
                    );
                  }
                },
                child: Text('Actualizar Contraseña'),
              ),
            ],
          );
        },
      );
    },
  );
}


Future<void> _enviarNuevaContrasena(String newPassword) async {
  if (_usuario == null || _usuario!.id == null) return;

  // Línea de depuración para imprimir los datos que se están enviando
  print('Enviando id: ${_usuario!.id.toString()} y new_password: $newPassword');

  final response = await http.post(
    Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/update_password.php'),
    body: {
      'id': _usuario!.id.toString(),
      'new_password': newPassword,
    },
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Contraseña actualizada correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar la contraseña')),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error de red al actualizar la contraseña')),
    );
  }
}


  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushReplacementNamed('/home');
  }

  // Obtener las publicaciones del usuario
  Future<void> _fetchUserPublications() async {
    if (_usuario == null) return;

    // Imprimir el usuario_id antes de enviar la solicitud
    //print('Enviando usuario_id: ${_usuario!.id.toString()}');

    try {
      var response = await http.post(
        Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/gestionar_publicaciones.php'),
        body: {
          'usuario_id': _usuario!.id.toString(),
          'accion': 'obtenerPublicaciones', // Especifica la acción
        },
      );

      // Imprimir la respuesta completa del servidor
      //print('Response: ${response.body}');

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        //print('Response body: ${response.body}'); // Imprime el cuerpo de la respuesta
        print('Se estan cargando en formatato Json'); // Imprime el cuerpo de la respuesta

        // Verifica si hay un error en la respuesta
        if (jsonResponse is List) {
          setState(() {
            _misPublicaciones = jsonResponse;
          });

          // Verifica si _misPublicaciones contiene datos
          if (_misPublicaciones.isNotEmpty) {
            //print('Mis publicaciones: $_misPublicaciones'); // Verifica si la lista no está vacía
            print('Se estan cargando tus publicaciones');
          } else {
            print('No se encontraron publicaciones.');
          }
        } else {
          print('Error: ${jsonResponse['error']}');
        }
      }
    } catch (e) {
      print('Error en la solicitud: $e');
    }
  }

  Future<void> _mostrarConfirmacionCambioEstado(
    int publicacionId,
    String nuevoEstado,
    String titulo,
    String mensaje,
  ) async {
    // Mostrar una ventana emergente de confirmación
    bool confirmar = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(titulo),
          content: Text(mensaje),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancelar
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Aceptar
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );

    // Si el usuario aceptó, realiza el cambio de estado
    if (confirmar) {
      _changeEstadoMascota(publicacionId, nuevoEstado);
    }
  }
  // Cambiar el estado de la publicación (por ejemplo, de perdido a encontrado)
  Future<void> _changeEstadoMascota(int publicacionId, String nuevoEstado) async {
    var response = await http.post(
      Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/gestionar_publicaciones.php'),
      body: {
        'accion': 'actualizarEstado',
        'id': publicacionId.toString(), // El ID de la mascota
        'estado': nuevoEstado,          // El nuevo estado
      }
    );
    
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      _fetchUserPublications(); // Actualiza las publicaciones después del cambio
    } else {
      print('Error al cambiar el estado: ${response.statusCode}');
    }
  }


  Future<void> _confirmarEliminacionPublicacion(int publicacionId) async {
    // Mostrar el cuadro de diálogo de confirmación
    bool confirmar = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar Eliminación'),
          content: Text('¿Está seguro de que desea eliminar la publicación?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancelar
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirmar
              },
              child: Text('Eliminar'),
            ),
          ],
        );
      },
    );

    // Si se confirmó la eliminación
    if (confirmar) {
      var response = await http.post(
        Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/gestionar_publicaciones.php'),
        body: {
          'accion': 'eliminarPublicacion',
          'id': publicacionId.toString(),
        },
      );

      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);

        // Verifica si la eliminación fue exitosa
        if (jsonResponse['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('El registro fue eliminado con éxito.'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.green, // Color verde para éxito
            ),
          );
          _fetchUserPublications(); // Actualiza las publicaciones después de eliminar
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Hubo un error al eliminar el registro.'),
              duration: Duration(seconds: 3),
              backgroundColor: Colors.red, // Color rojo para error
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al conectar con el servidor.'),
            duration: Duration(seconds: 3),
            backgroundColor: Colors.red, // Color rojo para error
          ),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      drawer: MenuWidget(usuario: _usuario ?? Usuario.vacio()),
      body: _usuario == null
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 20),
                    PopupMenuButton<String>(
                      onSelected: (String result) {
                        if (result == 'agregar') {
                          // Llamar a la función para seleccionar y agregar una nueva imagen
                          _pickImage();
                        } else if (result == 'reemplazar') {
                          // Llamar a la función para reemplazar la imagen de perfil
                          _reemplazarFotoPerfil();
                        } else if (result == 'eliminar') {
                          // Llamar a la función para eliminar la imagen de perfil
                          _eliminarFotoPerfil();
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'agregar',
                          child: Text('Agregar Foto de Perfil'),
                        ),
                        PopupMenuItem<String>(
                          value: 'reemplazar',
                          child: Text('Reemplazar Foto de Perfil'),
                        ),
                        PopupMenuItem<String>(
                          value: 'eliminar',
                          child: Text('Eliminar Foto de Perfil'),
                        ),
                      ],
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        backgroundImage: _usuario!.fotoPortada != null && _usuario!.fotoPortada!.isNotEmpty
                        ? NetworkImage('http://$serverIP/homecoming/assets/imagenes/fotos_perfil/${_usuario!.fotoPortada}?${DateTime.now().millisecondsSinceEpoch}')
                        : _imageBytes != null
                            ? MemoryImage(_imageBytes!)
                            : AssetImage('assets/imagenes/avatar7.png') as ImageProvider,
                        child: _usuario!.fotoPortada == null && _imageBytes == null
                            ? Icon(
                                Icons.camera_alt,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      _usuario!.nombre,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _usuario!.email,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => EditarPerfilPage(user: _usuario!),
                        ));
                      },
                      child: Text('Editar Perfil'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _updatePassword,
                      child: Text('Actualizar Contraseña'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _logout,
                      child: Text('Cerrar Sesión'),
                    ),
                    SizedBox(height: 20),
                    // Sección de "Mis Publicaciones"
                    Text('Mis Publicaciones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 20),
                    // Convertimos la lista de publicaciones en un GridView
                    LayoutBuilder(
                      builder: (context, constraints) {
                        int crossAxisCount = 1;
                        if (constraints.maxWidth > 600) crossAxisCount = 2;
                        if (constraints.maxWidth > 900) crossAxisCount = 3;

                        return GridView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          padding: EdgeInsets.all(10),
                          itemCount: _misPublicaciones.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount, // Número de columnas, ajustado según el tamaño de la pantalla
                            crossAxisSpacing: 40, // Espacio horizontal entre los cards
                            mainAxisSpacing: 20,  // Espacio vertical entre los cards
                            childAspectRatio: 2 / 2, // Proporción entre ancho y alto de cada card
                          ),
                          itemBuilder: (context, index) {
                            var publicacion = _misPublicaciones[index];
                            List<String> fotos = List<String>.from(publicacion['fotos']); // Obtener la lista de fotos
                            return Card(
                              elevation: 3,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: publicacion['estado'] == 'perdido' ? Colors.red : Colors.green,
                                          borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(10),
                                            topRight: Radius.circular(10),
                                          ),
                                        ),
                                        child: Text(
                                          publicacion['estado'] == 'perdido'
                                              ? 'Tu mascota te extraña tanto tú a él/ella'
                                              : 'Nos complace saber que tu mascota fue encontrada',
                                          style: TextStyle(color: Colors.white),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      // Agregar el PopupMenuButton (Three Dots)
                                      Positioned(
                                        right: 10,
                                        top: 10,
                                        child: PopupMenuButton<String>(
                                          onSelected: (String result) {
                                            if (result == 'agregarFotos') {
                                              _mostrarModalCambiarFotos(context, publicacion['id']);
                                            } else if (result == 'reemplazarFoto') {
                                              _mostrarModalReemplazarFoto(context, publicacion['id']);
                                            } else if (result == 'eliminarFoto') {
                                              _mostrarModalEliminarFoto(context, publicacion['id']);
                                            }
                                          },
                                          itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                            PopupMenuItem<String>(
                                              value: 'agregarFotos',
                                              child: Text('Agregar Fotos'),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'reemplazarFoto',
                                              child: Text('Reemplazar Foto'),
                                            ),
                                            PopupMenuItem<String>(
                                              value: 'eliminarFoto',
                                              child: Text('Eliminar Foto'),
                                            ),
                                          ],
                                          icon: Icon(Icons.more_vert),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
                                      child: fotos.isNotEmpty
                                          ? fotos.length > 1 
                                              ? CarouselSlider(
                                                  options: CarouselOptions(
                                                    height: MediaQuery.of(context).size.height * 0.25,
                                                    viewportFraction: 1.0,
                                                    enlargeCenterPage: false,
                                                    enableInfiniteScroll: true,
                                                    autoPlay: true,
                                                  ),
                                                  items: fotos.map((foto) {
                                                    return Container(
                                                      child: AspectRatio(
                                                        aspectRatio: 1.5,
                                                        child: Image.network(
                                                          'http://$serverIP/homecoming/assets/imagenes/fotos_mascotas/$foto',
                                                          fit: BoxFit.contain,
                                                          errorBuilder: (context, error, stackTrace) {
                                                            return Icon(Icons.pets, size: 100, color: Colors.grey);
                                                          },
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                )
                                              : Container(
                                                  child: AspectRatio(
                                                    aspectRatio: 1.5,
                                                    child: Image.network(
                                                      'http://$serverIP/homecoming/assets/imagenes/fotos_mascotas/${fotos[0]}',
                                                      fit: BoxFit.contain,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Icon(Icons.pets, size: 100, color: Colors.grey);
                                                      },
                                                    ),
                                                  ),
                                                )
                                          : Icon(Icons.pets, size: 100, color: Colors.grey),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          publicacion['nombre'],
                                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Fecha de perdida: ${publicacion['fecha_perdida']}  -  ${obtenerMensajeFecha(DateTime.parse(publicacion['fecha_perdida']))}',
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                        SizedBox(height: 5),
                                        Text(
                                          'Se perdio en: ${publicacion['lugar_perdida']}',
                                          style: TextStyle(color: Colors.grey[600]),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                    child: Wrap(
                                      alignment: WrapAlignment.end,
                                      spacing: 10.0,
                                      runSpacing: 5.0,
                                      children: [
                                        SizedBox(
                                          width: 80,
                                          child: TextButton(
                                            onPressed: () {
                                              if (publicacion['estado'] == 'perdido') {
                                                _mostrarConfirmacionCambioEstado(
                                                  publicacion['id'],
                                                  'encontrado',
                                                  'Confirmación',
                                                  'Al aceptar estas confirmando que encontraste a tu mascota, ¿Es correcto?',
                                                );
                                              } else if (publicacion['estado'] == 'encontrado') {
                                                _mostrarConfirmacionCambioEstado(
                                                  publicacion['id'],
                                                  'perdido',
                                                  'Confirmación',
                                                  'Si tu mascota se volvió a perder, acepta este mensaje para hacer pública la desaparición de tu mascota.',
                                                );
                                              }
                                            },
                                            child: Text('Cambiar Estado', style: TextStyle(color: Colors.green[400])),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 80,
                                          child: TextButton(
                                            onPressed: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (context) => EditarPublicacionPage(publicacion: publicacion),
                                                ),
                                              );
                                            },
                                            child: Text('Editar', style: TextStyle(color: Colors.amber[500])),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 80,
                                          child: TextButton(
                                            onPressed: () {
                                              _confirmarEliminacionPublicacion(publicacion['id']);
                                            },
                                            child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}