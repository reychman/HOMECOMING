import 'package:flutter/material.dart';
import 'package:homecoming/pages/admin_usuarios_page.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/menu/usuario.dart';

class ModificarUsuarioPage extends StatefulWidget {
  final Usuario user;

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
  Usuario? usuario;
  @override
  void initState() {
    super.initState();
    _nombreController.text = widget.user.nombre;
    _primerApellidoController.text = widget.user.primerApellido;
    _segundoApellidoController.text = widget.user.segundoApellido;
    _telefonoController.text = widget.user.telefono;
    _emailController.text = widget.user.email;
    _tipoUsuario = widget.user.tipoUsuario;
  }

Future<void> _updateUser() async {
  final nombre = _nombreController.text.toUpperCase();
  final primerApellido = _primerApellidoController.text.toUpperCase();
  final segundoApellido = _segundoApellidoController.text.toUpperCase();
  final telefono = _telefonoController.text;
  final email = _emailController.text;
  final tipoUsuario = _tipoUsuario;

  final updatedUser = Usuario(
    id: widget.user.id,
    nombre: nombre,
    primerApellido: primerApellido,
    segundoApellido: segundoApellido,
    telefono: telefono,
    email: email,
    contrasena: widget.user.contrasena, // Mantén la contraseña actual si no se actualiza
    tipoUsuario: tipoUsuario,
    fotoPortada: widget.user.fotoPortada,
    fechaCreacion: widget.user.fechaCreacion,
    fechaModificacion: DateTime.now(), // Actualiza la fecha
    estado: widget.user.estado,
  );

  final result = await updatedUser.updateUsuario(); // Llama al método updateUsuario

  if (result) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Datos Actualizados Correctamente'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => AdminUsuariosPage()),
    );
  } else {
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
      drawer: MenuWidget(usuario: usuario ?? Usuario.vacio()), 
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
