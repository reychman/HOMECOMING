import 'package:flutter/material.dart';
import 'package:homecoming/pages/editar_perfil_page.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class PerfilUsuario extends StatefulWidget {
  const PerfilUsuario({Key? key}) : super(key: key);
  @override
  _PerfilUsuarioState createState() => _PerfilUsuarioState();
}

class _PerfilUsuarioState extends State<PerfilUsuario> {
  File? _image;
  String? nombre;
  String? email;
  String? primerApellido;
  String? segundoApellido;
  String? telefono;

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
    });
    print('Nombre: $nombre');
    print('primerApellido: $email');
    print('segundoApellido: $email');
    print('telefono: $telefono');
    print('Email: $email');
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpia todos los datos de SharedPreferences
    Navigator.of(context).pushReplacementNamed('/home'); // Redirige a la página principal
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
                backgroundImage: _image != null ? FileImage(_image!) : AssetImage('assets/imagenes/avatar7.png'),
                child: _image == null
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