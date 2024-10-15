import 'package:flutter/material.dart';
import 'package:homecoming/pages/admin_usuarios_page.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/usuario.dart';

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
  
  // Campos para refugio
  final TextEditingController _nombreRefugioController = TextEditingController();
  final TextEditingController _emailRefugioController = TextEditingController();
  final TextEditingController _ubicacionRefugioController = TextEditingController();
  final TextEditingController _telefonoRefugioController = TextEditingController();

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

    // Inicializa campos de refugio si el tipo de usuario es refugio
    if (_tipoUsuario == 'refugio') {
      _nombreRefugioController.text = widget.user.nombreRefugio ?? '';
      _emailRefugioController.text = widget.user.emailRefugio ?? '';
      _ubicacionRefugioController.text = widget.user.ubicacionRefugio ?? '';
      _telefonoRefugioController.text = widget.user.telefonoRefugio ?? '';
    }
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
      // Campos adicionales para refugio
      nombreRefugio: _tipoUsuario == 'refugio' ? _nombreRefugioController.text.toUpperCase() : null,
      emailRefugio: _tipoUsuario == 'refugio' ? _emailRefugioController.text : null,
      ubicacionRefugio: _tipoUsuario == 'refugio' ? _ubicacionRefugioController.text.toUpperCase() : null,
      telefonoRefugio: _tipoUsuario == 'refugio' ? _telefonoRefugioController.text : null,
    );

    final result = await updatedUser.updateUsuario(); // Llama al método updateUsuario

    // Verificamos la respuesta del servidor
    if (result['success'] != null) {
      // Cambiamos a éxito en lugar de un booleano
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Datos Actualizados Correctamente'),
          duration: Duration(seconds: 2),
        ),
      );
      // Redirigir a la página de administración de usuarios
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => AdminUsuarios()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Error al actualizar usuario'),
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
                  // Limpiar los campos de refugio si cambia el tipo de usuario
                  if (_tipoUsuario != 'refugio') {
                    _nombreRefugioController.clear();
                    _emailRefugioController.clear();
                    _ubicacionRefugioController.clear();
                    _telefonoRefugioController.clear();
                  }
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

            // Campos adicionales solo para refugios
            if (_tipoUsuario == 'refugio') ...[
              TextField(
                controller: _nombreRefugioController,
                decoration: InputDecoration(labelText: 'Nombre Refugio'),
              ),
              TextField(
                controller: _emailRefugioController,
                decoration: InputDecoration(labelText: 'Email Refugio'),
              ),
              TextField(
                controller: _ubicacionRefugioController,
                decoration: InputDecoration(labelText: 'Ubicación Refugio'),
              ),
              TextField(
                controller: _telefonoRefugioController,
                decoration: InputDecoration(labelText: 'Teléfono Refugio'),
              ),
            ],
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
