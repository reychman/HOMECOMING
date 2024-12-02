import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/editar_perfil_page.dart';
import 'package:homecoming/pages/login/EditarPublicacionPage.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/usuario.dart';
import 'package:homecoming/pages/usuario_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';

class PerfilUsuario extends StatefulWidget {
  const PerfilUsuario({Key? key}) : super(key: key);

  @override
  _PerfilUsuarioState createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  Uint8List? _imageBytes;
  Usuario? _usuario;
  List<dynamic> _misPublicaciones = []; // Lista de publicaciones del usuario
  List<dynamic> _mascotasAdoptadas = [];

  @override
  void initState() {
    super.initState();
  _cargarDatos();
  }
  Future<void> _cargarDatos() async {
  await _loadUserData();  // Asumiendo que este método carga los datos del usuario
  await _publicacioPropiaUsuario();  // Tus publicaciones
  await _obtenerMascotasAdoptadas();  // Mascotas adoptadas
}
//inicio donde se administra las fotos de las mascotas
  Future<void> _mostrarModalAgregarFotos(BuildContext context, int publicacionId) async {
    List<Uint8List> nuevasFotos = [];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Agregar Fotos de la Mascota'),
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

  Future<void> _agregarFotos(BuildContext context, int publicacionId, List<Uint8List> nuevasFotos) async {
    // Capturar en el ScaffoldMessenger antes de las operaciones asincrónicas
    final scaffoldMessenger = ScaffoldMessenger.of(context);

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
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Fotos actualizadas con éxito.')));
        _publicacioPropiaUsuario(); // Asegúrate de que esta función esté definida en tu clase
      } else {
        // Manejar el error si 'success' es null o falso
        String errorMessage = jsonResponse != null && jsonResponse.containsKey('error')
          ? jsonResponse['error']
          : 'Error desconocido al actualizar las fotos.';
        scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error: $errorMessage')));
      }
    } catch (e) {
      // Manejar los errores en la solicitud HTTP
      scaffoldMessenger.showSnackBar(SnackBar(content: Text('Error al subir fotos: $e')));
    }
  }
