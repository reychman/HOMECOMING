import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/editar_perfil_page.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
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
  String? nombre;
  String? email;
  String? primerApellido;
  String? segundoApellido;
  String? telefono;
  String? fotoPortada;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      nombre = prefs.getString('nombre') ?? '';
      email = prefs.getString('email') ?? '';
      primerApellido = prefs.getString('primerApellido') ?? '';
      segundoApellido = prefs.getString('segundoApellido') ?? '';
      telefono = prefs.getString('telefono') ?? '';
      fotoPortada = prefs.getString('foto_portada') ?? '';
    });
  }

  Future<void> _uploadImage(Uint8List imageBytes) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id') ?? 0;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('http://$serverIP/homecomingbd_v2/upload_image.php'),
    );

    request.fields['id'] = userId.toString();
    request.files.add(http.MultipartFile.fromBytes(
      'foto_portada',
      imageBytes,
      contentType: MediaType('image', 'jpeg'), // Asegúrate de que el tipo es correcto
    ));

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();
      print('Respuesta del servidor: $responseData');

      final jsonResponse = jsonDecode(responseData);

      if (jsonResponse['success'] != null) {
        print('Imagen subida correctamente');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Imagen subida correctamente'),
            duration: Duration(seconds: 2),
          ),
        );

        await prefs.setString('foto_portada', jsonResponse['foto_portada']);
        setState(() {
          fotoPortada = jsonResponse['foto_portada'];
        });
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
          content: Text('Error al subir imagen catch'),
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
      drawer: MenuWidget(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey,
                backgroundImage: fotoPortada != null && fotoPortada!.isNotEmpty
                    ? NetworkImage(fotoPortada!)
                    : _imageBytes != null
                        ? MemoryImage(_imageBytes!) // Usa MemoryImage para mostrar la imagen cargada
                        : AssetImage('assets/imagenes/avatar7.png'),
                child: fotoPortada == null && _imageBytes == null
                    ? Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                      )
                    : null,
              ),
            ),
            SizedBox(height: 20),
            Text(
              nombre ?? '',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              email ?? '',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => EditarPerfilPage(user: {
                    'nombre': nombre,
                    'primerApellido': primerApellido,
                    'segundoApellido': segundoApellido,
                    'telefono': telefono,
                    'email': email,
                  }),
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
