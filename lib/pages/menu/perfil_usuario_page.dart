import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/editar_perfil_page.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/menu/usuario.dart';
import 'package:homecoming/pages/menu/usuario_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _loadUserData(); 
  }

Future<void> _loadUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  int? userId = prefs.getInt('userId');

  if (userId != null) {
    Usuario? usuarioLogeado = await UsuarioProvider.getUsuarioActual(userId);
    setState(() {
      _usuario = usuarioLogeado;
    });
  } else {
    print('No se encontró un userId en SharedPreferences');
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

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      drawer: MenuWidget(usuario: _usuario ?? Usuario.vacio()), 
      body: Center(
        child: _usuario == null
            ? CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
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
                    onPressed: _logout,
                    child: Text('Cerrar Sesión'),
                  ),
                ],
              ),
      ),
    );
  }
}
