import 'dart:convert'; // Importar para usar jsonDecode
import 'package:flutter/material.dart';
import 'package:homecoming/ip.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:http/http.dart' as http;
import 'package:homecoming/pages/admin_usuarios_page.dart'; // Importa la página a la que quieres redirigir

class ModificarUsuarioPage extends StatefulWidget {
  final Map<String, dynamic> user;

  const ModificarUsuarioPage({Key? key, required this.user}) : super(key: key);

  @override
  _ModificarUsuarioPageState createState() => _ModificarUsuarioPageState();
}

class _ModificarUsuarioPageState extends State<ModificarUsuarioPage> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _primerApellidoController = TextEditingController();
  final TextEditingController _segundoApellidoController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  String _tipoUsuario = '';

  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.user['nombre'];
    _primerApellidoController.text = widget.user['primerApellido'];
    _segundoApellidoController.text = widget.user['segundoApellido'];
    _telefonoController.text = widget.user['telefono'];
    _emailController.text = widget.user['email'];
    _tipoUsuario = widget.user['tipo_usuario'];
  }

  Future<void> _updateUser() async {
    final url = Uri.parse('http://$serverIP/homecoming/homecomingbd_v2/actualizar_usuario.php');
    final response = await http.post(
      url,
      body: {
        'id': widget.user['id'].toString(),
        'nombre': _nombreController.text,
        'primerApellido': _primerApellidoController.text,
        'segundoApellido': _segundoApellidoController.text,
        'telefono': _telefonoController.text,
        'email': _emailController.text,
        'tipo_usuario': _tipoUsuario.isNotEmpty ? _tipoUsuario : '',
      },
    );

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      if (responseData['success'] != null) {
        // Handle successful update
        print('Usuario actualizado correctamente');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Datos Actualizados Correctamente'),
            duration: Duration(seconds: 2),
          ),
        );
        // Navegar a la página de administración de usuarios
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => AdminUsuariosPage(),
        ));
      } else {
        // Handle error response from the server
        print('Error al actualizar usuario: ${responseData['error']}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${responseData['error']}'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // Handle HTTP error
      print('Error al actualizar usuario: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar usuario'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modificar Usuario'),
      ),
      drawer: MenuWidget(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            TextField(
              controller: _primerApellidoController,
              decoration: InputDecoration(labelText: 'Primer Apellido'),
            ),
            TextField(
              controller: _segundoApellidoController,
              decoration: InputDecoration(labelText: 'Segundo Apellido'),
            ),
            TextField(
              controller: _telefonoController,
              decoration: InputDecoration(labelText: 'Teléfono'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            DropdownButtonFormField<String>(
              value: _tipoUsuario,
              onChanged: (newValue) {
                setState(() {
                  _tipoUsuario = newValue!;
                });
              },
              items: ['administrador', 'propietario', 'refugio']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              decoration: InputDecoration(labelText: 'Tipo Usuario'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateUser,
              child: Text('Guardar Cambios'),
            ),
          ],
        ),
      ),
    );
  }
}
