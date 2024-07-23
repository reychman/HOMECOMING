import 'package:flutter/material.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';

class PlanesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planes'),
      ),
      drawer: MenuWidget(),
      body: Center(
        child: Text('Contenido de Planes'),
      ),
    );
  }
}
