import 'package:flutter/material.dart';
import 'package:homecoming/pages/menu/menu_widget.dart';

class MapaBusquedasPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapa de búsquedas'),
      ),
      drawer: MenuWidget(),
      body: Center(
        child: Text('Contenido de Mapa de búsquedas'),
      ),
    );
  }
}