//fin de administrador de las fotos de las mascotas

  Future<void> _loadUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? usuario_id = prefs.getInt('usuario_id');

  if (usuario_id != null) {
    Usuario? usuarioLogeado = await UsuarioProvider.getUsuarioActual(usuario_id);
    setState(() {
      _usuario = usuarioLogeado;
    });
    
    // Llamar a fetchUserPublications una vez cargado el usuario
    _publicacioPropiaUsuario();
  } else {
    print('No se encontró un usuario_id en SharedPreferences');
  }
}
//inicio de la administrador de la foto de perfil
  Future<void> _subirFotoPerfil(Uint8List imageBytes) async {
  if (_usuario == null || _usuario!.id == null) return;

  final request = http.MultipartRequest(
    'POST',
    Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/upload_image.php'),
  );

  request.fields['accion'] = 'subirFotoPerfil';
  request.fields['id'] = _usuario!.id.toString();

  request.files.add(http.MultipartFile.fromBytes(
    'foto_perfil',
    imageBytes,
    filename: 'foto_perfil_${_usuario!.id}.jpg',
    contentType: MediaType('image', 'jpeg'),
  ));

  try {
    final response = await request.send();
    final responseData = await response.stream.bytesToString();
    final jsonResponse = jsonDecode(responseData);

    if (jsonResponse['success']) {
      final nuevaFotoPerfil = jsonResponse['foto_perfil'];
      
      // Actualiza el usuario en el UsuarioProvider con la nueva foto de perfil
      final usuarioProvider = Provider.of<UsuarioProvider>(context, listen: false);
      Usuario? usuarioActualizado = usuarioProvider.usuario;
      if (usuarioActualizado != null) {
        usuarioActualizado = usuarioActualizado.copyWith(fotoPortada: nuevaFotoPerfil);
        usuarioProvider.setUsuario(usuarioActualizado);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Foto de perfil subida correctamente.'),
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => PerfilUsuario(),
        ),
      );
    }
  } catch (e) {
    print('Error en _subirFotoPerfil: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ocurrió un error al subir la foto de perfil.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}

  Future<void> _reemplazarFotoPerfil() async {
    final picker = ImagePicker();
    try {
      // Seleccionar una nueva imagen desde la galería
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (!mounted) return; // Verificar si el widget sigue montado

      if (pickedFile != null) {
        // Recortar la imagen seleccionada
        final croppedBytes = await _cropImage(context, pickedFile.path);

        if (!mounted) return; // Verificar si el widget sigue montado

        if (croppedBytes != null) {
          // Actualizar la imagen en la interfaz
          setState(() {
            _imageBytes = croppedBytes;
          });

          // Subir la nueva imagen al servidor
          await _subirFotoPerfil(croppedBytes);

          // Llamar al método para recargar las publicaciones del usuario
          _publicacioPropiaUsuario(); // Recargar las publicaciones o realizar alguna acción después de subir la imagen
        } else {
          // Si no se recortó correctamente
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No se recortó la imagen.')),
            );
          }
        }
      } else {
        // Si no se seleccionó ninguna imagen
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se seleccionó ninguna imagen.')),
          );
        }
      }
    } catch (e) {
      // Manejar errores
      print('Error al seleccionar o recortar la imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar o recortar la imagen.')),
        );
      }
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
// fin de la administracion de foto de perfil
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    try {
      // Seleccionar imagen desde la galería
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (!mounted) return; // Verificar si el widget sigue montado

      if (pickedFile != null) {
        // Llamamos al método _cropImage para recortar la imagen
        final croppedBytes = await _cropImage(context, pickedFile.path);

        if (!mounted) return; // Verificar nuevamente después de la operación async

        if (croppedBytes != null) {
          // Mostramos la imagen recortada antes de subirla
          setState(() {
            _imageBytes = croppedBytes;
          });

          // Subimos la imagen recortada al servidor
          await _subirFotoPerfil(croppedBytes);
        } else {
          // Si no se recortó correctamente la imagen
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No se recortó la imagen.')),
            );
          }
        }
      } else {
        // Si no se seleccionó ninguna imagen
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se seleccionó ninguna imagen.')),
          );
        }
      }
    } catch (e) {
      // Captura cualquier error durante la selección o recorte de la imagen
      print('Error al seleccionar o recortar la imagen: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al seleccionar o recortar la imagen.')),
        );
      }
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
  final _formKey = GlobalKey<FormState>();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(
              'Actualizar Contraseña', 
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: Colors.green[700]
              ),
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: newPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Nueva Contraseña',
                      prefixIcon: Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isPasswordVisible 
                            ? Icons.visibility 
                            : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isPasswordVisible = !isPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    obscureText: !isPasswordVisible,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese una contraseña';
                      }
                      if (value.length < 8) {
                        return 'La contraseña debe tener al menos 8 caracteres';
                      }
                      if (!RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
                          .hasMatch(value)) {
                        return 'Contraseña debe contener:\n- Mayúscula\n- Minúscula\n- Número\n- Carácter especial';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: confirmPasswordController,
                    decoration: InputDecoration(
                      labelText: 'Confirmar Contraseña',
                      prefixIcon: Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(
                          isConfirmPasswordVisible 
                            ? Icons.visibility 
                            : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            isConfirmPasswordVisible = !isConfirmPasswordVisible;
                          });
                        },
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    obscureText: !isConfirmPasswordVisible,
                    validator: (value) {
                      if (value != newPasswordController.text) {
                        return 'Las contraseñas no coinciden';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.black,
                ),
                child: Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Llamar a la función para actualizar la contraseña en el backend
                    await _enviarNuevaContrasena(newPasswordController.text);
                    Navigator.of(context).pop(); // Cierra el modal
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Contraseña actualizada exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[500],
                ),
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

    if (!mounted) return; // Check if the widget is still mounted

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

  Future<void> _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); // Elimina el userId almacenado
    await prefs.setBool('isLoggedIn', false); // Nueva bandera
    Provider.of<UsuarioProvider>(context, listen: false).setUsuario(Usuario.vacio());
    Navigator.of(context).pushReplacementNamed('/inicio');
  }

