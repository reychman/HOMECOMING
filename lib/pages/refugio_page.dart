import 'package:flutter/material.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';

class Refugio extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido Refugio'),
      ),
      drawer: MenuWidget(),
      body: Center(
        child: Text('Contenido para refugios'),
      ),
    );
  }
}