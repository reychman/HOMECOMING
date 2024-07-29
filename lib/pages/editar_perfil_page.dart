import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homecoming/pages/menu/perfil_usuario_page.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:homecoming/ip.dart';

class EditarPerfilPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditarPerfilPage({Key? key, required this.user}) : super(key: key);

  @override
  _EditarPerfilPageState createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nombreController = TextEditingController();
  TextEditingController _primerApellidoController = TextEditingController();
  TextEditingController _segundoApellidoController = TextEditingController();
  TextEditingController _telefonoController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  late int userId;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

Future<void> _loadUserData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  setState(() {
    userId = prefs.getInt('id') ?? 0; // Verifica que 'id' sea el nombre correcto
    _nombreController.text = prefs.getString('nombre') ?? '';
    _primerApellidoController.text = prefs.getString('primerApellido') ?? '';
    _segundoApellidoController.text = prefs.getString('segundoApellido') ?? '';
    _telefonoController.text = prefs.getString('telefono') ?? '';
    _emailController.text = prefs.getString('email') ?? '';
    print('ID del usuario: $userId'); // Para depuración
    print('Nombre: ${prefs.getString('nombre')}');
    print('Primer Apellido: ${prefs.getString('primerApellido')}');
    print('Segundo Apellido: ${prefs.getString('segundoApellido')}');
    print('Teléfono: ${prefs.getString('telefono')}');
    print('Email: ${prefs.getString('email')}');

  });
}

  Future<void> _updateUser() async {
  if (_formKey.currentState!.validate()) {
    final response = await http.post(
      Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/actualizar_usuario.php'),
      body: {
        'id': userId.toString(),
        'nombre': _nombreController.text,
        'primerApellido': _primerApellidoController.text,
        'segundoApellido': _segundoApellidoController.text,
        'telefono': _telefonoController.text,
        'email': _emailController.text,
        // Agregar tipo_usuario solo si es necesario
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] != null) {
        print('Usuario actualizado correctamente');
        // Actualizando el SharedPreferences con los nuevos datos
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('nombre', _nombreController.text);
        await prefs.setString('primerApellido', _primerApellidoController.text);
        await prefs.setString('segundoApellido', _segundoApellidoController.text);
        await prefs.setString('telefono', _telefonoController.text);
        await prefs.setString('email', _emailController.text);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Datos Actualizados Correctamente'),
            duration: Duration(seconds: 2),
          ),
        );
         // Regresar a la página de perfil
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => PerfilUsuario(),
        ));
      } else {
        print('Error al actualizar usuario: ${responseData['error']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${responseData['error']}'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      print('Error al actualizar usuario: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar usuario'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nombreController,
                decoration: InputDecoration(labelText: 'Nombre'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su nombre';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _primerApellidoController,
                decoration: InputDecoration(labelText: 'Primer Apellido'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su primer apellido';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _segundoApellidoController,
                decoration: InputDecoration(labelText: 'Segundo Apellido'),
              ),
              TextFormField(
                controller: _telefonoController,
                decoration: InputDecoration(labelText: 'Teléfono'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su teléfono';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese su email';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateUser,
                child: Text('Guardar Datos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
