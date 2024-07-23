import 'package:flutter/material.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';

class Propietario extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido Propietario'),
      ),
      drawer: MenuWidget(),
      body: Center(
        child: Text('Contenido para propietarios'),
      ),
    );
  }
}
