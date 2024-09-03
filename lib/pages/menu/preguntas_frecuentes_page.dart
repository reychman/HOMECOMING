import 'package:flutter/material.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';
import 'package:homecoming/pages/usuario.dart';

class PreguntasFrecuentesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Usuario? usuario;
    return Scaffold(
      appBar: AppBar(
        title: Text('Preguntas Frecuentes'),
      ),
      drawer: MenuWidget(usuario: usuario ?? Usuario.vacio()), 
      body: Center(
        child: Text('Contenido de Preguntas Frecuentes'),
      ),
    );
  }
}
