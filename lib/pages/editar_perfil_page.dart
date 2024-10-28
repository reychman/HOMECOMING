import 'package:flutter/material.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/login/perfil_usuario_page.dart';
import 'package:homecoming/pages/usuario.dart';

class EditarPerfilPage extends StatefulWidget {
  final Usuario user;

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
  late Usuario user;
  Usuario? usuario;
  
  @override
  void initState() {
    super.initState();
    user = widget.user;
    _nombreController.text = user.nombre;
    _primerApellidoController.text = user.primerApellido;
    _segundoApellidoController.text = user.segundoApellido;
    _telefonoController.text = user.telefono;
    _emailController.text = user.email;
  }

Future<void> _updateUser() async {
  if (_formKey.currentState!.validate()) {
    user.nombre = _nombreController.text;
    user.primerApellido = _primerApellidoController.text;
    user.segundoApellido = _segundoApellidoController.text;
    user.telefono = _telefonoController.text;
    user.email = _emailController.text;

    final result = await user.actualizarPerfil();

    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Datos Actualizados Correctamente'),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => PerfilUsuario(),
      ));
    } else {
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
      drawer: MenuWidget(usuario: usuario ?? Usuario.vacio()),
      backgroundColor: Colors.green[50],
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
