import 'package:flutter/material.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/admin_usuarios_page.dart';
import 'package:homecoming/pages/usuario.dart';

class Administrador extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Usuario? usuario;
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido Administrador'),
      ),
      drawer: MenuWidget(usuario: usuario ?? Usuario.vacio()), 
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => AdminUsuariosPage(),
            ));
          },
          child: Text('Administrar Usuarios'),
        ),
      ),
    );
  }
}
