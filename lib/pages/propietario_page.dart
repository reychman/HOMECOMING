import 'package:flutter/material.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/usuario.dart';

class Propietario extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Usuario? usuario;
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido Propietario'),
      ),
      drawer: MenuWidget(usuario: usuario ?? Usuario.vacio()), 
      body: Center(
        child: Text('Contenido para propietarios'),
      ),
    );
  }
}
