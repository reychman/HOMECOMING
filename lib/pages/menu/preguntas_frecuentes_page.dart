import 'package:flutter/material.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';

class PreguntasFrecuentesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preguntas Frecuentes'),
      ),
      drawer: MenuWidget(),
      body: Center(
        child: Text('Contenido de Preguntas Frecuentes'),
      ),
    );
  }
}
