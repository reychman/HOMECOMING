import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/editar_perfil_page.dart';
import 'package:homecoming/pages/login/EditarPublicacionPage.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/usuario.dart';
import 'package:homecoming/pages/usuario_provider.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

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

    request.fields['id'] = _usuario!.id.toString();
    request.files.add(http.MultipartFile.fromBytes(
      'foto_portada',
      imageBytes,
      contentType: MediaType('image', 'jpeg'),
    ));

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      final jsonResponse = jsonDecode(responseData);

      if (jsonResponse['success'] != null) {
        print('Imagen subida correctamente');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imagen subida correctamente'),
            duration: Duration(seconds: 2),
          ),
        );

        setState(() {
          _usuario!.fotoPortada = jsonResponse['foto_portada'];
        });

        if (_usuario!.id != null) {
          await UsuarioProvider.actualizarFotoPortada(_usuario!.id!, jsonResponse['foto_portada']);
        }

        Navigator.of(context).pop(); 
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => PerfilUsuario(),
        ));
      } else {
        print('Error al subir imagen: ${jsonResponse['error']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${jsonResponse['error']}'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('Error en _uploadImage: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al subir imagen'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = imageBytes;
      });
      await _uploadImage(_imageBytes!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se seleccionó ninguna imagen.')),
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
                    await _submitNewPassword(newPasswordController.text);
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


Future<void> _submitNewPassword(String newPassword) async {
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

        // Verifica si hay un error en la respuesta
        if (jsonResponse is List) {
          setState(() {
            _misPublicaciones = jsonResponse;
          });

          // Verifica si _misPublicaciones contiene datos
          if (_misPublicaciones.isNotEmpty) {
            //print('Mis publicaciones: $_misPublicaciones');
          } else {
            print('No se encontraron publicaciones.');
          }
        } else {
          print('Error: ${jsonResponse['error']}');
        }
      } else {
        print('Error al obtener las publicaciones: ${response.statusCode}');
      }
    } catch (e) {
      print('Error en la solicitud: $e');
    }
  }

  // Cambiar el estado de la publicación (por ejemplo, de perdido a encontrado)
  Future<void> _changeEstadoMascota(int publicacionId, String nuevoEstado) async {
    var response = await http.post(
      Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/gestionar_publicaciones.php'),
      body: {
        'accion': 'actualizarEstado',
        'id': publicacionId,
        'estado': nuevoEstado,
      }
    );
    if (response.statusCode == 200) {
      _fetchUserPublications(); // Actualiza las publicaciones después del cambio
    } else {
      print('Error al cambiar el estado: ${response.statusCode}');
    }
  }

  // Eliminar una publicación lógicamente (cambiar el estado_registro a 0)
  Future<void> _eliminarPublicacion(int publicacionId) async {
    var response = await http.post(
      Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/gestionar_publicaciones.php'),
      body: {
        'accion': 'eliminarPublicacion',
        'id': publicacionId,
      }
    );
    if (response.statusCode == 200) {
      _fetchUserPublications(); // Actualiza las publicaciones después de eliminar
    } else {
      print('Error al eliminar la publicación: ${response.statusCode}');
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0), // Margen alrededor del contenido
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 20), // Añadir espacio arriba
                    GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey,
                        backgroundImage: _usuario!.fotoPortada != null && _usuario!.fotoPortada!.isNotEmpty
                            ? NetworkImage(_usuario!.fotoPortada!)
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
                      onPressed: _updatePassword, // Botón para actualizar contraseña
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
                    ..._misPublicaciones.map((publicacion) {
                      return Center(
                        child: Container(
                          width: 400, // Ajustar el ancho del card
                          margin: EdgeInsets.symmetric(vertical: 10), // Márgenes verticales
                          child: Card(
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (publicacion['estado'] == 'perdido')
                                Container(
                                  width: double.infinity,
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(10),
                                      topRight: Radius.circular(10),
                                    ),
                                  ),
                                  child: Text(
                                    '¡Hay una familia que busca a esta mascota!',
                                    style: TextStyle(color: Colors.white),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                SizedBox(
                                  height: 400, // Altura fija
                                  width: 400,  // Ancho fijo
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.vertical(
                                      bottom: Radius.circular(10),
                                    ),
                                    child: Image.asset(
                                      'assets/imagenes/fotos_mascotas/${publicacion['foto']}',
                                      fit: BoxFit.cover, // Ajusta la imagen dentro de las dimensiones
                                      errorBuilder: (context, error, stackTrace) {
                                        return Icon(Icons.pets, size: 200, color: Colors.grey); // Icono si la imagen falla
                                      },
                                    ),
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
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          _changeEstadoMascota(publicacion['id'], 'encontrado');
                                        },
                                        child: Text('Cambiar a Encontrado'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) => EditarPublicacionPage(publicacion: publicacion),
                                            ),
                                          );
                                        },
                                        child: Text('Editar'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _eliminarPublicacion(publicacion['id']);
                                        },
                                        child: Text('Eliminar', style: TextStyle(color: Colors.red)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(height: 20), // Añadir espacio al final
                  ],
                ),
              ),
            ),
    );
  }
}
