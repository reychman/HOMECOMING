import 'package:flutter/material.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/menu/usuario.dart';

class PlanesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
      Usuario? usuario;
    return Scaffold(
      appBar: AppBar(
        title: Text('Planes'),
      ),
      drawer: MenuWidget(usuario: usuario ?? Usuario.vacio()), 
      body: Center(
        child: Text('Contenido de Planes'),
      ),
    );
  }
}
