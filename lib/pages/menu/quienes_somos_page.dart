import 'package:flutter/material.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';

class QuienesSomosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('¿Quiénes somos?'),
      ),
      drawer: MenuWidget(),
      body: Center(
        child: Text('Contenido de ¿Quiénes somos?'),
      ),
    );
  }
}