// Obtener las publicaciones del usuario
  Future<void> _publicacioPropiaUsuario() async {
    if (_usuario == null) return;
    try {
      var response = await http.post(
        Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/gestionar_publicaciones.php'),
        body: {
          'usuario_id': _usuario!.id.toString(),
          'accion': 'obtenerPublicaciones',
        },
      );
      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        if (jsonResponse is List) {
          setState(() {
            _misPublicaciones = jsonResponse.map((publicacion) {
              // Asegúrate de que 'fotos' sea una lista de mapas o cadenas
              if (publicacion['fotos'] is List) {
                publicacion['fotos'] = publicacion['fotos'].map((foto) {
                  return foto is String ? foto : (foto is Map ? foto : null);
                }).whereType<dynamic>().toList();
              } else {
                publicacion['fotos'] = [];
              }
              return publicacion;
            }).toList();
          });
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
    String estadoActual, // Agregar el estado actual como parámetro
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
      // Lógica adicional para cambiar el estado según la transición
      if (nuevoEstado == 'adoptado' && estadoActual == 'pendiente') {
        _cambiarEstadoMascota(publicacionId, 'adoptado');
      } else if (nuevoEstado == 'encontrado' && estadoActual == 'perdido') {
        _cambiarEstadoMascota(publicacionId, 'encontrado');
      } else if (nuevoEstado == 'perdido' && estadoActual == 'encontrado') {
        _cambiarEstadoMascota(publicacionId, 'perdido');
      }
      // No se permite más cambios para 'adoptado'
    }
  }

// Cambiar el estado de la publicación (por ejemplo, de perdido a encontrado)
  Future<void> _cambiarEstadoMascota(int publicacionId, String nuevoEstado) async {
    var response = await http.post(
      Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/gestionar_publicaciones.php'),
      body: {
        'accion': 'actualizarEstado',
        'id': publicacionId.toString(), // El ID de la mascota
        'estado': nuevoEstado,          // El nuevo estado
      }
    );
    

    if (response.statusCode == 200) {
      _publicacioPropiaUsuario(); // Actualiza las publicaciones después del cambio
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

    if (!mounted) return; // Comprueba si el widget todavía está montado antes de acceder al contexto

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
        _publicacioPropiaUsuario(); // Actualiza las publicaciones después de eliminar
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

  Future<Uint8List?> _cropImage(BuildContext context, String imagePath) async {
    CroppedFile? croppedFile;

    // Configuración para Web y Android/iOS
    croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatio: CropAspectRatio(ratioX: 1, ratioY: 1), // Relación de aspecto cuadrada
      uiSettings: [
        IOSUiSettings(
          title: 'Recortar Imagen',
          cancelButtonTitle: 'Cancelar',
          doneButtonTitle: 'Recortar',
          aspectRatioPickerButtonHidden: true,
          rotateButtonsHidden: false,
        ),
        if (kIsWeb)
          WebUiSettings(
            context: context, // Usamos el context, pero solo si el widget sigue montado
            size: CropperSize(width: 400, height: 400), // Tamaño fijo
            dragMode: WebDragMode.crop, // Modo de arrastre solo para recortar
            initialAspectRatio: 1.0, // Relación de aspecto fija (cuadrada) para Web
            zoomable: true, // Habilitar zoom
            rotatable: true, // Habilitar rotación
            cropBoxResizable: false,
            translations: WebTranslations(
              title: 'Recortar Imagen',
              cropButton: 'Recortar',
              cancelButton: 'Cancelar',
              rotateLeftTooltip: 'Girar a la izquierda',
              rotateRightTooltip: 'Girar a la derecha',
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

  Future<void> _mostrarInteresados(int idMascota) async {
    final url = Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/adopcion.php?mascota_id=$idMascota');
    
    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'success') {
          List interesados = data['data'];
          Map<String, dynamic>? selectedInteresado;
          
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return StatefulBuilder(
                builder: (context, setState) {
                  return AlertDialog(
                    title: Text('Interesados en Adoptar'),
                    content: interesados.isNotEmpty
                        ? SizedBox(
                            width: double.maxFinite,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: interesados.length,
                                    itemBuilder: (context, index) {
                                      final interesado = interesados[index];
                                      String nombreCompleto = interesado['nombre'];
                                      if (interesado['primerApellido'] != null) {
                                        nombreCompleto += ' ${interesado['primerApellido']}';
                                      }
                                      if (interesado['segundoApellido'] != null && interesado['segundoApellido'].isNotEmpty) {
                                        nombreCompleto += ' ${interesado['segundoApellido']}';
                                      }
                                      
                                      return ListTile(
                                        leading: Radio<Map<String, dynamic>>(
                                          value: interesado,
                                          groupValue: selectedInteresado,
                                          onChanged: (Map<String, dynamic>? value) {
                                            setState(() {
                                              selectedInteresado = value;
                                            });
                                          },
                                        ),
                                        title: Text(nombreCompleto),
                                        subtitle: Text(interesado['email']),
                                        trailing: IconButton(
                                          icon: Icon(Icons.message, color: Colors.green),
                                          onPressed: () {
                                            final whatsappUri = Uri.parse(
                                              'https://wa.me/${interesado['telefono']}?text=Hola, me comunico contigo porque estás interesado en adoptar una mascota.',
                                            );
                                            launchUrl(whatsappUri);
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: selectedInteresado == null ? null : () async {
                                    bool? confirmar = await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Confirmar Adopción'),
                                          content: Text(
                                            'Al continuar estás confirmando que ${selectedInteresado!['nombre']} adoptó a la mascota. ¿Deseas continuar?'
                                          ),
                                          actions: [
                                            TextButton(
                                              child: Text('Cancelar'),
                                              onPressed: () => Navigator.of(context).pop(false),
                                            ),
                                            ElevatedButton(
                                              child: Text('Confirmar'),
                                              onPressed: () => Navigator.of(context).pop(true),
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmar == true) {
                                      final confirmarUrl = Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/adopcion.php');
                                      try {
                                        final confirmarResponse = await http.post(
                                          confirmarUrl,
                                          body: {
                                            'action': 'confirmar_adopcion',
                                            'mascota_id': idMascota.toString(),
                                            'adoptante_id': selectedInteresado!['id'].toString(),
                                          },
                                        );

                                        final responseData = json.decode(confirmarResponse.body);
                                        if (responseData['status'] == 'success') {
                                          Navigator.of(context).pop(); // Cerrar diálogo de confirmación                                        
                                          _publicacioPropiaUsuario();

                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Adopción confirmada exitosamente')),
                                          );
                                          
                                          // Aquí puedes actualizar tu UI si es necesario
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error: ${responseData['message']}')),
                                          );
                                        }
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error al confirmar la adopción: $e')),
                                        );
                                      }
                                    }
                                  },
                                  child: Text('Confirmar Adopción'),
                                ),
                              ],
                            ),
                          )
                        : Text('Nadie ha mostrado interés en esta mascota.'),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Cerrar'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  );
                },
              );
            },
          );
        } else {
          print(data['message']);
        }
      } else {
        print('Error al obtener interesados');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Color _getEstadoColor(String estado) {
    switch (estado) {
      case 'perdido':
        return Colors.red;
      case 'encontrado':
        return Colors.green;
      case 'adopcion':
        return Colors.orange; // O el color que prefieras
      case 'pendiente':
        return Colors.blue; // O el color que prefieras
      case 'adoptado':
        return Colors.green; // O el color que prefieras
      default:
        return Colors.grey; // Color por defecto si no coincide con ningún estado
    }
  }

  String _getEstadoTexto(String estado) {
    switch (estado) {
      case 'perdido':
        return 'Tu mascota te extraña tanto como tú a él/ella';
      case 'encontrado':
        return 'Nos complace saber que tu mascota fue encontrada';
      case 'adopcion':
        return 'Esta mascota está en adopción';
      case 'pendiente':
        return 'Hay alguien interesado en la adopción';
      case 'adoptado':
        return 'Mascota Adoptada';
      default:
        return 'Estado desconocido'; // Texto por defecto si no coincide con ningún estado
    }
  }

Future<void> _obtenerMascotasAdoptadas() async {
  if (_usuario == null) return;
  try {
    var response = await http.post(
      Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/gestionar_publicaciones.php'),
      body: {
        'usuario_id': _usuario!.id.toString(),
        'accion': 'obtenerMascotasAdoptadas',
      },
    );
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      
      // Verificar si es una lista o tiene un error
      if (jsonResponse is List) {
        setState(() {
          _mascotasAdoptadas = jsonResponse.map((mascota) {
            // Asegúrate de que 'fotos' sea una lista de mapas o cadenas
            if (mascota['fotos'] is List) {
              mascota['fotos'] = mascota['fotos'].map((foto) {
                return foto is String ? foto : (foto is Map ? foto : null);
              }).whereType<dynamic>().toList();
            } else {
              mascota['fotos'] = [];
            }
            return mascota;
          }).toList();
        });
      } else if (jsonResponse is Map && jsonResponse.containsKey('error')) {
        // Manejar el caso de error
        print('Error: ${jsonResponse['error']}');
        setState(() {
          _mascotasAdoptadas = [];
        });
      }
    }
  } catch (e) {
    print('Error en la solicitud: $e');
    setState(() {
      _mascotasAdoptadas = [];
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        title: Text('Perfil'),
      ),
      drawer: MenuWidget(usuario: _usuario ?? Usuario.vacio()),
      backgroundColor: Colors.green[50],
      body: _usuario == null
          ? Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                // Definir el ancho mínimo, por ejemplo 300px
                double minWidth = 300;
                // Si el ancho es menor que el mínimo, ajustarlo al mínimo
                double effectiveWidth = constraints.maxWidth < minWidth ? minWidth : constraints.maxWidth;
                return SingleChildScrollView( // Asegura que todo el contenido sea desplazable si no cabe en pantalla
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: minWidth,
                        maxWidth: effectiveWidth,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: 20),
                            PopupMenuButton<String>(
                              onSelected: (String result) {
                                if (result == 'agregar') {
                                  _pickImage();
                                } else if (result == 'reemplazar') {
                                  _reemplazarFotoPerfil();
                                } else if (result == 'eliminarFotoPerfil') {
                                  _eliminarFotoPerfil();
                                }
                              },
                              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                PopupMenuItem<String>(
                                  value: 'agregar',
                                  child: Text('Agregar Foto de Perfil'),
                                ),
                                PopupMenuItem<String>(
                                  value: 'eliminarFotoPerfil',
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
                                        : NetworkImage('http://$serverIP/homecoming/assets/imagenes/avatarDefecto.png') as ImageProvider,
                                child: _usuario!.fotoPortada == null && _imageBytes != null
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
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blue[500],
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                shadowColor: Colors.blue[500],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.edit_outlined, size: 20),
                                  SizedBox(width: 10),
                                  Text('Editar Perfil'),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _updatePassword,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.green[500],
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                shadowColor: Colors.green[500],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.lock_reset_outlined, size: 20),
                                  SizedBox(width: 10),
                                  Text('Actualizar Contraseña'),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => _logout(context),
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red[500],
                                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                shadowColor: Colors.red[500],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.logout_outlined, size: 20),
                                  SizedBox(width: 10),
                                  Text('Cerrar Sesión'),
                                ],
                              ),
                            ),
                            SizedBox(height: 20),
                            Text('Mis Publicaciones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 20),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                int crossAxisCount;
                                  if (constraints.maxWidth > 1200) {
                                    crossAxisCount = 4; // Extra large screens
                                  } else if (constraints.maxWidth > 900) {
                                    crossAxisCount = 3; // Desktop/Tablet landscape
                                  } else if (constraints.maxWidth > 600) {
                                    crossAxisCount = 2; // Tablet portrait
                                  } else {
                                    crossAxisCount = 1; // Mobile
                                  }
                                return GridView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true, // Evita que el GridView ocupe más espacio del necesario
                                  padding: EdgeInsets.all(10),
                                  itemCount: _misPublicaciones.length,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 16.0,
                                    mainAxisSpacing: 16.0,
                                    childAspectRatio: 0.85,
                                  ),
                                  itemBuilder: (context, index) {
                                    final publicacion = _misPublicaciones[index];
                                    List<String> fotos = List<String>.from(publicacion['fotos']);
                                    return Card(
                                      margin: EdgeInsets.all(8.0),
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
                                                  color: _getEstadoColor(publicacion['estado']),
                                                  borderRadius: BorderRadius.only(
                                                    topLeft: Radius.circular(10),
                                                    topRight: Radius.circular(10),
                                                  ),
                                                ),
                                                child: Text(
                                                  publicacion['estado_registro'] == 2
                                                      ? 'Publicación Restringida'
                                                      : _getEstadoTexto(publicacion['estado']),
                                                  style: TextStyle(color: Colors.white),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Positioned(
                                                right: 10,
                                                top: 10,
                                                child: PopupMenuButton<String>(
                                                  onSelected: (String result) {
                                                    if (result == 'eliminar') {
                                                      _confirmarEliminacionPublicacion(publicacion['id']);
                                                    } else if (result == 'verAdoptante') {
                                                      // Aquí deberías agregar la lógica para ver al adoptante
                                                      //_mostrarInformacionAdoptante(context, publicacion['id']);
                                                    } else if (publicacion['estado_registro'] != 2) {
                                                      if (result == 'agregarFotos') {
                                                        _mostrarModalAgregarFotos(context, publicacion['id']);
                                                      } else if (result == 'cambiarEstado') {
                                                        if (publicacion['estado'] == 'perdido') {
                                                          _mostrarConfirmacionCambioEstado(
                                                            publicacion['id'],
                                                            'encontrado',
                                                            'Confirmación',
                                                            'Al aceptar, confirmarás que encontraste a tu mascota, ¿Es correcto?',
                                                            publicacion['estado'],
                                                          );
                                                        } else if (publicacion['estado'] == 'encontrado') {
                                                          _mostrarConfirmacionCambioEstado(
                                                            publicacion['id'],
                                                            'perdido',
                                                            'Confirmación',
                                                            'Si tu mascota se volvió a perder, actualiza los datos y acepta este mensaje para hacer pública la desaparición de tu mascota.',
                                                            publicacion['estado'],
                                                          );
                                                        } else if (publicacion['estado'] == 'pendiente') {
                                                          _mostrarConfirmacionCambioEstado(
                                                            publicacion['id'],
                                                            'adoptado',
                                                            'Confirmación de Adopción',
                                                            '¿La mascota fue adoptada? Al aceptar, cambiará el estado a adoptado y no se podrá cambiar nuevamente.',
                                                            publicacion['estado'],
                                                          );
                                                        }
                                                      } else if (result == 'editar') {
                                                        Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                            builder: (context) => EditarPublicacionPage(
                                                              publicacion: publicacion,
                                                              estado: publicacion['estado'],
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  },
                                                  itemBuilder: (BuildContext context) {
                                                    // Lista de opciones según el estado
                                                    List<PopupMenuEntry<String>> opciones = [];

                                                    switch (publicacion['estado']) {
                                                      case 'adoptado':
                                                        // Solo mostrar eliminar y ver adoptante
                                                        opciones = [
                                              const PopupMenuItem<String>(
                                                            value: 'eliminar',
                                                            child: Text('Eliminar publicación'),
                                                          ),
                                                        ];
                                                        break;

                                                      case 'adopcion':
                                                        // Solo mostrar 3 opciones básicas
                                                        opciones = [
                                                          const PopupMenuItem<String>(
                                                            value: 'agregarFotos',
                                                            child: Text('Agregar Fotos'),
                                                          ),
                                                          const PopupMenuItem<String>(
                                                            value: 'editar',
                                                            child: Text('Actualizar datos'),
                                                          ),
                                                          const PopupMenuItem<String>(
                                                            value: 'eliminar',
                                                            child: Text('Eliminar publicación'),
                                                          ),
                                                        ];
                                                        break;

                                                      case 'perdido':
                                                      case 'encontrado':
                                                        // Opciones completas para perdido/encontrado
                                                        opciones = [
                                                          const PopupMenuItem<String>(
                                                            value: 'agregarFotos',
                                                            child: Text('Agregar Fotos'),
                                                          ),
                                                          PopupMenuItem<String>(
                                                            value: 'cambiarEstado',
                                                            child: Text(publicacion['estado'] == 'perdido' 
                                                              ? '¿Mascota Encontrada?' 
                                                              : '¿Mascota Perdida?'),
                                                          ),
                                                          const PopupMenuItem<String>(
                                                            value: 'editar',
                                                            child: Text('Actualizar datos'),
                                                          ),
                                                          const PopupMenuItem<String>(
                                                            value: 'eliminar',
                                                            child: Text('Eliminar publicación'),
                                                          ),
                                                        ];
                                                        break;

                                                      case 'pendiente':
                                                        // Opciones para estado pendiente
                                                        opciones = [
                                                          const PopupMenuItem<String>(
                                                            value: 'agregarFotos',
                                                            child: Text('Agregar fotos'),
                                                          ),
                                                          const PopupMenuItem<String>(
                                                            value: 'editar',
                                                            child: Text('Actualizar datos'),
                                                          ),
                                                          const PopupMenuItem<String>(
                                                            value: 'eliminar',
                                                            child: Text('Eliminar publicación'),
                                                          ),
                                                        ];
                                                        break;

                                                      default:
                                                        // Opciones por defecto si hay algún estado no contemplado
                                                        opciones = [
                                                          const PopupMenuItem<String>(
                                                            value: 'eliminar',
                                                            child: Text('Eliminar publicación'),
                                                          ),
                                                        ];
                                                    }

                                                    // Si el estado_registro es 2, solo mostrar opción de eliminar
                                                    if (publicacion['estado_registro'] == 2) {
                                                      return <PopupMenuEntry<String>>[
                                                        const PopupMenuItem<String>(
                                                          value: 'eliminar',
                                                          child: Text('Eliminar publicación'),
                                                        ),
                                                      ];
                                                    }

                                                    return opciones;
                                                  },
                                                  icon: Icon(Icons.more_vert),
                                                ),
                                              )
                                            ],
                                          ),
                                          Expanded(
                                            child: publicacion['estado_registro'] == 2
                                                ? Padding(
                                                    padding: const EdgeInsets.all(16.0),
                                                    child: Center(
                                                      child: Text(
                                                        'Esta publicación fue eliminada por un administrador debido a contenido inapropiado.',
                                                        style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                    ),
                                                  )
                                                : ClipRRect(
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
                                                                  return AspectRatio(
                                                                    aspectRatio: 1.5,
                                                                    child: Image.network(
                                                                      'http://$serverIP/homecoming/assets/imagenes/fotos_mascotas/$foto',
                                                                      fit: BoxFit.contain,
                                                                      errorBuilder: (context, error, stackTrace) {
                                                                        return Icon(Icons.pets, size: 100, color: Colors.grey);
                                                                      },
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                              )
                                                            : AspectRatio(
                                                                aspectRatio: 1.5,
                                                                child: Image.network(
                                                                  'http://$serverIP/homecoming/assets/imagenes/fotos_mascotas/${fotos[0]}',
                                                                  fit: BoxFit.contain,
                                                                  errorBuilder: (context, error, stackTrace) {
                                                                    return Icon(Icons.pets, size: 100, color: Colors.grey);
                                                                  },
                                                                ),
                                                              )
                                                        : Icon(Icons.pets, size: 100, color: Colors.grey),
                                                  ),
                                          ),
                                          if (publicacion['estado_registro'] != 2)
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
                                                if (publicacion['estado'] == 'pendiente') ...[
                                                  Center(
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        _mostrarInteresados(publicacion['id']);
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        foregroundColor: Colors.white,
                                                        backgroundColor: Colors.green[700],
                                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                        textStyle: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12),
                                                        ),
                                                        elevation: 4,
                                                        shadowColor: Colors.green[900],
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(Icons.people_outline, size: 20),
                                                          SizedBox(width: 10),
                                                          Text('Ver Interesados'),
                                                        ],
                                                      ),
                                                    ),
                                                    ),
                                                ] else if (publicacion['estado'] == 'perdido') ...[
                                                  SizedBox(height: 5),
                                                  Text(
                                                    'Fecha de perdida: ${publicacion['fecha_perdida'] != null ? publicacion['fecha_perdida'] : 'No disponible'}  -  ${publicacion['fecha_perdida'] != null ? obtenerMensajeFecha(DateTime.parse(publicacion['fecha_perdida'])) : ''}',
                                                    style: TextStyle(color: Colors.grey[600]),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    'Se perdió en: ${publicacion['lugar_perdida']}',
                                                    style: TextStyle(color: Colors.grey[600]),
                                                  ),
                                                  Center(
                                                    child: ElevatedButton(
                                                      onPressed: () {
                                                        _mostrarMapa(context, publicacion['id']);
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        foregroundColor: Colors.white, // Color del texto
                                                        backgroundColor: Colors.green[700], // Color de fondo
                                                        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                                        textStyle: TextStyle(
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius: BorderRadius.circular(12), // Bordes redondeados
                                                        ),
                                                        elevation: 4, // Sombra para efecto de profundidad
                                                        shadowColor: Colors.green[900], // Color de sombra
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          Icon(Icons.map_outlined, size: 20), // Ícono de mapa
                                                          SizedBox(width: 10), // Espacio entre ícono y texto
                                                          Text('Ver Avistamientos'),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ] else if (!(publicacion['estado'] == 'adopcion' || publicacion['estado'] == 'adoptado')) ...[
                                                  Text(
                                                    'Fecha de perdida: ${publicacion['fecha_perdida'] != null ? publicacion['fecha_perdida'] : 'No disponible'}  -  ${publicacion['fecha_perdida'] != null ? obtenerMensajeFecha(DateTime.parse(publicacion['fecha_perdida'])) : ''}',
                                                    style: TextStyle(color: Colors.grey[600]),
                                                  ),
                                                  SizedBox(height: 5),
                                                  Text(
                                                    'Se perdió en: ${publicacion['lugar_perdida']}',
                                                    style: TextStyle(color: Colors.grey[600]),
                                                  ),
                                                ] else ...[
                                                  Text(
                                                    'Descripción: ${publicacion['descripcion'] ?? 'No disponible'}',
                                                    style: TextStyle(color: Colors.grey[600]),
                                                  ),
                                                ]
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
                            SizedBox(height: 40), // Espaciado entre secciones
                            Text('Mis Intereses en Mascotas', 
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 20),
                            
                            LayoutBuilder(
                              builder: (context, constraints) {
                                int crossAxisCount;
                                if (constraints.maxWidth > 1200) {
                                  crossAxisCount = 4;
                                } else if (constraints.maxWidth > 900) {
                                  crossAxisCount = 3;
                                } else if (constraints.maxWidth > 600) {
                                  crossAxisCount = 2;
                                } else {
                                  crossAxisCount = 1;
                                }
                                return _mascotasAdoptadas.isEmpty
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: Text(
                                            'No has adoptado ninguna mascota todavía',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      )
                                    : GridView.builder(
                                        physics: NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        padding: EdgeInsets.all(10),
                                        itemCount: _mascotasAdoptadas.length,
                                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: crossAxisCount,
                                          crossAxisSpacing: 16.0,
                                          mainAxisSpacing: 16.0,
                                          childAspectRatio: 0.85,
                                        ),
                                        itemBuilder: (context, index) {
                                          final mascota = _mascotasAdoptadas[index];
                                          List<String> fotos = List<String>.from(mascota['fotos']);
                                          bool isAdopted = mascota['estado'] == 'adoptado';

                                          return Card(
                                            margin: EdgeInsets.all(8.0),
                                            elevation: 3,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10)
                                            ),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Container(
                                                  width: double.infinity,
                                                  padding: EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: isAdopted ? Colors.green[400] : Colors.orange[400],
                                                    borderRadius: BorderRadius.only(
                                                      topLeft: Radius.circular(10),
                                                      topRight: Radius.circular(10),
                                                    ),
                                                  ),
                                                  child: Text(
                                                    isAdopted ? 'Mascota Adoptada' : 'En Proceso de Adopción',
                                                    style: TextStyle(color: Colors.white),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: ClipRRect(
                                                    borderRadius: BorderRadius.vertical(
                                                      bottom: Radius.circular(10)
                                                    ),
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
                                                                  return AspectRatio(
                                                                    aspectRatio: 1.5,
                                                                    child: Image.network(
                                                                      'http://$serverIP/homecoming/assets/imagenes/fotos_mascotas/$foto',
                                                                      fit: BoxFit.contain,
                                                                      errorBuilder: (context, error, stackTrace) {
                                                                        return Icon(Icons.pets, size: 100, color: Colors.grey);
                                                                      },
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                              )
                                                            : AspectRatio(
                                                                aspectRatio: 1.5,
                                                                child: Image.network(
                                                                  'http://$serverIP/homecoming/assets/imagenes/fotos_mascotas/${fotos[0]}',
                                                                  fit: BoxFit.contain,
                                                                  errorBuilder: (context, error, stackTrace) {
                                                                    return Icon(Icons.pets, size: 100, color: Colors.grey);
                                                                  },
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
                                                        mascota['nombre'],
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 18
                                                        ),
                                                      ),
                                                      SizedBox(height: 5),
                                                      if (isAdopted) ...[
                                                        Text(
                                                          'Anterior dueño: ${mascota['nombre_dueno_original']}',
                                                          style: TextStyle(color: Colors.grey[600]),
                                                        ),
                                                        Text(
                                                          'Correo: ${mascota['email_dueno_original']}',
                                                          style: TextStyle(color: Colors.grey[600]),
                                                        ),
                                                        Text(
                                                          'Contacto: ${mascota['telefono_dueno_original']}',
                                                          style: TextStyle(color: Colors.grey[600]),
                                                        ),
                                                      ] else ...[
                                                        Text(
                                                          'Especie: ${mascota['especie']}',
                                                          style: TextStyle(color: Colors.grey[600]),
                                                        ),
                                                        Text(
                                                          'Raza: ${mascota['raza']}',
                                                          style: TextStyle(color: Colors.grey[600]),
                                                        ),
                                                      ]
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      );
                              },
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
  
void _mostrarMapa(BuildContext context, int idMascota) async {
    List<Marker> markers = [];
    
    bool isMobile = !kIsWeb;
    
    final String apiUrl =
        'http://$serverIP/homecoming/homecomingbd_v2/ver_avistamientos.php?id_mascota=$idMascota';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success']) {
          // Cargar íconos personalizados con rutas condicionales
          final BitmapDescriptor ubicacionOriginalIcon = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(
              devicePixelRatio: 3.2,
              size: Size(48, 48) 
            ),
            isMobile 
              ? 'assets/imagenes/ubicacion.png' 
              : 'imagenes/ubicacion.png'
          );

          final BitmapDescriptor avistamientoIcon = await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(
              devicePixelRatio: 3.2,
              size: Size(48, 48)
            ),
            isMobile 
              ? 'assets/imagenes/avistamientos.png' 
              : 'imagenes/avistamientos.png'
          );

          // Agregar marcador de ubicación original
          if (data['mascota_ubicacion'] != null) {
            markers.add(
              Marker(
                markerId: MarkerId('ubicacion'),
                position: LatLng(
                  double.parse(data['mascota_ubicacion']['latitud']),
                  double.parse(data['mascota_ubicacion']['longitud']),
                ),
                icon: ubicacionOriginalIcon,
                infoWindow: InfoWindow(
                  title: 'Aquí se perdió originalmente la mascota',
                ),
              ),
            );
          }

          // Agregar marcadores de avistamientos
          for (var avistamiento in data['avistamientos']) {
            markers.add(
              Marker(
                markerId: MarkerId(avistamiento['fecha_avistamiento'] ?? DateTime.now().toString()),
                position: LatLng(
                  double.parse(avistamiento['latitud']),
                  double.parse(avistamiento['longitud']),
                ),
                icon: avistamientoIcon,
                infoWindow: InfoWindow(
                  title: "Fecha de avistamiento: ${avistamiento['fecha_avistamiento']}",
                  snippet: avistamiento['detalles'] ?? 'Sin detalles',
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Detalles del Avistamiento'),
                        content: SingleChildScrollView(
                          child: ListBody(
                            children: <Widget>[
                              Text('Fecha: ${avistamiento['fecha_avistamiento']}'),
                              SizedBox(height: 10),
                              Text('Detalles completos:', style: TextStyle(fontWeight: FontWeight.bold)),
                              Text(avistamiento['detalles'] ?? 'No hay detalles disponibles'),
                              // Puedes agregar más campos si los tienes
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cerrar'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            );
          }

          // Mostrar el mapa si hay marcadores
          if (markers.isNotEmpty) {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                  insetPadding: EdgeInsets.all(16),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mapa de Avistamientos',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.close),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: markers[0].position,
                              zoom: 15.9,
                            ),
                            markers: Set<Marker>.of(markers),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            // No hay ubicaciones para mostrar
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("No se encontraron ubicaciones.")),
            );
          }
        } else {
          // Error en la solicitud
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? "No se encontraron datos.")),
          );
        }
      } else {
        throw Exception("Error en la solicitud: ${response.statusCode}");
      }
    } catch (e) {
      // Manejar errores
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al cargar los avistamientos: $e")),
      );
    }
  }
}