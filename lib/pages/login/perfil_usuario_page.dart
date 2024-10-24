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

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _publicacioPropiaUsuario(); // Cargar publicaciones del usuario
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
  Widget _buildCarousel(List<dynamic> fotos, int publicacionIndex) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 300.0,
        enlargeCenterPage: true,
        autoPlay: false,
        aspectRatio: 16 / 9,
        viewportFraction: 0.9,
      ),
      items: fotos.asMap().entries.map((entry) {
        int fotoIndex = entry.key;
        dynamic foto = entry.value;
        return Builder(
          builder: (BuildContext context) {
            return Stack(
              children: [
                // Contenedor para la imagen
                Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                  ),
                  child: Image.network(
                    foto['ruta'] as String, // Asegúrate de que 'ruta' es String
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error al cargar la imagen: $error');
                      return Center(child: Text('Error al cargar la imagen'));
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(child: CircularProgressIndicator());
                    },
                  ),
                ),
                // IconButton para eliminar la foto (X en la esquina superior derecha)
                Positioned(
                  right: 10,
                  top: 10,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.red), // Icono de la X
                    onPressed: () => _modalEliminarFotoMascota(context, publicacionIndex, foto['id'] as int, fotoIndex),
                  ),
                ),
              ],
            );
          },
        );
      }).toList(),
    );
  }

  Future<void> _modalEliminarFotoMascota(BuildContext context, int publicacionIndex, int fotoId, int fotoIndex) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Eliminar Foto'),
          content: Text('¿Estás seguro de que deseas eliminar esta foto?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _eliminarFotoMascota(context, publicacionIndex, fotoId, fotoIndex);
              },
              child: Text('Eliminar Foto'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _eliminarFotoMascota(BuildContext context, int publicacionIndex, int fotoId, int fotoIndex) async {
    try {
      final response = await http.post(
        Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/gestionar_publicaciones.php'),
        body: {
          'accion': 'eliminarFotoMascota',
          'foto_id': fotoId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _misPublicaciones[publicacionIndex]['fotos'].removeAt(fotoIndex);
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Foto eliminada con éxito')));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: ${data['error']}')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error en la conexión')));
      }
    } catch (e) {
      print('Error al eliminar la foto: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al eliminar la foto')));
    }
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

        // Mostrar mensaje de confirmación
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Foto de perfil subida correctamente.'),
              duration: Duration(seconds: 2),
            ),
          );
        }

        // Refrescar la página después de la operación
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PerfilUsuario(),
          ),
        );
      }
    } catch (e) {
      // Manejar los errores de red u otros
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
        print('Se están cargando en formato Json');
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

          if (_misPublicaciones.isNotEmpty) {
            print('Se están cargando tus publicaciones');
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
    
    print('Response body: ${response.body}');

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        title: Text('Perfil'),
      ),
      drawer: MenuWidget(usuario: _usuario ?? Usuario.vacio()),
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
                              child: Text('Editar Perfil'),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _updatePassword,
                              child: Text('Actualizar Contraseña'),
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () => _logout(context),
                              child: Text('Cerrar Sesión'),
                            ),
                            SizedBox(height: 20),
                            Text('Mis Publicaciones', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            SizedBox(height: 20),
                            LayoutBuilder(
                              builder: (context, constraints) {
                                int crossAxisCount = 1;
                                if (constraints.maxWidth > 600) crossAxisCount = 2;
                                if (constraints.maxWidth > 900) crossAxisCount = 3;
                                return GridView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true, // Evita que el GridView ocupe más espacio del necesario
                                  padding: EdgeInsets.all(10),
                                  itemCount: _misPublicaciones.length,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 20,
                                    mainAxisSpacing: 20,
                                    childAspectRatio: 2 / 1.5,
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
                                                  _getEstadoTexto(publicacion['estado']),
                                                  style: TextStyle(color: Colors.white),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              Positioned(
                                                right: 10,
                                                top: 10,
                                                child: PopupMenuButton<String>(
                                                  onSelected: (String result) {
                                                    if (result == 'agregarFotos') {
                                                      _mostrarModalAgregarFotos(context, publicacion['id']);
                                                    } else if (result == 'cambiarEstado') {
                                                      if (publicacion['estado'] == 'perdido') {
                                                        _mostrarConfirmacionCambioEstado(
                                                          publicacion['id'],
                                                          'encontrado',
                                                          'Confirmación',
                                                          'Al aceptar, confirmarás que encontraste a tu mascota, ¿Es correcto?',
                                                          publicacion['estado'], // Pasar el estado actual
                                                        );
                                                      } else if (publicacion['estado'] == 'encontrado') {
                                                        _mostrarConfirmacionCambioEstado(
                                                          publicacion['id'],
                                                          'perdido',
                                                          'Confirmación',
                                                          'Si tu mascota se volvió a perder, actualiza los datos y acepta este mensaje para hacer pública la desaparición de tu mascota.',
                                                          publicacion['estado'], // Pasar el estado actual
                                                        );
                                                      } else if (publicacion['estado'] == 'adopcion') {
                                                        _mostrarConfirmacionCambioEstado(
                                                          publicacion['id'],
                                                          'pendiente',
                                                          'Interés en la Mascota',
                                                          '¿Está alguien interesado en adoptar a esta mascota? Al aceptar, cambiará el estado a pendiente.',
                                                          publicacion['estado'], // Pasar el estado actual
                                                        );
                                                      } else if (publicacion['estado'] == 'pendiente') {
                                                        _mostrarConfirmacionCambioEstado(
                                                          publicacion['id'],
                                                          'adoptado',
                                                          'Confirmación de Adopción',
                                                          '¿La mascota fue adoptada? Al aceptar, cambiará el estado a adoptado y no se podrá cambiar nuevamente.',
                                                          publicacion['estado'], // Pasar el estado actual
                                                        );
                                                      }
                                                    } else if (result == 'editar') {
                                                        Navigator.of(context).push(
                                                          MaterialPageRoute(
                                                            builder: (context) => EditarPublicacionPage(
                                                              publicacion: publicacion,
                                                              estado: publicacion['estado'], // Pasar el estado actual
                                                            ),
                                                          ),
                                                        );
                                                      } else if (result == 'eliminar') {
                                                      _confirmarEliminacionPublicacion(publicacion['id']);
                                                    }
                                                  },
                                                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                                                    PopupMenuItem<String>(
                                                      value: 'agregarFotos',
                                                      child: Text('Agregar Fotos'),
                                                    ),
                                                    PopupMenuItem<String>(
                                                      value: 'cambiarEstado',
                                                      child: Text('Perdido/Encontrado/Adopción'),
                                                    ),
                                                    PopupMenuItem<String>(
                                                      value: 'editar',
                                                      child: Text('Actualizar datos'),
                                                    ),
                                                    PopupMenuItem<String>(
                                                      value: 'eliminar',
                                                      child: Text('Eliminar publicación'),
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
                                                  publicacion['nombre'],
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                                                ),
                                                SizedBox(height: 5),
                                                  if (publicacion['estado'] == 'pendiente') ...[
                                                    Center(
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          // Lógica para mostrar la lista de interesados
                                                          _mostrarInteresados(publicacion['id']);
                                                        },
                                                        child: Text('Ver interesados'),
                                                      ),
                                                    ),
                                                  ] else ...[
                                                    if (!(publicacion['estado'] == 'adopcion' || publicacion['estado'] == 'adoptado')) ...[
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
                                                    ],
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
Future<void> _mostrarInteresados(int idMascota) async {
  final url = Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/adopcion.php?mascota_id=$idMascota');
  
  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['status'] == 'success') {
        List interesados = data['data'];
          // Mostramos un diálogo con la lista de interesados
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Interesados en Adoptar'),
                content: interesados.isNotEmpty
                    ? SizedBox(
                        width: double.maxFinite,
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

                            // Crear el link de WhatsApp
                            final whatsappUri = Uri.parse(
                              'https://wa.me/${interesado['telefono']}?text=Hola, me comunico contigo porque estás interesado en adoptar una mascota.',
                            );

                            return ListTile(
                              leading: Icon(Icons.person),
                              title: Text(nombreCompleto),
                              subtitle: Text(interesado['email']),
                              trailing: IconButton(
                                icon: Icon(Icons.message, color: Colors.green),
                                onPressed: () {
                                  // Abrir WhatsApp
                                  launchUrl(whatsappUri);
                                },
                              ),
                              // Mostrar el número de teléfono con opción para contactar
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Contactar a ${interesado['nombre']}'),
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Teléfono: ${interesado['telefono']}'),
                                          SizedBox(height: 10),
                                          ElevatedButton.icon(
                                            icon: Icon(Icons.message),
                                            label: Text('Contactar por WhatsApp'),
                                            onPressed: () {
                                              launchUrl(whatsappUri);  // Abrir WhatsApp
                                            },
                                          ),
                                        ],
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
                            );
                          },
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
    } else {
        print(data['message']);  // Mostrar error en caso de que no haya interesados
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
      return 'Tu mascota te extraña tanto tú a él/ella';
    case 'encontrado':
      return 'Nos complace saber que tu mascota fue encontrada';
    case 'adopcion':
      return 'Esta mascota está en adopción';
    case 'pendiente':
      return 'Mascota pendiente para la adopción';
    case 'adoptado':
      return 'Esta mascota ya fue adoptada';
    default:
      return 'Estado desconocido'; // Texto por defecto si no coincide con ningún estado
  }
}

}